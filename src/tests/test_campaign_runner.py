"""Regression checks for the runner's destructive-fixture storage boundary.

Host names and engine subprocesses are mocked; these are not native platform
or Godot integration results. Run from the repository root with unittest.
"""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location(
    'campaign_runner', Path(__file__).with_name('run_campaign_checks.py'))
RUNNER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(RUNNER)


class CampaignRunnerIsolationTests(unittest.TestCase):
    def test_unsupported_hosts_refuse_before_any_engine_or_fixture(self):
        for host in ('Windows', 'Darwin', 'FreeBSD', 'Unknown'):
            with self.subTest(host=host), tempfile.TemporaryDirectory() as folder:
                root = Path(folder)
                player = root / 'player'
                player.mkdir()
                originals = {'campaign.json': b'valuable campaign',
                             'campaign.json.bak': b'valuable backup',
                             'settings.cfg': b'valuable preferences'}
                for name, contents in originals.items():
                    (player / name).write_bytes(contents)
                output = root / 'must-not-be-created'
                stderr = io.StringIO()
                with patch.object(RUNNER.platform, 'system', return_value=host), \
                     patch.object(RUNNER.subprocess, 'run') as run, \
                     patch.object(RUNNER.subprocess, 'check_output') as check_output, \
                     patch.object(RUNNER.tempfile, 'mkdtemp') as mkdtemp, \
                     patch.dict(os.environ, {'APPDATA': str(player),
                                             'XDG_DATA_HOME': str(player)}), \
                     contextlib.redirect_stderr(stderr):
                    with self.assertRaises(SystemExit) as error:
                        RUNNER.main(['--godot', str(root / 'native-godot'),
                                     '--output', str(output)])
                self.assertEqual(error.exception.code, 2)
                self.assertIn('require Linux', stderr.getvalue())
                run.assert_not_called()
                check_output.assert_not_called()  # Includes engine --version.
                mkdtemp.assert_not_called()
                self.assertFalse(output.exists())
                self.assertEqual({p.name: p.read_bytes() for p in player.iterdir()},
                                 originals)

    def run_linux_with_mock_engine(self, *, fail=False):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            sandbox = root / 'sandbox'
            sandbox.mkdir()
            output = root / 'evidence'

            def command_output(command, **kwargs):
                if command[:2] == ['git', 'ls-files']:
                    return b''
                if command[:2] == ['git', 'rev-parse']:
                    return 'mock-base\n'
                return 'mock-engine\n'

            process = subprocess.CompletedProcess([], 1 if fail else 0,
                                                  b'FAIL: fixture\n' if fail else b'PASS: fixture\n', b'')
            with patch.object(RUNNER.platform, 'system', return_value='Linux'), \
                 patch.object(RUNNER.tempfile, 'mkdtemp', return_value=str(sandbox)), \
                 patch.object(RUNNER, 'sha', return_value='mock-hash'), \
                 patch.object(RUNNER.subprocess, 'check_output', side_effect=command_output), \
                 patch.object(RUNNER.subprocess, 'run', return_value=process) as run, \
                 patch.dict(os.environ, {'XDG_DATA_HOME': '/must-not-use-player-data',
                                         'XDG_CONFIG_HOME': '/must-not-use-player-config',
                                         'XDG_CACHE_HOME': '/must-not-use-player-cache'}), \
                 contextlib.redirect_stdout(io.StringIO()):
                result = RUNNER.main(['--godot', str(root / 'godot'),
                                      '--output', str(output)])
            calls = run.call_args_list
            self.assertEqual(len(calls), 19)
            roots = []
            for call in calls:
                env = call.kwargs['env']
                for kind in ('data', 'config', 'cache'):
                    resolved = Path(env[f'XDG_{kind.upper()}_HOME'])
                    self.assertTrue(resolved.is_relative_to(sandbox))
                    self.assertEqual(resolved.name, kind)
                roots.append(Path(env['XDG_DATA_HOME']).parent)
            # Only deliberate restart/migration sequences share user storage.
            self.assertEqual(roots[1], roots[2])
            self.assertEqual(roots[3], roots[4])
            self.assertEqual(roots[4], roots[5])
            self.assertEqual(len(set(roots)), 16)
            self.assertEqual(len(set(roots[6:])), 13)
            report = json.loads((output / 'results.json').read_text())
            self.assertEqual(report['all_passed'], not fail)
            self.assertEqual(report['passed'], 0 if fail else 19)
            self.assertEqual(result, 1 if fail else 0)

    def test_linux_replaces_inherited_storage_for_all_fixtures(self):
        self.run_linux_with_mock_engine()

    def test_fixture_failures_return_nonzero(self):
        self.run_linux_with_mock_engine(fail=True)

    def test_help_is_available_without_engine_or_storage_on_other_hosts(self):
        with patch.object(RUNNER.platform, 'system', return_value='Darwin'), \
             patch.object(RUNNER.subprocess, 'run') as run, \
             patch.object(RUNNER.subprocess, 'check_output') as check_output, \
             patch.object(RUNNER.tempfile, 'mkdtemp') as mkdtemp, \
             contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaises(SystemExit) as error:
                RUNNER.main(['--help'])
        self.assertEqual(error.exception.code, 0)
        run.assert_not_called()
        check_output.assert_not_called()
        mkdtemp.assert_not_called()


if __name__ == '__main__':
    unittest.main()
