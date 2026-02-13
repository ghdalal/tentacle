import os
import sys
import argparse
import subprocess
import json
import zipfile
import hashlib
import time
import re
from datetime import datetime, timezone
from pathlib import Path

# Google Client Library Imports
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

# --- CONFIGURATION ---
# Extracted from your provided URLs
SPREADSHEET_ID = '1eUlaAeK1Uq-7v_qRLIlsFU4HphGmG2hd_JVdtl78lGI'
PRINTS_ROOT_FOLDER_ID = '1eq0sUx1rX4Xk9Mjh12D6apsdK7ZViP1l'

# Placeholder for Component 2 (You will update this after deploying the GAS script)
GAS_WEB_APP_URL = 'https://script.google.com/macros/s/AKfycbzndE6qGfXdZYGHNMOGOGA3DXf8657i2b7K9ILnhfohE39nL2XW1hXVo9wbqN9Qedon/exec_URL_HERE' 

SCOPES = [
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/spreadsheets.readonly'
]

# TENTACLE-REL-001: Hard-coded deterministic camera angles
CAMERAS = {
    "system":    [0, 0, 0, 60, 0, 45, 500],
    "technical": [0, 0, 0, 0, 0, 0, 200], # Top-down technical view
    "front":     [0, 0, 0, 90, 0, 0, 300],
    "side":      [0, 0, 0, 90, 0, 90, 300]
}

class EnvironmentGuard:
    @staticmethod
    def validate_git_state():
        """Ensures clean git state and strictly enforces 'print' branch rules."""
        print("🔍 [Guard] Validating Git Environment...")
        
        # 1. Check Branch Name (Must start with 'print/')
        try:
            branch = subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"]).decode().strip()
        except subprocess.CalledProcessError:
            print("❌ [Guard] Error: Not a git repository.")
            sys.exit(1)

        if not (branch.startswith("print/")):
            print(f"❌ [Guard] Violation: Current branch is '{branch}'.")
            print("   Rule: Publication is only permitted from branches starting with 'print/'.")
            sys.exit(1)
            
        # 2. Check Cleanliness (No uncommitted changes)
        status = subprocess.check_output(["git", "status", "--porcelain"]).decode().strip()
        if status:
            print("❌ [Guard] Violation: Working directory is dirty.")
            print(status)
            print("   Action: Commit or stash changes before publishing.")
            sys.exit(1)
            
        # 3. Get Commit Hash
        commit = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()
        print(f"✅ [Guard] Environment Secure. Branch: {branch}, Commit: {commit[:7]}")
        return commit, branch

    @staticmethod
    def get_git_logs():
        """Harvests logs from 'src/' for Gemini synthesis."""
        try:
            last_tag = subprocess.check_output(["git", "describe", "--tags", "--abbrev=0"]).decode().strip()
            log_range = f"{last_tag}..HEAD"
        except subprocess.CalledProcessError:
            log_range = "HEAD" # Fallback if no tags exist
            
        # Get logs only for the src directory
        logs = subprocess.check_output(
            ["git", "log", "--pretty=format:%s", log_range, "--", "src/"]
        ).decode().strip()
        return logs

class RevisionManager:
    def __init__(self, service_sheets):
        self.sheets = service_sheets
        self.local_counter_path = Path("counter.txt")

    def get_next_revision_id(self, scope):
        """
        Implements TENTACLE-REL-001 Monotonic ID Allocation.
        Syncs local counter with Cloud Ledger to prevent collisions.
        """
        print("🔢 [RevMgr] Allocating Revision ID...")

        # 1. Read Local Counter
        if not self.local_counter_path.exists():
            local_r = 0
        else:
            try:
                local_r = int(self.local_counter_path.read_text().strip())
            except ValueError:
                local_r = 0

        # 2. Read Cloud Ledger (Column A of 'revisions' tab)
        try:
            result = self.sheets.spreadsheets().values().get(
                spreadsheetId=SPREADSHEET_ID, range="revisions!A2:A"
            ).execute()
            values = result.get('values', [])
        except Exception as e:
            print(f"❌ [RevMgr] Error connecting to Ledger: {e}")
            sys.exit(1)
        
        max_cloud_r = 0
        for row in values:
            if not row: continue
            rid = row[0]
            # Regex to extract rNN number from 'print-YYYYMMDD-rNN-scope'
            match = re.search(r'-r(\d+)-', rid)
            if match:
                max_cloud_r = max(max_cloud_r, int(match.group(1)))

        # 3. Determine Next rNN (High Water Mark)
        next_r = max(local_r, max_cloud_r) + 1
        
        # 4. Update Local Counter
        self.local_counter_path.write_text(str(next_r))
        
        # 5. Format ID
        date_str = datetime.now(timezone.utc).strftime("%Y%m%d")
        rid = f"print-{date_str}-r{next_r:02d}-{scope}"
        print(f"✅ [RevMgr] Allocated ID: {rid}")
        return rid, next_r

class ArtifactBuilder:
    def __init__(self, revision_id, output_dir):
        self.rid = revision_id
        self.out = Path(output_dir)
        self.out.mkdir(parents=True, exist_ok=True)

    def run_openscad(self, generate_models=True):
        """Generates Renders and Models using OpenSCAD CLI."""
        print("🔨 [Build] Running OpenSCAD...")
        
        # Find the entry point .scad file (looking in src/common or src/s33 based on your files)
        # Update this path if your main entry point is different
        scad_files = list(Path("src").rglob("*.scad"))
        if not scad_files:
             print("❌ [Build] Error: No .scad files found in src/.")
             sys.exit(1)
        # Just taking the first one found or specific one. Adjust as needed.
        scad_file = scad_files[0] 
        print(f"   ℹ️ Using source: {scad_file}")

        # 1. Renders (Required for ALL scopes per TENTACLE-REL-001)
        for name, params in CAMERAS.items():
            cam_str = ",".join(map(str, params))
            out_png = self.out / f"{name}.png"
            
            # Using --imgsize=1920,1080 and hardcoded camera params
            cmd = [
                "openscad", "-o", str(out_png),
                "--imgsize=1920,1080",
                f"--camera={cam_str}",
                "--colorscheme=DeepOcean", # Or your preferred scheme
                str(scad_file)
            ]
            print(f"   📸 Rendering {name}...")
            subprocess.run(cmd, check=True)

        # 2. Models (Skip for prototype)
        if generate_models:
            print("   📦 Exporting STL...")
            subprocess.run([
                "openscad", "-o", str(self.out / "model.stl"),
                str(scad_file)
            ], check=True)
            
            # Note: OpenSCAD can export 3MF but features vary. 
            # If 3MF is strict requirement, verify OpenSCAD version supports it or use external converter.
            # Adding command for 3MF export:
            print("   📦 Exporting 3MF...")
            subprocess.run([
                "openscad", "-o", str(self.out / "slicer.3mf"),
                str(scad_file)
            ], check=True)

    def archive_source(self):
        """Zips src/ directory preserving internal folder structure."""
        print("🗜️ [Build] Archiving Source...")
        zip_path = self.out / "source.zip"
        
        # Exclude these patterns
        excludes = ['.git', 'output', '__pycache__', '.DS_Store']
        
        with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
            for root, dirs, files in os.walk("src"):
                # Modify dirs in-place to skip excluded directories
                dirs[:] = [d for d in dirs if d not in excludes]
                
                for file in files:
                    if file in excludes: continue
                    file_path = Path(root) / file
                    # Provide the full path inside the zip (preserving src/...)
                    zf.write(file_path, file_path)
        return zip_path

    def calculate_hashes(self):
        """Generates SHA256 hashes for validation."""
        hashes = {}
        for fname in ["model.stl", "source.zip", "slicer.3mf"]:
            fpath = self.out / fname
            if fpath.exists():
                sha = hashlib.sha256()
                with open(fpath, "rb") as f:
                    while chunk := f.read(4096):
                        sha.update(chunk)
                hashes[fname] = sha.hexdigest()
        return hashes

class CloudSync:
    def __init__(self, service_drive):
        self.drive = service_drive

    def upload_folder(self, local_path, parent_id):
        print(f"☁️ [Sync] Uploading to Drive (Parent ID: {parent_id})...")
        
        # 1. Create Revision Folder on Drive
        folder_meta = {
            'name': local_path.name,
            'mimeType': 'application/vnd.google-apps.folder',
            'parents': [parent_id]
        }
        folder = self.drive.files().create(body=folder_meta, fields='id').execute()
        folder_id = folder.get('id')

        # 2. Upload Artifacts (excluding complete.flag for now)
        files = [f for f in local_path.iterdir() if f.is_file() and f.name != 'complete.flag']
        
        for f in files:
            print(f"   ⬆️ {f.name}")
            media = MediaFileUpload(str(f), resumable=True)
            self.drive.files().create(
                body={'name': f.name, 'parents': [folder_id]},
                media_body=media
            ).execute()

        # 3. Write complete.flag LAST (The Freeze Signal)
        print("   🚩 Writing complete.flag...")
        flag_meta = {'name': 'complete.flag', 'parents': [folder_id]}
        self.drive.files().create(
            body=flag_meta, 
            media_body=MediaFileUpload(str(local_path / 'complete.flag'))
        ).execute()

        return folder_id

# --- MAIN EXECUTION ---
def main():
    parser = argparse.ArgumentParser(description="Tentacle Publisher (TENTACLE-REL-001)")
    parser.add_argument("--scope", choices=['prototype', 'physical', 'online', 'production'], required=True, help="Release scope")
    parser.add_argument("--desc", help="Manual description (overrides AI synthesis)", default=None)
    args = parser.parse_args()

    print("🚀 Starting TENTACLE-REL-001 Publication Sequence")

    # 1. Authenticate Google Services
    creds = None
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        with open('token.json', 'w') as token:
            token.write(creds.to_json())

    service_drive = build('drive', 'v3', credentials=creds)
    service_sheets = build('sheets', 'v4', credentials=creds)

    # 2. Phase 1: Guard & Initialization
    commit_hash, branch = EnvironmentGuard.validate_git_state()

    # 3. AI Narrative Synthesis (Phase 1.2)
    if args.desc:
        description = args.desc
    else:
        logs = EnvironmentGuard.get_git_logs