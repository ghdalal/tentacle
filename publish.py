import os
import sys
import glob
import subprocess
import hashlib
import json
from datetime import datetime

# --- CONFIGURATION ---
# Replace with your actual IDs from your Apps Script Deployment
SHEET_ID = '1eUlaAeK1Uq-7v_qRLIlsFU4HphGmG2hd_JVdtl78lGI'
PARENT_DRIVE_FOLDER_ID = 'YOUR_DRIVE_FOLDER_ID'
WEB_APP_URL = 'https://script.google.com/macros/s/AKfycbzndE6qGfXdZYGHNMOGOGA3DXf8657i2b7K9ILnhfohE39nL2XW1hXVo9wbqN9Qedon/execRL'

# Force immediate terminal feedback
sys.stdout.reconfigure(line_buffering=True)

try:
    import git
    from google.oauth2.credentials import Credentials
    from googleapiclient.discovery import build
except ImportError:
    print("❌ Missing libraries. Run: pip install GitPython google-api-python-client")
    sys.exit(1)

class TentacleOrchestrator:
    def __init__(self, scope):
        self.scope = scope
        self.repo = git.Repo(search_parent_directories=True)
        self.commit_hash = self.repo.head.object.hexsha[:7]
        self.timestamp = datetime.now().strftime('%Y%m%d')
        
    def guard(self):
        print("🔍 [Guard] Validating Git Environment...")
        if self.repo.is_dirty():
            print("❌ ERROR: Git tree is dirty. Commit your changes first.")
            sys.exit(1)
        if not self.repo.active_branch.name.startswith('print/'):
            print(f"❌ ERROR: Invalid branch '{self.repo.active_branch.name}'. Use 'print/...'")
            sys.exit(1)
        print(f"✅ [Guard] Environment Secure. Commit: {self.commit_hash}")

    def select_variant(self):
        # Search for .scad files recursively in src/
        files = glob.glob("src/**/*.scad", recursive=True)
        if not files:
            print("❌ ERROR: No .scad files found in src/")
            sys.exit(1)
        
        if len(files) == 1:
            return files[0]
        
        print("\n📦 Multiple Variants Detected:")
        for i, f in enumerate(files):
            print(f"  [{i}] {f}")
        
        choice = int(input("\n👉 Select variant index to publish: "))
        return files[choice]

    def build(self, scad_path):
        output_dir = f"output/prints/{self.timestamp}_{self.commit_hash}_{self.scope}"
        os.makedirs(output_dir, exist_ok=True)
        
        print(f"🔨 [Build:{self.scope.upper()}] Initializing OpenSCAD...")

      
            # 4-file Audit for ALL BUILDs: 2 views (ISO, SIDE) x 2 modes (Preview, Render)
        views = {"iso": "--camera=0,0,0,65,0,35,500", "side": "--camera=0,0,0,0,0,0,500"}
        for mode in ["preview", "render"]:
            for view, cam in views.items():
                fname = f"{mode}_{view}.png"
                self._render(scad_path, os.path.join(output_dir, fname), cam, mode == "preview")
        
        if self.scope == "physical":
            # 7-angle Audit for Mobile Evidence
            angles = {
                "01_iso": "--camera=0,0,0,65,0,35,500", "02_top": "--camera=0,0,0,0,0,0,500",
                "03_front": "--camera=0,0,0,90,0,0,500", "04_back": "--camera=0,0,0,90,0,180,500",
                "05_left": "--camera=0,0,0,90,0,90,500", "06_right": "--camera=0,0,0,90,0,270,500",
                "07_bottom": "--camera=0,0,0,180,0,0,500"
            }
            for name, cam in angles.items():
                self._render(scad_path, os.path.join(output_dir, f"{name}.png"), cam)

        # Always generate STL
        print("  🧊 Exporting model.stl...")
        subprocess.run(["openscad", "-o", os.path.join(output_dir, "model.stl"), scad_path], check=True)
        return output_dir

    def _render(self, scad, out, cam, is_preview=False):
        cmd = ["openscad", "-o", out, cam, "--imgsize=1200,1200"]
        if is_preview: cmd.append("--preview")
        print(f"  📸 {os.path.basename(out)}")
        subprocess.run(cmd + [scad], check=True, capture_output=True)

    def finalize(self, rev_id):
        evidence_url = f"{WEB_APP_URL}?rev={rev_id}&scope={self.scope}"
        print("\n" + "="*60)
        print(f"🚀 PUBLISHED: {rev_id}")
        print("="*60)
        if self.scope == "physical":
            print(f"📱 PHYSICAL EVIDENCE REQUIRED ON MOBILE:")
            print(f"👉 {evidence_url}")
        else:
            print(f"✅ PROTOTYPE LOGGED. Review Drive for renders.")
        print("="*60 + "\n")

def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--scope", choices=["prototype", "physical"], required=True)
    args = parser.parse_args()

    print(f"🚀 TENTACLE-REL-001 | Scope: {args.scope.upper()}")
    
    orch = TentacleOrchestrator(args.scope)
    orch.guard()
    target_scad = orch.select_variant()
    out_path = orch.build(target_scad)
    
    # Placeholder for the actual CloudSync logic
    # rev_id = CloudSync.upload(out_path)
    orch.finalize("r01_demo") # Replace with actual revision logic

if __name__ == "__main__":
    main()