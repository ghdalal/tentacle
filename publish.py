import os
import sys
import glob
import subprocess
import qrcode
import argparse
from datetime import datetime
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

# --- USER CONFIGURATION ---
SHEET_ID = '1eUlaAeK1Uq-7v_qRLIlsFU4HphGmG2hd_JVdtl78lGI'
PARENT_DRIVE_FOLDER_ID = '1eq0sUx1rX4Xk9Mjh12D6apsdK7ZViP1l' 
WEB_APP_URL = 'https://script.google.com/macros/s/AKfycbzndE6qGfXdZYGHNMOGOGA3DXf8657i2b7K9ILnhfohE39nL2XW1hXVo9wbqN9Qedon/exec'
sys.stdout.reconfigure(line_buffering=True)

class TentacleOrchestrator:
    def __init__(self, scope):
        self.scope = scope
        self.creds = Credentials.from_authorized_user_file('token.json')
        self.drive = build('drive', 'v3', credentials=self.creds)
        self.sheets = build('sheets', 'v4', credentials=self.creds)
        self.commit = subprocess.check_output(['git', 'rev-parse', '--short', 'HEAD']).decode().strip()

    def select_variant(self):
        files = glob.glob("src/**/*.scad", recursive=True)
        if not files: print("❌ No .scad files in src/"); sys.exit(1)
        if len(files) == 1: return files[0]
        print("\n📦 Variants Detected:"); [print(f" [{i}] {f}") for i, f in enumerate(files)]
        return files[int(input("\n👉 Select variant index: "))]

    def get_rev_id(self):
        res = self.sheets.spreadsheets().values().get(spreadsheetId=SHEET_ID, range="A:A").execute()
        return f"r{len(res.get('values', [])):02d}"

    def build_and_upload(self, scad_path, rev_id):
        out_dir = f"output/prints/{datetime.now().strftime('%Y%m%d')}_{rev_id}_{self.scope}"
        os.makedirs(out_dir, exist_ok=True)
        
        # Define Angle Sets
        
        angles = {
            "preview_iso": "--camera=0,0,0,65,0,35,500 --preview", 
            "render_iso": "--camera=0,0,0,65,0,35,500",
            "preview_top": "--camera=0,0,0,0,0,0,500 --preview", 
            "render_top": "--camera=0,0,0,0,0,0,500"
        }
        if self.scope == "physical":
            angles = {
                "01_iso": "--camera=0,0,0,65,0,35,500", "02_top": "--camera=0,0,0,0,0,0,500",
                "03_front": "--camera=0,0,0,90,0,0,500", "04_back": "--camera=0,0,0,90,0,180,500",
                "05_left": "--camera=0,0,0,90,0,90,500", "06_right": "--camera=0,0,0,90,0,270,500",
                "07_bottom": "--camera=0,0,0,180,0,0,500"
            }

        # Render Images
        for name, params in angles.items():
            print(f"  📸 Rendering {name}...")
            subprocess.run(f"openscad -o {out_dir}/{name}.png {params} --imgsize=1200,1200 {scad_path}", shell=True, check=True)
        
        # Export STL
        subprocess.run(f"openscad -o {out_dir}/model.stl {scad_path}", shell=True, check=True)

        # Upload to Drive
        meta = {'name': rev_id, 'parents': [PARENT_DRIVE_FOLDER_ID], 'mimeType': 'application/vnd.google-apps.folder'}
        folder = self.drive.files().create(body=meta, fields='id', supportsAllDrives=True).execute()
        f_id = folder.get('id')

        for f in os.listdir(out_dir):
            m = MediaFileUpload(os.path.join(out_dir, f))
            self.drive.files().create(body={'name': f, 'parents': [f_id]}, media_body=m, supportsAllDrives=True).execute()
        return rev_id

    def finalize(self, rev_id):
        url = f"{WEB_APP_URL}?rev={rev_id}&scope={self.scope}&pid={PARENT_DRIVE_FOLDER_ID}"
        print("\n" + "="*30 + "\n📸 SCAN FOR MOBILE AUDIT\n" + "="*30)
        qr = qrcode.QRCode(); qr.add_data(url); qr.print_ascii()
        print(f"👉 {url}\n" + "="*30)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(); parser.add_argument("--scope", choices=["prototype", "physical"], required=True)
    args = parser.parse_args()
    orch = TentacleOrchestrator(args.scope)
    target = orch.select_variant()
    rev = orch.get_rev_id()
    orch.build_and_upload(target, rev)
    orch.finalize(rev)