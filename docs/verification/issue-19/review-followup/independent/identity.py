import hashlib,json,pathlib,subprocess,sys
root=pathlib.Path('/home/stevdrey/Projects/Godot/Experiment 2D Platform/experiment-2d-platform')
out=pathlib.Path('/tmp/issue19-followup-independent')
expected=json.loads((root/'docs/verification/issue-19/review-followup/implementation/results.json').read_text())
paths=subprocess.check_output(['git','ls-files','-c','-o','--exclude-standard','-z'],cwd=root).decode().split('\0')
actual={p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in sorted(set(paths)) if p and (root/p).is_file() and not p.startswith('docs/verification/')}
digest=hashlib.sha256(json.dumps(actual,sort_keys=True,separators=(',',':')).encode()).hexdigest()
r={'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),'tree':subprocess.check_output(['git','rev-parse','HEAD^{tree}'],cwd=root,text=True).strip(),'files':len(actual),'manifest_sha256':digest,'expected_matches':actual==expected['source_files_sha256'],'manifest_expected_matches':digest=='5579900907d166220b8f011f753c27d3999235af24d5f344291adc51c15c9a2f','source_files_sha256':actual}
(out/('identity-'+sys.argv[1]+'.json')).write_text(json.dumps(r,indent=2)+'\n')
assert r['expected_matches'] and r['manifest_expected_matches']
print({k:v for k,v in r.items() if k!='source_files_sha256'})
if sys.argv[1]=='before':
 import shutil
 for p in actual:
  dest=out/'project'/p
  dest.parent.mkdir(parents=True,exist_ok=True)
  shutil.copy2(root/p,dest)
