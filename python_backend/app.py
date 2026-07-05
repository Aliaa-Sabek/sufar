from flask import Flask, request, jsonify, render_template
import os
import json
from sufar_smart_travel_assistant_v2 import generate_plan_from_form

app = Flask(__name__)

# Load destination catalog from destination.json
def load_destination_catalog():
    """Load destination catalog from destination.json"""
    try:
        with open(os.path.join(os.path.dirname(__file__), 'destination.json'), 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading destination catalog: {e}")
        return []

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/api/destinations/catalog", methods=["GET"])
def get_destinations_catalog():
    """Get all destinations from backend catalog"""
    catalog = load_destination_catalog()
    return jsonify({
        "success": True,
        "data": catalog,
        "count": len(catalog)
    })

@app.route("/api/recommend", methods=["POST"])
def recommend():
    data = request.json
    destination = data.get("destination", "")
    budget_usd = data.get("budget", "")
    duration_days = data.get("duration", "")
    interests = data.get("interests", [])
    
    # Use language sent from frontend; fallback to auto-detect from destination
    language_mode = data.get("language", "")
    if not language_mode:
        if destination and any('\u0600' <= ch <= '\u06FF' for ch in destination):
            language_mode = "ar"
        else:
            language_mode = "en"
    
    result = generate_plan_from_form(
        destination=destination,
        budget_usd=budget_usd,
        duration_days=duration_days,
        selected_interests=interests,
        language_mode=language_mode
    )
    
    # Tell the frontend which language Python decided on
    result["language_mode"] = language_mode
    
    return jsonify(result)

if __name__ == "__main__":
    app.run(debug=True, port=5000)
