import os, sys, subprocess, qrcode, argparse, json
from datetime import datetime
from google.auth import default
from google.cloud import secretmanager
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

class TentacleOrchestrator:
    def __init__(self, scope, variant, project_id):
        self.scope = scope
        self.variant = variant
        self.project_id = project_id
        
        # Identity-Based Auth (No local token files)
        self.creds, _ = default()
        self.config = self.load_vault_config()
        
        # Construct Path: src\{variant}\main.scad
        self.scad_file = os.path.join("src", self.variant, "main.scad")
        
        self.drive = build('drive', 'v3', credentials=self.creds)
        self.sheets = build('sheets', 'v4', credentials=self.creds)

    def load_vault_config(self):
        client = secretmanager.SecretManagerServiceClient(credentials=self.creds)
        name = f"projects/{self.project_id}/secrets/tentacle-config/versions/latest"
        response = client.access_secret_version(request={"name": name})
        return json.loads(response.payload.data.decode("UTF-8"))

    def print_critical_vars(self, rev_id):
        print("\n--- CRITICAL VARIABLES ---")
        print(f"TIMESTAMP: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"REVISION : {rev_id}")
        print(f"SCOPE    : {self.scope.upper()}")
        print(f"VARIANT  : {self.variant}")
        print("--------------------------\n")

    def run_renders(self, rev_id):
        if not os.path.exists(self.scad_file):
            print(f"ERROR: Protocol violation. Source not found at {self.scad_file}")
            sys.exit(1)

        # Output Path: output\prints\{rev}_{scope}
        out_dir = os.path.join("output", "prints", f"{rev_id}_{self.scope}")
        if not os.path.exists(out_dir):
            os.makedirs(out_dir)
            
        os_cmd = self.config['OPENSCAD_PATH']
        
        # 1. Universal Bundle
        for name, params in self.config['UNIVERSAL_BUNDLE'].items():
            rot_x, rot_z, res, is_render = params
            mode = "--render" if is_render else "--preview"
            out_file = os.path.join(out_dir, f"{name}.png")
            subprocess.run(f'"{os_cmd}" -o "{out_file}" {mode} --camera=0,0,0,{rot_x},0,{rot_z},500 --imgsize={res},{res} "{self.scad_file}"', shell=True)

        # 2. Physical Scope Requirements
        if self.scope == "physical":
            stl_file = os.path.join(out_dir, f"{rev_id}.stl")
            subprocess.run(f'"{os_cmd}" -o "{stl_file}" --render "{self.scad_file}"', shell=True)
            
            for name, rot in self.config['AUDIT_ANGLES'].items():
                wire_file = os.path.join(out_dir, f"{name}_wire.png")
                subprocess.run(f'"{os_cmd}" -o "{wire_file}" --render --camera=0,0,0,{rot[0]},0,{rot[1]},500 --view=wireframe --colorscheme="Starlight" --imgsize=1200,1200 "{self.scad_file}"', shell=True)

        return self.upload_to_drive(out_dir, rev_id)

    def upload_to_drive(self, out_dir, rev_id):
        meta = {'name': rev_id, 'parents': [self.config['PARENT_DRIVE_FOLDER_ID']], 'mimeType': 'application/vnd.google-apps.folder'}
        folder = self.drive.files().create(body=meta, fields='id').execute()
        f_id = folder.get('id')
        for f in os.listdir(out_dir):
            file_path = os.path.join(out_dir, f)
            m = MediaFileUpload(file_path)
            self.drive.files().create(body={'name': f, 'parents': [f_id]}, media_body=m).execute()
        return f_id

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--scope", choices=["prototype", "physical"], required=True)
    parser.add_argument("--variant", required=True)
    parser.add_argument("--project", required=True)
    args = parser.parse_args()
    
    orch = TentacleOrchestrator(args.scope, args.variant, args.project)
    rev = orch.get_rev_id()
    orch.print_critical_vars(rev)
    pid = orch.run_renders(rev)
    
    url = f"{orch.config['WEB_APP_URL']}?rev={rev}&scope={args.scope}&pid={pid}"
    print(f"AUDIT PORTAL READY: {rev}")
    qr = qrcode.QRCode(); qr.add_data(url); qr.print_ascii()