import hashlib,json,os,pathlib,platform,subprocess,tempfile
root=pathlib.Path.cwd(); out=pathlib.Path('/tmp/path-light-19-independent-final'); engine='/opt/Godot/Godot_v4.8-beta3_linux.x86_64'
results=[]
cases=[('supplemental-boundaries','/tmp/path-light-19-independent-final/reviewer_final_boundaries.gd',[]),('original-pause','/tmp/path-light-19-independent/reviewer_navigation.gd',['pause']),('original-completion','/tmp/path-light-19-independent/reviewer_navigation.gd',['completion']),('corrected-navigation','res://src/tests/scripts/map_navigation_integration.gd',[])]
for name,script,args in cases:
    storage=pathlib.Path(tempfile.mkdtemp(prefix='review19-final-')); env=os.environ.copy(); overrides={f'XDG_{k.upper()}_HOME':str(storage/k) for k in ('data','config','cache')}; env.update(overrides)
    cmd=[engine,'--headless','--path',str(root),'--script',script]+(['--',*args] if args else [])
    try:
        process=subprocess.run(cmd,env=env,capture_output=True,timeout=90); code=process.returncode; stdout=process.stdout; stderr=process.stderr
    except subprocess.TimeoutExpired as e:
        code='timeout'; stdout=e.stdout or b''; stderr=e.stderr or b''
    (out/f'{name}.stdout.log').write_bytes(stdout); (out/f'{name}.stderr.log').write_bytes(stderr)
    text=(stdout+stderr).decode(errors='replace'); diagnostics=[s for s in text.splitlines() if any(w in s for w in ('SCRIPT ERROR','Parse Error','FAIL:'))]
    result={'name':name,'command':cmd,'environment':overrides,'exit_code':code,'diagnostics':diagnostics,'pass_lines':[s for s in text.splitlines() if 'PASS:' in s],'stdout_sha256':hashlib.sha256(stdout).hexdigest(),'stderr_sha256':hashlib.sha256(stderr).hexdigest()}; results.append(result)
    (out/'focused-with-boundaries-results.json').write_text(json.dumps({'engine_sha256':hashlib.sha256(pathlib.Path(engine).read_bytes()).hexdigest(),'platform':platform.platform(),'results':results},indent=2)+'\n')
    print(name,code,diagnostics,flush=True)
