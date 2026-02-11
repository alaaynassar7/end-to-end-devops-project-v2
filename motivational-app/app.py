import os
from flask import Flask, render_template_string, request, jsonify
from pymongo import MongoClient

app = Flask(__name__)

# Fetch URI from Environment Secret
MONGO_URI = os.getenv("MONGO_URI")

def get_db_connection():
    client = MongoClient(MONGO_URI, connectTimeoutMS=10000, serverSelectionTimeoutMS=10000)
    return client.get_database()

DEFAULT_MESSAGES = {
    "1": "The best way to predict the future is to create it. 🏗️",
    "2": "Don't stop until you are proud of your infrastructure. 💻",
    "3": "Your only limit is your mind, not your cloud quota. 🚀",
    "4": "Consistency is the key to mastering DevOps. 🗝️"
}

HTML_TEMPLATE = """
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Alaa's Motivational Hub</title>
    <style>
        :root { --primary: #6366f1; --success: #10b981; --bg: #f8fafc; }
        body { font-family: 'Segoe UI', sans-serif; background: var(--bg); display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; color: #1e293b; }
        .app-card { background: #ffffff; padding: 40px; border-radius: 24px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.1); text-align: center; max-width: 500px; width: 95%; border: 1px solid #e2e8f0; }
        h1 { color: var(--primary); font-size: 2.2rem; margin-bottom: 5px; }
        .status-text { font-size: 0.85rem; font-weight: 600; margin-bottom: 20px; color: #64748b; }
        .grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin: 25px 0; }
        button { background: var(--primary); color: white; border: none; padding: 18px; border-radius: 12px; font-size: 1.1rem; font-weight: bold; cursor: pointer; transition: all 0.2s; }
        button:hover { background: #4f46e5; transform: scale(1.05); }
        #message-display { margin: 30px 0; font-size: 1.3rem; font-style: italic; min-height: 60px; color: #475569; display: flex; align-items: center; justify-content: center; }
        
        .admin-section { margin-top: 35px; padding-top: 25px; border-top: 1px solid #f1f5f9; text-align: left; }
        .admin-section h4 { margin: 0 0 15px 0; color: #64748b; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 0.05em; }
        .input-group { display: flex; gap: 8px; }
        input { flex: 1; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; outline: none; }
        select { padding: 10px; border: 1px solid #cbd5e1; border-radius: 8px; background: white; }
        .save-btn { background: var(--success); font-size: 0.9rem; padding: 10px 15px; width: auto; }
        .save-btn:hover { background: #059669; }
        footer { margin-top: 30px; font-size: 0.75rem; color: #94a3b8; }
    </style>
</head>
<body>
    <div class="app-card">
        <h1>Hello, Alaa! ✨</h1>
        <div class="status-text">{{ "Database Live 🟢" if connected else "Running Offline 🟠" }}</div>
        
        <div class="grid">
            {% for id in ["1", "2", "3", "4"] %}
            <button onclick="display('{{ id }}')">{{ id }}</button>
            {% endfor %}
        </div>
        
        <div id="message-display">Select a number for inspiration...</div>

        <div class="admin-section">
            <h4>Update Hub ✍️</h4>
            <div class="input-group">
                <select id="btn-id">
                    <option value="1">1</option><option value="2">2</option>
                    <option value="3">3</option><option value="4">4</option>
                </select>
                <input type="text" id="new-msg" placeholder="Write something new...">
                <button class="save-btn" onclick="updateMsg()">Update</button>
            </div>
        </div>
        
        <footer>DevOps Final Project • Alaa Nassar • 2026</footer>
    </div>

    <script>
        let msgs = {{ messages | tojson }};
        function display(id) {
            document.getElementById('message-display').innerText = msgs[id];
        }

        async function updateMsg() {
            const id = document.getElementById('btn-id').value;
            const text = document.getElementById('new-msg').value;
            if(!text) return;

            const response = await fetch('/update', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({id, text})
            });

            if(response.ok) {
                msgs[id] = text;
                display(id);
                document.getElementById('new-msg').value = '';
                alert("Cloud Synced! ✅");
            }
        }
    </script>
</body>
</html>
"""

@app.route('/')
def index():
    messages_to_show = DEFAULT_MESSAGES
    is_connected = False
    if MONGO_URI:
        try:
            db = get_db_connection()
            collection = db.messages
            if collection.count_documents({}) == 0:
                collection.insert_many([{"_id": k, "text": v} for k, v in DEFAULT_MESSAGES.items()])
            db_data = list(collection.find())
            messages_to_show = {doc["_id"]: doc["text"] for doc in db_data}
            is_connected = True
        except Exception as e:
            print(f"Error: {e}")
            is_connected = False
    return render_template_string(HTML_TEMPLATE, messages=messages_to_show, connected=is_connected)

@app.route('/update', methods=['POST'])
def update():
    data = request.json
    if MONGO_URI:
        try:
            db = get_db_connection()
            db.messages.update_one({"_id": data['id']}, {"$set": {"text": data['text']}})
            return jsonify({"status": "success"})
        except:
            return jsonify({"status": "error"}), 500
    return jsonify({"status": "no_db"}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)