from pathlib import Path
import json,os,subprocess,tempfile,hashlib
root=Path.cwd();out=Path('/tmp/path-of-light-18-independent'); sandbox=Path(tempfile.mkdtemp(prefix='supplemental-',dir=out)); results=[]
for mode in ['real-stage-collisions','unreadable','direct-level2']:
 env=os.environ.copy(); env.update({f'XDG_{kind.upper()}_HOME':str(sandbox/mode/kind) for kind in ('data','config','cache')})
 if mode=='unreadable':
  path=sandbox/mode/'protected.json';path.parent.mkdir(parents=True);data={'schema_version':1,'completed_levels':[1],'recorded_secrets':[1]};path.write_text(json.dumps(data));Path(str(path)+'.bak').write_text(json.dumps(data));before=hashlib.sha256(path.read_bytes()).hexdigest();path.chmod(0);env['REVIEW_SAVE_PATH']=str(path)
 cmd=['/opt/Godot/Godot_v4.8-beta3_linux.x86_64','--headless','--path',str(root),'--script',str(out/'supplemental.gd'),'--','--'+mode]
 proc=subprocess.run(cmd,env=env,capture_output=True,timeout=40);(out/(mode+'.stdout.log')).write_bytes(proc.stdout);(out/(mode+'.stderr.log')).write_bytes(proc.stderr)
 if mode=='unreadable':
  path.chmod(0o600);assert hashlib.sha256(path.read_bytes()).hexdigest()==before
 diagnostics=[l for l in (proc.stdout+proc.stderr).decode().splitlines() if any(x in l for x in ('FAIL:','SCRIPT ERROR','Parse Error'))];results.append({'mode':mode,'command':cmd,'environment':{k:v for k,v in env.items() if k.startswith('XDG_') or k=='REVIEW_SAVE_PATH'},'exit_code':proc.returncode,'diagnostics':diagnostics});print(mode,proc.returncode,diagnostics);print(proc.stdout.decode())
(out/'supplemental-results.json').write_text(json.dumps(results,indent=2)+'\n')
