"""Independent mocked runner probes; not native Windows/macOS execution."""
import contextlib, importlib.util, io, json, pathlib, subprocess, tempfile
from unittest.mock import patch
ROOT = pathlib.Path('/home/stevdrey/Projects/Godot/Experiment 2D Platform/experiment-2d-platform')
OUT = pathlib.Path('/tmp/path-of-light-48-isolation-independent')
spec=importlib.util.spec_from_file_location('reviewed_runner',ROOT/'src/tests/run_campaign_checks.py')
module=importlib.util.module_from_spec(spec)
with patch('subprocess.Popen',side_effect=AssertionError('import launched child')), patch('pathlib.Path.mkdir',side_effect=AssertionError('import created directory')), patch('tempfile.mkdtemp',side_effect=AssertionError('import created sandbox')):
    spec.loader.exec_module(module)
results=[{'name':'import has no child/storage effects','pass':True}]
with tempfile.TemporaryDirectory(dir=OUT) as temp:
    directory=pathlib.Path(temp)
    output=directory/'existing-evidence'
    output.mkdir()
    marker=output/'campaign.json'
    marker.write_bytes(b'valuable existing output/player sentinel')
    for host in ['Windows','Darwin','FreeBSD','OpenBSD','','linux',None]:
        stderr=io.StringIO()
        with patch.object(module.platform,'system',return_value=host), patch.object(module.subprocess,'Popen',side_effect=AssertionError('child launched')), patch.object(module.subprocess,'run',side_effect=AssertionError('run launched')), patch.object(module.subprocess,'check_output',side_effect=AssertionError('check_output launched')), patch.object(pathlib.Path,'mkdir',side_effect=AssertionError('directory created')), patch.object(module.tempfile,'mkdtemp',side_effect=AssertionError('sandbox created')), contextlib.redirect_stderr(stderr):
            try: module.main(['--godot',str(directory/'missing-engine'),'--output',str(output)])
            except SystemExit as exc: assert exc.code==2
            else: raise AssertionError('host did not refuse')
        assert marker.read_bytes()==b'valuable existing output/player sentinel'
        assert sorted(p.name for p in output.iterdir())==['campaign.json']
        results.append({'name':'refusal before all effects','mocked_host':host,'pass':True,'stderr':stderr.getvalue()})
    for failure in ['timeout','zero-exit-script-error']:
        case_output=directory/failure
        sandbox=directory/(failure+'-sandbox')
        sandbox.mkdir()
        def command_output(command,**kwargs):
            if command[:2]==['git','ls-files']: return b''
            return 'mock identity\n'
        process=subprocess.CompletedProcess([],0,b'',b'SCRIPT ERROR: independent injected diagnostic\n')
        def simulate(*args,**kwargs):
            if failure=='timeout': raise subprocess.TimeoutExpired(args[0],90,output=b'partial',stderr=b'partial stderr')
            return process
        with patch.object(module.platform,'system',return_value='Linux'), patch.object(module.tempfile,'mkdtemp',return_value=str(sandbox)), patch.object(module,'sha',return_value='mock hash'), patch.object(module.subprocess,'check_output',side_effect=command_output), patch.object(module.subprocess,'run',side_effect=simulate), contextlib.redirect_stdout(io.StringIO()):
            code=module.main(['--godot',str(directory/'mock-engine'),'--output',str(case_output)])
        report=json.loads((case_output/'results.json').read_text())
        assert code==1 and report['passed']==0 and report['total']==18 and not report['all_passed']
        assert all(r['exit_code']=='timeout' for r in report['results']) if failure=='timeout' else all(r['diagnostics'] for r in report['results'])
        results.append({'name':failure+' fails closed for 18 fixtures','pass':True})
(OUT/'supplemental-results.json').write_text(json.dumps({'mocked_only':True,'results':results,'passed':len(results),'total':len(results)},indent=2)+'\n')
print(f'{len(results)}/{len(results)} independent supplemental probes passed')
