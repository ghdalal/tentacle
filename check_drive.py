# Save as check_drive.py
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('token.json')
service = build('drive', 'v3', credentials=creds)

FOLDER_ID = '1eq0sUx1rX4Xk9Mjh12D6apsdK7ZViP1l'

try:
    folder = service.files().get(fileId=FOLDER_ID, fields='name').execute()
    print(f"✅ Success! Connected to folder: {folder.get('name')}")
except Exception as e:
    print(f"❌ ERROR: {e}")