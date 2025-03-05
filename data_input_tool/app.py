"""
Flask REST API for patient assessment management using Redis
This application provides endpoints for creating, reading, and managing patient assessments
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import redis
import os
from datetime import datetime
import time
import json  # Make sure this is at the top with other imports

# Initialize Flask application with CORS support
app = Flask(__name__)
CORS(app)

# Redis configuration
redis_host = os.getenv('REDIS_HOST', 'localhost')
redis_port = int(os.getenv('REDIS_PORT', 6379))
redis_client = redis.StrictRedis(
    host=redis_host, 
    port=redis_port, 
    decode_responses=True
)

# Helper functions
def validate_patient_exists(patient_id):
    """Check if a patient exists in the database"""
    if not redis_client.exists(patient_id):
        return False
    return True

def create_timestamp():
    """Generate both Unix and human-readable timestamps"""
    unix_ts = int(time.time())
    human_ts = datetime.fromtimestamp(unix_ts).strftime('%Y-%m-%d %H:%M:%S')
    return unix_ts, human_ts

# Route handlers
@app.route('/api', methods=['POST'])
def create():
    """
    Create a new patient record
    Required JSON payload: {"identifier": "patient_id"}
    Returns: Success message or error
    """
    data = request.json
    identifier = data.get('identifier')
    
    # Input validation
    if not identifier or not identifier.isalnum():
        return jsonify({'error': 'Invalid input'}), 400
    if redis_client.exists(identifier):
        return jsonify({'error': 'Patient with this ID already exists'}), 400

    redis_client.hset(identifier, mapping={'created': 'true'})
    return jsonify({'message': 'Patient created successfully'}), 201

# READ: to get the hashmap from Redis
@app.route('/api/<identifier>', methods=['GET'])
def get(identifier):
    hashmap = redis_client.hgetall(identifier)
    if hashmap:
        return jsonify(hashmap), 200
    return jsonify({'message': 'Hashmap not found'}), 404


# UPDATE: to update the hashmap in Redis
@app.route('/api/<patient_id>/<assessment_name>', methods=['POST'])
def save_assessment(patient_id, assessment_name):
    """Saves an assessment for a given patient."""
    if not validate_patient_exists(patient_id):
        return jsonify({'error': 'Patient ID does not exist'}), 404

    data = request.json
    if not data:
        return jsonify({'error': 'Invalid input'}), 400

    # Convert all values to strings, including nested dictionaries
    processed_data = {}
    for key, value in data.items():
        if isinstance(value, (dict, list)):
            processed_data[key] = json.dumps(value)
        else:
            processed_data[key] = str(value) if value is not None else ''

    unix_timestamp, human_readable = create_timestamp()
    key = f"{patient_id}:{assessment_name}:{unix_timestamp}:{human_readable}"
    
    redis_client.hset(key, mapping=processed_data)

    return jsonify({
        'message': 'Assessment saved successfully',
        'timestamp': human_readable,
        'unix_timestamp': unix_timestamp,
        'key': key
    }), 200

# READ: to get an assessment from Redis
@app.route('/api/<patient_id>/<assessment_name>', methods=['GET'])
def get_assessment(patient_id, assessment_name):
    """
Endpoint to retrieve an assessment for a given patient.

Args:
    patient_id (str): The ID of the patient.
    assessment_name (str): The name of the assessment to retrieve.

Returns:
    Response: A JSON response containing the assessment data if found, 
              or an error message if the patient ID does not exist or the assessment is not found.
              - 200: Assessment data found and returned.
              - 404: Patient ID does not exist or assessment not found.
"""
    # Check if the patient ID exists
    if not redis_client.exists(patient_id):
        return jsonify({'error': 'Patient ID does not exist or might need to be created'}), 404

    assessment = redis_client.hgetall(f"{patient_id}:{assessment_name}")
    if assessment:
        return jsonify(assessment), 200
    return jsonify({'message': 'Assessment not found'}), 404

# READ: to get all assessments for a given patient from Redis
@app.route('/api/<patient_id>/assessments', methods=['GET'])
def get_assessments(patient_id):
    """
Retrieve assessments for a given patient.
This endpoint retrieves all assessments for a specified patient ID from the Redis database.
The assessments are sorted by timestamp in descending order.
Args:
    patient_id (str): The ID of the patient whose assessments are to be retrieved.
Returns:
    Response: A JSON response containing the assessments if found, or an error message if the patient ID does not exist or no assessments are found.
"""
    if not validate_patient_exists(patient_id):
        return jsonify({'error': 'Patient ID does not exist'}), 404

    keys = redis_client.keys(f"{patient_id}:*")
    assessments = {}
    
    # Sort keys by timestamp in descending order
    sorted_keys = sorted(
        keys, 
        key=lambda x: x.split(':')[-1] if len(x.split(':')) > 2 else '', 
        reverse=True
    )
    
    for key in sorted_keys:
        if data := redis_client.hgetall(key):
            assessments[key] = data
            
    return (jsonify(assessments), 200) if assessments else (
        jsonify({'message': 'No assessments found'}), 404
    )

# READ: to get all data associated with a given ID from Redis
@app.route('/api/<identifier>/all', methods=['GET'])
def get_all_data(identifier):
    """
Endpoint to retrieve all data associated with a given identifier.
Args:
    identifier (str): The unique identifier for the patient.
Returns:
    Response: A JSON response containing all data associated with the identifier.
              If the identifier does not exist, returns a 404 error with a message.
              If no data is found for the identifier, returns a 404 error with a message.
              If data is found, returns a 200 status with the data.
The data is retrieved from a Redis database. Each key associated with the identifier
is checked for timestamp information. If timestamp information is present, it is included
in the response along with the data.
"""
    # Check if the patient ID exists
    if not redis_client.exists(identifier):
        return jsonify({'error': 'Patient ID does not exist or might need to be created'}), 404

    keys = redis_client.keys(f"{identifier}:*")
    all_data = {}
    for key in keys:
        data = redis_client.hgetall(key)
        key_parts = key.split(':')
        if len(key_parts) >= 4:  # If key contains timestamp information
            unix_timestamp = key_parts[2]
            human_timestamp = key_parts[3]
            all_data[key] = {
                'data': data,
                'timestamp': human_timestamp,
                'unix_timestamp': unix_timestamp
            }
        else:
            all_data[key] = data
            
    if all_data:
        return jsonify(all_data), 200
    return jsonify({'message': 'No data found for this ID'}), 404

@app.route('/api/<patient_id>/barthel/latest', methods=['GET'])
def get_latest_barthel(patient_id):
    """
Retrieve the latest Barthel assessment for a given patient.
Args:
    patient_id (str): The ID of the patient.
Returns:
    Response: A JSON response containing the latest Barthel assessment data, 
              including the timestamp, unix timestamp, assessment data, and key.
              If the patient does not exist, returns a 404 error with a message.
              If no assessments are found, returns a 404 error with a message.
              If the latest assessment is empty, returns a 404 error with a message.
              If an error occurs during retrieval, returns a 500 error with details.
"""
    if not validate_patient_exists(patient_id):
        return jsonify({'error': 'Patient not found'}), 404

    pattern = f"{patient_id}:Barthel Index:*"
    assessment_keys = redis_client.keys(pattern)
    
    if not assessment_keys:
        return jsonify({'message': 'No Barthel assessments found'}), 404

    try:
        # Get the latest assessment based on timestamp
        latest_key = max(
            assessment_keys,
            key=lambda k: int(k.split(':')[2]) if len(k.split(':')) > 2 else 0
        )
        
        if not (assessment_data := redis_client.hgetall(latest_key)):
            return jsonify({'message': 'Latest assessment is empty'}), 404

        # Parse timestamps from key more safely
        key_parts = latest_key.split(':')
        # Default values
        unix_timestamp = "0"
        human_readable = "Unknown"
        
        # Extract timestamps if they exist in the key
        if len(key_parts) >= 4:  # Ensure we have enough parts
            unix_timestamp = key_parts[2]
            human_readable = ':'.join(key_parts[3:])  # Join remaining parts in case timestamp contains colons
        
        return jsonify({
            'timestamp': human_readable,
            'unix_timestamp': int(unix_timestamp),
            'data': assessment_data,
            'key': latest_key
        }), 200

    except Exception as e:
        print(f"Error retrieving latest Barthel assessment: {e}")
        return jsonify({
            'error': 'Failed to retrieve latest assessment',
            'details': str(e)
        }), 500

# Update get_assessment to parse JSON strings back to dictionaries
@app.route('/api/<patient_id>/<assessment_name>/latest', methods=['GET'])
def get_latest_assessment(patient_id, assessment_name):
    """Retrieve the latest assessment for a given patient."""
    if not validate_patient_exists(patient_id):
        return jsonify({'error': 'Patient not found'}), 404

    pattern = f"{patient_id}:{assessment_name}:*"
    assessment_keys = redis_client.keys(pattern)
    
    if not assessment_keys:
        return jsonify({'message': f'No {assessment_name} assessments found'}), 404

    try:
        latest_key = max(
            assessment_keys,
            key=lambda k: int(k.split(':')[2]) if len(k.split(':')) > 2 else 0
        )
        
        raw_data = redis_client.hgetall(latest_key)
        if not raw_data:
            return jsonify({'message': 'Latest assessment is empty'}), 404

        # Parse any JSON strings back to dictionaries
        processed_data = {}
        for key, value in raw_data.items():
            try:
                processed_data[key] = json.loads(value)
            except (json.JSONDecodeError, TypeError):
                processed_data[key] = value

        key_parts = latest_key.split(':')
        if len(key_parts) >= 4:
            unix_timestamp = key_parts[2]
            human_readable = ':'.join(key_parts[3:])
        else:
            unix_timestamp = "0"
            human_readable = "Unknown"
        
        return jsonify({
            'timestamp': human_readable,
            'unix_timestamp': int(unix_timestamp),
            'data': processed_data,
            'key': latest_key
        }), 200

    except Exception as e:
        print(f"Error retrieving latest {assessment_name} assessment: {e}")
        return jsonify({
            'error': f'Failed to retrieve latest {assessment_name} assessment',
            'details': str(e)
        }), 500

@app.route('/api/<patient_id>/moca5min/latest', methods=['GET'])
def get_latest_moca5min(patient_id):
    """
    Retrieve the latest MoCA 5min assessment for a given patient.
    Args:
        patient_id (str): The ID of the patient.
    Returns:
        Response: A JSON response containing the latest MoCA 5min assessment data,
                  including the timestamp, unix timestamp, assessment data, and key.
                  If the patient does not exist, returns a 404 error with a message.
                  If no assessments are found, returns a 404 error with a message.
                  If the latest assessment is empty, returns a 404 error with a message.
                  If an error occurs during retrieval, returns a 500 error with details.
    """
    if not validate_patient_exists(patient_id):
        return jsonify({'error': 'Patient not found'}), 404

    pattern = f"{patient_id}:MoCA 5min:*"
    assessment_keys = redis_client.keys(pattern)
    
    if not assessment_keys:
        return jsonify({'message': 'No MoCA 5min assessments found'}), 404

    try:
        # Get the latest assessment based on timestamp
        latest_key = max(
            assessment_keys,
            key=lambda k: int(k.split(':')[2]) if len(k.split(':')) > 2 else 0
        )
        
        if not (assessment_data := redis_client.hgetall(latest_key)):
            return jsonify({'message': 'Latest assessment is empty'}), 404

        # Parse timestamps from key more safely
        key_parts = latest_key.split(':')
        unix_timestamp = "0"
        human_readable = "Unknown"
        
        if len(key_parts) >= 4:
            unix_timestamp = key_parts[2]
            human_readable = ':'.join(key_parts[3:])
        
        return jsonify({
            'timestamp': human_readable,
            'unix_timestamp': int(unix_timestamp),
            'data': assessment_data,
            'key': latest_key
        }), 200

    except Exception as e:
        print(f"Error retrieving latest MoCA 5min assessment: {e}")
        return jsonify({
            'error': 'Failed to retrieve latest assessment',
            'details': str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)