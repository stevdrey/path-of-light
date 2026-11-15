"""Independent selected-candidate verification; never touches player storage."""
from pathlib import Path
import hashlib,json,os,platform,subprocess,tempfile,time
ROOT=Path(__file__).resolve().parents[4]
OUT=Path(__file__).resolve().parent/'final-checks'
OUT.mkdir(exist_ok=True)
assert platform.system()=='Linux'
ENGINE=Path('/opt/Godot/Godot_v4.8-beta3_linux.x86_64')
SANDBOX=Path(tempfile.mkdtemp(prefix='issue20-independent-final-'))
report={'engine':str(ENGINE),'engine_sha256':hashlib.sha256(ENGINE.read_bytes()).hexdigest(),'platform':platform.platform(),'sandbox':str(SANDBOX),'results':[]}
CASES=[('storage','campaign_storage_integration',[],None),('reward-policy-storage','campaign_rewards_integration',['--checks'],None),('reward-write','campaign_rewards_integration',['--write'],'reward-restart'),('reward-cold-restore','campaign_rewards_integration',['--verify'],'reward-restart'),('level-map','level_map_integration',[],'map-restart'),('level-map-cold-restore','level_map_integration',['--verify'],'map-restart'),('map-navigation','map_navigation_integration',[],None),('front-end-navigation','front_end_navigation_integration',[],None)]
for name,script,args,storage in CASES:
 env=os.environ.copy(); isolated={f'XDG_{kind.upper()}_HOME':str(SANDBOX/(storage or name)/kind) for kind in ['data','config','cache']};env.update(isolated)
 cmd=[str(ENGINE),'--headless','--path',str(ROOT),'--script',f'res://src/tests/scripts/{script}.gd']+(['--']+args if args else [])
 started=time.monotonic()
 try:
  p=subprocess.run(cmd,cwd=ROOT,env=env,capture_output=True,timeout=90);stdout,stderr,code=p.stdout,p.stderr,p.returncode
 except subprocess.TimeoutExpired as e:
  stdout,stderr,code=e.stdout or b'',e.stderr or b'','timeout'
 for stream,value in [('stdout',stdout),('stderr',stderr)]: (OUT/f'{name}.{stream}.log').write_bytes(value)
 combined=(stdout+stderr).decode(errors='replace');diagnostics=[line for line in combined.splitlines() if any(mark in line for mark in ['SCRIPT ERROR','Parse Error','FAIL:'])]
 report['results'].append({'name':name,'command':cmd,'environment':isolated,'exit_code':code,'diagnostics':diagnostics,'pass_lines':[l for l in combined.splitlines() if 'PASS:' in l],'seconds':round(time.monotonic()-started,3),'stdout_sha256':hashlib.sha256(stdout).hexdigest(),'stderr_sha256':hashlib.sha256(stderr).hexdigest()})
 (OUT/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(f'{name}: exit={code}, diagnostics={diagnostics}',flush=True)
report['passed']=sum(r['exit_code']==0 and not r['diagnostics'] for r in report['results']);report['total']=len(report['results']);report['all_passed']=report['passed']==report['total'];(OUT/'results.json').write_text(json.dumps(report,indent=2)+'\n')
raise SystemExit(0 if report['all_passed'] else 1)
