import redis
import json
import time
from datetime import datetime, timedelta

# Connect to Redis
r = redis.Redis(
    host='localhost',
    port=6379,
    decode_responses=True
)

def populate_patient_data():
    patient_id = "UsabilityWorkshop"
    
    # Basic patient information
    patient_data = {
        "dx": "Hip Fracture",
        "tx": "ORIF",
        "adm_age": "85",
        "weight_preop": "52",
        "size_preop": "165", 
        "bmi_preop": "19.1",
        "birthday": "1939",
        "isolation": "0",
        "ops_name": "Osteosynthesis",
        "load": "Routine surgery"
    }
    
    # Set patient hash data
    r.hmset(patient_id, patient_data)
    
    # Add time series data for lab values
    now = int(time.time() * 1000)
    
    # Hemoglobin values over time
    hemoglobin_values = [12.5, 11.8, 10.9, 11.2, 11.8]
    for i, value in enumerate(hemoglobin_values):
        timestamp = now - (len(hemoglobin_values) - i - 1) * 24 * 60 * 60 * 1000
        r.execute_command('TS.ADD', f'{patient_id}:hemoglobin', timestamp, value)
    
    # Creatinine values
    creatinine_values = [85, 92, 110, 95, 88]
    for i, value in enumerate(creatinine_values):
        timestamp = now - (len(creatinine_values) - i - 1) * 24 * 60 * 60 * 1000
        r.execute_command('TS.ADD', f'{patient_id}:creatinin', timestamp, value)
    
    # eGFR values
    egfr_values = [69, 65, 58, 62, 67]
    for i, value in enumerate(egfr_values):
        timestamp = now - (len(egfr_values) - i - 1) * 24 * 60 * 60 * 1000
        r.execute_command('TS.ADD', f'{patient_id}:egfr', timestamp, value)

def populate_medication_data():
    # Create search index for medications
    try:
        r.execute_command(
            'FT.CREATE', 'medis_index',
            'ON', 'HASH',
            'PREFIX', '1', 'medication:',
            'SCHEMA',
            'patient', 'TEXT',
            'slot', 'TEXT', 
            'position', 'NUMERIC',
            'name', 'TEXT'
        )
    except:
        pass  # Index might already exist
    
    # Add medication data
    medications = [
        {"name": "Lorazepam 1mg 0-0-1", "position": 1},
        {"name": "Johanniskraut Kps 100mg", "position": 2},
        {"name": "ASS 100mg", "position": 3},
        {"name": "Digitoxin 0,25mg 1-0-0", "position": 4},
        {"name": "Ramipril 5mg 1-0-0", "position": 5}
    ]
    
    for i, med in enumerate(medications):
        med_key = f"medication:{i+1}"
        r.hmset(med_key, {
            "patient": "UsabilityWorkshop",
            "slot": "latest",
            "position": med["position"],
            "name": med["name"]
        })

if __name__ == "__main__":
    print("Populating Redis with sample data...")
    populate_patient_data()
    populate_medication_data()
    print("Data population complete!")