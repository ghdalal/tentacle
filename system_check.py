import sys
import subprocess
import os

# Force immediate output
sys.stdout.reconfigure(line_buffering=True)

def run_command(name, cmd):
    print(f"Testing {name}...", end=" ", flush=True)
    try:
        # Run with a 5-second timeout
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True, timeout=5)
        print("✅ PASS")
    except subprocess.TimeoutExpired:
        print("❌ FAILED (Timed out - It's hanging!)")
    except Exception as e:
        print(f"❌ FAILED ({str(e)})")

print("--- TENTACLE-REL-001 SYSTEM CHECK ---")

# 1. Test GIT
# Is Git installed and callable from Python?
run_command("Git", ["git", "--version"])

# 2. Test OPENSCAD
# Is OpenSCAD in your path?
run_command("OpenSCAD", ["openscad", "--version"])

# 3. Test GOOGLE DRIVE
# Can we connect using your saved token?
print("Testing Google Drive...", end=" ", flush=True)
try:
    from google.oauth2.credentials import Credentials
    from googleapiclient.discovery import build
    
    if not os.path.exists('token.json'):
        print("❌ FAILED (Missing token.json)")
    else:
        creds = Credentials.from_authorized_user_file('token.json')
        service = build('drive', 'v3', credentials=creds)
        
        # Try a tiny read operation
        results = service.files().list(pageSize=1, fields="nextPageToken, files(id, name)").execute()
        files = results.get('files', [])
        
        if not files:
            print("✅ PASS (Connected, but Drive is empty)")
        else:
            print(f"✅ PASS (Found file: {files[0]['name']})")
except Exception as e:
    print(f"❌ FAILED ({str(e)})")

print("--- END OF CHECK ---")