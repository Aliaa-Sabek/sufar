from flask import Flask, request, jsonify, render_template
import os
from sufar_smart_travel_assistant_v2 import generate_plan_from_form

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

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
