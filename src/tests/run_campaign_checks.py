#!/usr/bin/env python3
"""Run Linux-only campaign/recovery checks with isolated user storage and retained evidence."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args(argv)
    # XDG overrides protect player storage only on the verified Linux host.
    # Refuse before starting even --version or creating any fixture/output paths.
    if platform.system() != "Linux":
        parser.error("Campaign checks require Linux: XDG isolation is not supported by this runner on other hosts. No Godot process or save fixture was started.")
    args.output.mkdir(parents=True, exist_ok=True)
    # Never reuse prior state accidentally, even when the evidence directory exists.
    sandbox = Path(tempfile.mkdtemp(prefix='path-of-light-18-'))
    engine = args.godot.resolve()

    source_paths = subprocess.check_output(['git', 'ls-files', '-c', '-o', '--exclude-standard', '-z'], cwd=ROOT).decode().split('\0')
    sources = {name: sha(ROOT / name) for name in sorted(set(source_paths))
               if name and (ROOT / name).is_file() and not name.startswith('docs/verification/issue-18/')}
    report = {
        'source_files_sha256': sources,
        'source_manifest_sha256': hashlib.sha256(json.dumps(sources, sort_keys=True, separators=(',', ':')).encode()).hexdigest(),
        'base_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        'engine': str(engine), 'engine_sha256': sha(engine),
        'engine_version': subprocess.check_output([str(engine), '--version'], text=True).strip(),
        'platform': platform.platform(), 'sandbox': str(sandbox), 'results': []}


    def run(name, script, extra=(), storage=None):
        env = os.environ.copy()
        storage_root = sandbox / (storage or name)
        isolated = {f'XDG_{kind.upper()}_HOME': str(storage_root / kind)
                    for kind in ('data', 'config', 'cache')}
        env.update(isolated)
        cmd = [str(engine), '--headless', '--path', str(ROOT), '--script',
               'res://src/tests/scripts/' + script + '.gd']
        if extra:
            cmd += ['--', *extra]
        try:
            process = subprocess.run(cmd, cwd=ROOT, env=env, capture_output=True, timeout=90)
            stdout, stderr, code = process.stdout, process.stderr, process.returncode
        except subprocess.TimeoutExpired as exc:
            stdout, stderr, code = exc.stdout or b'', exc.stderr or b'', 'timeout'
        for stream, contents in [('stdout', stdout), ('stderr', stderr)]:
            (args.output / f'{name}.{stream}.log').write_bytes(contents)
        combined = (stdout + stderr).decode(errors='replace')
        diagnostics = [line for line in combined.splitlines()
                       if any(word in line for word in ('SCRIPT ERROR', 'Parse Error', 'FAIL:'))]
        entry = {'name': name, 'command': cmd, 'environment': isolated,
                 'exit_code': code, 'diagnostics': diagnostics,
                 'pass_lines': [line for line in combined.splitlines() if 'PASS:' in line],
                 'stdout_sha256': hashlib.sha256(stdout).hexdigest(),
                 'stderr_sha256': hashlib.sha256(stderr).hexdigest()}
        report['results'].append(entry)
        (args.output / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
        print(f'{name}: exit={code}, diagnostics={len(diagnostics)}', flush=True)
        return code == 0 and not diagnostics

    checks = [run('storage', 'campaign_storage_integration')]
    checks += [run('campaign-write', 'campaign_restart_integration', ['--write'], 'restart'),
               run('campaign-restore', 'campaign_restart_integration', ['--verify'], 'restart'),
               run('migration-seed', 'campaign_restart_integration', ['--seed-migration'], 'migration'),
               run('migration-restore', 'campaign_restart_integration', ['--verify-migration'], 'migration'),
               run('migration-second-restart', 'campaign_restart_integration', ['--verify'], 'migration')]
    for mode in ('future', 'corrupt', 'recovered', 'write-failure'):
        checks.append(run('failure-' + mode, 'campaign_failure_integration', ['--' + mode]))
    # These exercise the affected record, reset, retry, menu and assist boundaries.
    for script in ('attempt_recovery', 'recovery_records', 'restart_lifecycle',
                   'fall_depletion', 'assist_recovery', 'assist_ui', 'pause_menu', 'two_levels'):
        checks.append(run(script, script + '_integration'))
    report['passed'] = sum(checks)
    report['total'] = len(checks)
    report['all_passed'] = all(checks)
    (args.output / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
    return 0 if all(checks) else 1


if __name__ == "__main__":
    raise SystemExit(main())
