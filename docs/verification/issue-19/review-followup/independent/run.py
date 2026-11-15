import os,pathlib,subprocess,json,hashlib,tempfile,sys
base=pathlib.Path('/tmp/issue19-followup-independent'); project=base/'project'; engine='/opt/Godot/Godot_v4.8-beta3_linux.x86_64'
results=json.loads((base/'runtime-results.json').read_text()) if (base/'runtime-results.json').exists() else []
def run(name,args):
 storage=pathlib.Path(tempfile.mkdtemp(prefix=name+'-',dir=base))
 env=os.environ.copy(); isolated={f'XDG_{k.upper()}_HOME':str(storage/k) for k in ('data','config','cache')};env.update(isolated)
 cmd=[engine,*args]
 try:
  p=subprocess.run(cmd,cwd=project,env=env,capture_output=True,timeout=90); code=p.returncode;stdout=p.stdout;stderr=p.stderr
 except subprocess.TimeoutExpired as e:
  code='timeout';stdout=e.stdout or b'';stderr=e.stderr or b''
 for stream,data in [('stdout',stdout),('stderr',stderr)]: (base/(name+'.'+stream+'.log')).write_bytes(data)
 diag=[l for l in (stdout+stderr).decode(errors='replace').splitlines() if any(s in l for s in ('SCRIPT ERROR','Parse Error','FAIL:'))]
 r={'name':name,'command':cmd,'environment':isolated,'exit_code':code,'diagnostics':diag,'stdout_sha256':hashlib.sha256(stdout).hexdigest(),'stderr_sha256':hashlib.sha256(stderr).hexdigest(),'pass_lines':[l for l in stdout.decode(errors='replace').splitlines() if l.startswith('PASS:')]};results.append(r)
 (base/'runtime-results.json').write_text(json.dumps(results,indent=2)+'\n'); print(name,code,diag,flush=True)
 return code==0 and not diag
if sys.argv[1]=='import':
 assert run('engine-version',['--version'])
 assert run('editor-import-retry',['--headless','--editor','--path',str(project),'--import'])
else:
 for name in sys.argv[1:]:
  assert run(name,['--headless','--path',str(project),'--script','res://src/tests/scripts/'+name+'.gd'])
