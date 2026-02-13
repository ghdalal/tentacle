import os
import sys
import json
# Force unbuffered output
sys.stdout.reconfigure(line_buffering=True)

from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = [
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/spreadsheets.readonly'
]

def main():
    print("--- DIAGNOSTIC AUTH MODE (v2) ---")
    
    if not os.path.exists('credentials.json'):
        print("❌ ERROR: credentials.json is missing!")
        return

    print("✅ Found credentials.json. Initializing...")
    
    try:
        flow = InstalledAppFlow.from_client_secrets_file(
            'credentials.json', SCOPES)

        # CRITICAL CHANGE: We use run_local_server with open_browser=False
        # This forces it to print the URL to the console.
        print("\n👇 COPY THIS URL AND PASTE IT IN YOUR BROWSER 👇")
        print("="*60)
        
        creds = flow.run_local_server(
            port=0, 
            open_browser=False,
            prompt='consent' 
        )
        
        print("\n" + "="*60)
        print("✅ Authentication Successful!")
        
        # Save the token
        with open('token.json', 'w') as token:
            token.write(creds.to_json())
            
        print("💾 Saved token.json.")
        print("🎉 YOU ARE DONE! You can now run 'python publish.py' normally.")
        
    except Exception as e:
        print(f"\n❌ FATAL ERROR: {e}")

if __name__ == '__main__':
    main()