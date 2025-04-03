import json
import os
from flask import Flask, Response, request
from google.cloud import firestore

# Initialize Firestore client
db = firestore.Client()

# Firestore collection name
collection_name = "candidates"

# Initialize Flask application
candidates_app = Flask(__name__)

# Get instance ID from hostname
instance_id = os.popen("hostname -I").read().strip()

# Default route: Invalid request handler
@candidates_app.route("/", methods=["GET"])
def default():
    """
    Returns an error response for invalid requests.
    """
    return Response(json.dumps({"status": "invalid request"}), status=400, mimetype="application/json")

# Health check route: Good-to-go (gtg)
@candidates_app.route("/gtg", methods=["GET"])
def gtg():
    """
    Health check endpoint.
    Returns instance ID details if requested, otherwise just a 200 status.
    """
    details = request.args.get("details")

    if "details" in request.args:
        return Response(json.dumps({"connected": "true", "hostname": instance_id}), status=200, mimetype="application/json")
    else:
        return Response("{}", status=200, mimetype="application/json")

# Retrieve candidate by name
@candidates_app.route("/candidate/<name>", methods=["GET"])
def get_candidate(name):
    """
    Retrieves a candidate document from Firestore by name.
    Returns the candidate data if found, otherwise 404.
    """
    try:
        doc_ref = db.collection(collection_name).document(name)
        doc = doc_ref.get()

        if doc.exists:
            return Response(json.dumps(doc.to_dict()), status=200, mimetype="application/json")
        else:
            return Response(json.dumps({"error": "Not Found"}), status=404, mimetype="application/json")
    except Exception as e:
        return Response(json.dumps({"error": "Not Found"}), status=404, mimetype="application/json")

# Create or update a candidate record
@candidates_app.route("/candidate/<name>", methods=["POST"])
def post_candidate(name):
    """
    Creates or updates a candidate document in Firestore.
    Returns the created/updated candidate data.
    """
    try:
        doc_id = name
        data = {"CandidateName": name}
        doc_ref = db.collection(collection_name).document(doc_id)
        doc_ref.set(data)
        return Response(json.dumps(data), status=200, mimetype="application/json")
    except Exception as e:
        return Response(json.dumps({"error": "Not Found"}), status=404, mimetype="application/json")

# Retrieve all candidates
@candidates_app.route("/candidates", methods=["GET"])
def get_candidates():
    """
    Retrieves all candidate documents from Firestore.
    Returns a JSON list of all candidates.
    """
    try:
        names_array = []
        docs = db.collection(collection_name).stream()

        for doc in docs:
            names_array.append(doc.to_dict())

        return Response(json.dumps(names_array), status=200, mimetype="application/json")
    except Exception as e:
        return Response(json.dumps({"error": "Not Found"}), status=404, mimetype="application/json")
