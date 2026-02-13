import os
import sys
import glob
import subprocess
import qrcode
from datetime import datetime
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

# --- CONFIGURATION ---
SHEET_ID = '1eUlaAeK1Uq-7v_qRLIlsFU4HphGmG2hd_JVdtl78lGI'
PARENT_DRIVE_FOLDER_ID = 'YOUR_DRIVE_FOLDER_ID' # <-- Update this!
WEB_APP_URL = 'YOUR_APPS_SCRIPT_WEBAPP_URL'   # <-- Update this!

sys.stdout.reconfigure(line_buffering=True)

class CloudSync:
    def __init__(self, creds):
        self.drive = build('drive', 'v3', credentials=creds)
        self.sheets = build('sheets', 'v4', credentials=creds)

    def get_next_revision(self):
        """Fetches the next rNN ID from the Ledger."""
        result = self.sheets.spreadsheets().values().get(
            spreadsheetId=SHEET_ID, range="A:A").execute()
        next_num = len(result.get('values', []))
        return f"r{next_num:02d}"

    def upload_artifacts(self, local_path, rev_id):
        """Creates a folder in Drive and uploads all PNGs and STL."""
        print(f"☁️ [Sync] Creating Drive folder for {rev_id}...")
        meta = {'name': rev_id, 'parents': [PARENT_DRIVE_FOLDER_ID], 'mimeType': 'application/vnd.google-apps.folder'}
        folder = self.drive.files().create(body=meta, fields='id').execute()
        folder_id = folder.get('id')

        for file in os.listdir(local_path):
            file_meta = {'name': file, 'parents': [folder_id]}
            media = MediaFileUpload(os.path.join(local_path, file))
            self.drive.files().create(body=file_meta, media_body=media).execute()
            print(f"  📤 Uploaded: {file}")
        return rev_id

class TentacleOrchestrator:
    def __init__(self, scope):
        self.scope = scope
        self.creds = Credentials.from_authorized_user_file('token.json')
        self.sync = CloudSync(self.creds)
        self.commit = subprocess.check_output(['git', 'rev-parse', '--short', 'HEAD']).decode().strip()

    def select_variant(self):
        files = glob.glob("src/**/*.scad", recursive=True)
        if len(files) == 1: return files[0]
        print("\n📦 Variants:"); [print(f" [{i}] {f}") for i, f in enumerate(files)]
        return files[int(input("\n👉 Select index: "))]

    def build(self, scad_path):
        out_dir = f"output/prints/{datetime.now().strftime('%Y%m%d')}_{self.commit}_{self.scope}"
        os.makedirs(out_dir, exist_ok=True)
        
        # Prototype (4 files) vs Physical (7 files)
        angles = {
            "prototype": {"preview_iso": "--camera=0,0,0,65,0,35,500 --preview", "render_iso": "--camera=0,0,0,65,0,35,500", 
                          "preview_top": "--camera=0,0,0,0,0,0,500 --preview", "render_top": "--camera=0,0,0,0,0,0,500"},
            "physical": {"01_iso": "--camera=0,0,0,65,0,35,500", "02_top": "--camera=0,0,0,0,0,0,500", 
                         "03_front": "--camera=0,0,0,90,0,0,500", "04_back": "--camera=0,0,0,90,0,180,500",
                         "05_left": "--camera=0,0,0,90,0,90,500", "06_right": "--camera=0,0,0,90,0,270,500",
                         "07_bottom": "--camera=0,0,0,180,0,0,500"}
        }[self.scope]

        for name, params in angles.items():
            print(f"  📸 Rendering {name}...")
            subprocess.run(f"openscad -o {out_dir}/{name}.png {params} --imgsize=1200,1200 {scad_path}", shell=True, check=True)
        
        subprocess.run(f"openscad -o {out_dir}/model.stl {scad_path}", shell=True, check=True)
        return out_dir

    def finalize(self, rev_id):
        url = f"{WEB_APP_URL}?rev={rev_id}&scope={self.scope}"
        print("\n" + "="*30 + "\n📸 SCAN FOR MOBILE AUDIT\n" + "="*30)
        qr = qrcode.QRCode(); qr.add_data(url); qr.print_ascii()
        print(f"👉 {url}\n" + "="*30)

def main():
    import argparse
    p = argparse.ArgumentParser(); p.add_argument("--scope", choices=["prototype", "physical"], required=True)
    args = p.parse_args()

    orch = TentacleOrchestrator(args.scope)
    target = orch.select_variant()
    path = orch.build(target)
    
    rev_id = orch.sync.get_next_revision()
    orch.sync.upload_artifacts(path, rev_id)
    orch.finalize(rev_id)

if __name__ == "__main__":
    main()