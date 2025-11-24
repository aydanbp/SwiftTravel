import requests
from datetime import datetime, timezone
import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.base_query import FieldFilter

# --- CONFIGURATION ---
API_BASE_URL = "https://aydanbp.pythonanywhere.com"
LINES_TO_MONITOR = {
    "TFL": ["bakerloo", "central", "circle", "district", "elizabeth", "hammersmith-city", "jubilee", "metropolitan", 
            "northern", "piccadilly", "victoria", "waterloo-city", "liberty", "lioness", "mildmay", "Suffragette", 
            "weaver", "windrush"],
    "NR": ["SW", "GW", "XC", "VT", "CC", "CH", "EM", "LE", "HX", "GR", "SE", "AW", "SN", "CS", "ES", "TL"] 
}
FIRESTORE_COLLECTION = 'disruptions'

# --- INITIALIZE FIREBASE ---
try:
    cred = credentials.Certificate('swifttraveldisruptiondb-firebase-adminsdk-fbsvc-b8c0f7d23c.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("Firebase initialized successfully.")
except Exception as error:
    print(f"Error initializing Firebase: {error}")
    exit()

def returnNRnames(line_code):
    match line_code:
        case "SW":
            return "South Western Railway"
        case "GW":
            return "Great Western Railway"
        case "XC":
            return "CrossCountry Railway"
        case "VT":
            return "Avanti West Coast"
        case "CC":
            return "c2c"
        case "CH":
            return "Chiltern Railway"
        case "EM":
            return "East Midlands"
        case "LE":
            return "Greater Anglia"
        case "HX":
            return "Heathrow Express"
        case "GR":
            return "London North Eastern Railway | (LNER)"
        case "SE":
            return "Southeastern Railway"
        case "SN":
            return "Southern Rail"
        case "TL":
            return "Thameslink"
        case _:
            return ""


# CORE FUNCTIONS
def fetch_current_disruptions():
    all_current_disruptions = []

    # Fetch TFL disruptions
    for line_id in LINES_TO_MONITOR["TFL"]:
        try:
            response = requests.get(f"{API_BASE_URL}/disruption_api?type=T&id={line_id}", timeout=20)
            response.raise_for_status()
            disruptions = response.json()
            if disruptions:
                for disruption in disruptions:
                    status_type = disruption.get('statusType', '').lower()
                    if status_type != 'good service':
                        disruption['line_id'] = line_id
                        all_current_disruptions.append(disruption)
        except requests.RequestException as e:
            print(f"Could not fetch TFL disruptions for {line_id}: {e}")

    # Fetch National Rail disruptions
    for toc_id in LINES_TO_MONITOR["NR"]:
        try:
            response = requests.get(f"{API_BASE_URL}/disruption_api?type=N&id={toc_id}", timeout=20)
            response.raise_for_status()
            disruptions = response.json()
            if disruptions:
                 for disruption in disruptions:
                    status_type = disruption.get('statusType', '').lower()
                    if status_type != 'good service':
                        disruption['line_id'] = toc_id
                        all_current_disruptions.append(disruption)
        except requests.RequestException as e:
            print(f"Could not fetch NR disruptions for {toc_id}: {e}")

    return all_current_disruptions

def track_disruptions():
    print(f"[{datetime.now():%Y-%m-%d %H:%M:%S}] Starting disruption check...")
    
    current_api_disruptions = fetch_current_disruptions()
    
    active_api_set = {
        (d.get('source'), d.get('line_id'), d.get('description', '')) 
        for d in current_api_disruptions
    }

    try:
        active_docs_query = db.collection(FIRESTORE_COLLECTION).where(
            filter=FieldFilter('status', '==', 'active')
        ).stream()
        
        tracked_disruptions_map = {}
        for doc in active_docs_query:
            doc_data = doc.to_dict()
            key = (doc_data.get('source'), doc_data.get('line_id'), doc_data.get('description', ''))
            tracked_disruptions_map[key] = doc
            
    except Exception as e:
        print(f"Error querying Firestore: {e}")
        return

    # Find and log NEW disruptions
    for disruption in current_api_disruptions:
        key = (disruption.get('source'), disruption.get('line_id'), disruption.get('description', ''))
        if key not in tracked_disruptions_map:
            print(f"➡️  ⚠️ New disruption detected on {disruption.get('line_id') + returnNRnames(disruption.get('line_id'))} ({disruption.get('source')}): {disruption.get('description')}")
            db.collection(FIRESTORE_COLLECTION).add({
                "source": disruption.get('source'),
                "line_id": disruption.get('line_id'),
                "description": disruption.get('description'),
                "status_type": disruption.get('statusType'),
                "status": "active",
                "start_time": datetime.now(timezone.utc),
                "end_time": None,
                "duration_minutes": None
            })

    # Find and resolve OLD disruptions
    for key, doc in tracked_disruptions_map.items():
        if key not in active_api_set:
            doc_data = doc.to_dict()
            line_id = doc_data.get('line_id', 'N/A')
            source = doc_data.get('source', 'N/A')
            description = doc_data.get('description', 'No description')
            
            print(f"🟢 Disruption resolved on {line_id} ({source}): {description}")
            
            end_time = datetime.now(timezone.utc)
            start_time = doc_data.get('start_time')
            
            update_data = {"status": "resolved", "end_time": end_time}
            if start_time:
                duration = (end_time - start_time).total_seconds() / 60
                update_data["duration_minutes"] = round(duration)
            
            doc.reference.update(update_data)
            
    print(f"[{datetime.now():%Y-%m-%d %H:%M:%S}] Disruption check finished.")

# --- SCRIPT EXECUTION ---
if __name__ == '__main__':
    track_disruptions()