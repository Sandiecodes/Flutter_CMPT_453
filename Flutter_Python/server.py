
import json
import logging
from pathlib import Path

import requests
from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

HOST = "0.0.0.0"
PORT = 3001

# JSON file stored in the same directory as app.py
DATA_FILE = Path(__file__).resolve().parent / "posts.json"

INITIAL_POSTS = [
    {"id": 1, "text": "bla 1", "time": "9:00"},
    {"id": 2, "text": "bla, blai 2", "time": "9:02"},
    {"id": 3, "text": "bla, blai, blai 3", "time": "9:05"},
]

logging.basicConfig(level=logging.INFO)


# -------------------------
# LOAD AND SAVE POSTS
# -------------------------

def valid_posts(data):
    return (
        isinstance(data, list)
        and all(
            isinstance(post, dict)
            and type(post.get("id")) is int
            and isinstance(post.get("text"), str)
            and isinstance(post.get("time"), str)
            for post in data
        )
    )


def save_posts(posts):
    """Save atomically to avoid leaving a partially written JSON file."""
    temp_file = DATA_FILE.with_suffix(".tmp")

    with temp_file.open("w", encoding="utf-8") as file:
        json.dump(posts, file, indent=2, ensure_ascii=False)
        file.write("\n")

    temp_file.replace(DATA_FILE)


def load_posts():
    if not DATA_FILE.exists() or not DATA_FILE.read_text(
        encoding="utf-8"
    ).strip():
        save_posts(INITIAL_POSTS)
        return INITIAL_POSTS.copy()

    with DATA_FILE.open("r", encoding="utf-8") as file:
        data = json.load(file)

    if not valid_posts(data):
        raise ValueError(
            "Each post must have an integer id and string text and time."
        )

    return data


try:
    posts = load_posts()
    print(f"Loaded {len(posts)} posts from posts.json")
except (OSError, ValueError, json.JSONDecodeError) as error:
    raise SystemExit(f"Could not load posts.json: {error}")


def find_post_index(post_id):
    for index, post in enumerate(posts):
        if post["id"] == post_id:
            return index
    return -1


def parse_post_id(value):
    try:
        # Reject IDs such as "1.5" or "abc".
        if not value.isdigit():
            return None
        return int(value)
    except (ValueError, AttributeError):
        return None


# -------------------------
# READ: GET ALL POSTS
# -------------------------

@app.get("/posts")
def get_posts():
    return jsonify(posts)


# -------------------------
# READ: GET ONE POST
# -------------------------

@app.get("/posts/<post_id>")
def get_post(post_id):
    post_id = parse_post_id(post_id)

    if post_id is None:
        return "The post with the given ID was not found.", 404

    index = find_post_index(post_id)

    if index == -1:
        return "The post with the given ID was not found.", 404

    return jsonify(posts[index])


# -------------------------
# CREATE: ADD A POST
# -------------------------

@app.post("/posts")
def create_post():
    data = request.get_json(silent=True)

    if not isinstance(data, dict):
        return "A JSON object is required.", 400

    text = data.get("text")
    time = data.get("time")

    if not isinstance(text, str) or not isinstance(time, str):
        return "Text and time are required.", 400

    new_id = max((post["id"] for post in posts), default=0) + 1
    new_post = {"id": new_id, "text": text, "time": time}

    posts.append(new_post)

    try:
        save_posts(posts)
    except OSError:
        posts.pop()
        app.logger.exception("Error saving post")
        return "Could not save post.", 500

    return jsonify(new_post), 201


# -------------------------
# UPDATE: PUT AND PATCH
# -------------------------

def update_post(post_id):
    post_id = parse_post_id(post_id)

    if post_id is None:
        return "The post with the given ID was not found.", 404

    index = find_post_index(post_id)

    if index == -1:
        return "The post with the given ID was not found.", 404

    data = request.get_json(silent=True)

    if not isinstance(data, dict):
        return "A JSON object is required.", 400

    text = data.get("text")
    time = data.get("time")

    if "text" in data and not isinstance(text, str):
        return "Text must be a string.", 400

    if "time" in data and not isinstance(time, str):
        return "Time must be a string.", 400

    if "text" not in data and "time" not in data:
        return "Text or time is required.", 400

    old_post = posts[index]
    updated_post = old_post.copy()

    if "text" in data:
        updated_post["text"] = text

    if "time" in data:
        updated_post["time"] = time

    posts[index] = updated_post

    try:
        save_posts(posts)
    except OSError:
        posts[index] = old_post
        app.logger.exception("Error updating post")
        return "Could not save changes.", 500

    return jsonify(updated_post)


app.add_url_rule(
    "/posts/<post_id>",
    view_func=update_post,
    methods=["PUT", "PATCH"],
)


# -------------------------
# DELETE: REMOVE A POST
# -------------------------

@app.delete("/posts/<post_id>")
def delete_post(post_id):
    post_id = parse_post_id(post_id)

    if post_id is None:
        return "The post with the given ID was not found.", 404

    index = find_post_index(post_id)

    if index == -1:
        return "The post with the given ID was not found.", 404

    deleted_post = posts.pop(index)

    try:
        save_posts(posts)
    except OSError:
        posts.insert(index, deleted_post)
        app.logger.exception("Error deleting post")
        return "Could not save changes.", 500

    return jsonify(posts)


# -------------------------
# OLLAMA CHAT
# -------------------------

@app.post("/chat")
def chat():
    data = request.get_json(silent=True)

    if not isinstance(data, dict):
        return jsonify(error="A JSON object is required."), 400

    messages = data.get("messages")

    if (
        not isinstance(messages, list)
        or len(messages) == 0
        or not all(
            isinstance(message, dict)
            and message.get("role") in ("user", "assistant")
            and isinstance(message.get("content"), str)
            for message in messages
        )
    ):
        return jsonify(
            error="A valid messages array is required."
        ), 400

    ollama_messages = [
        {
            "role": "system",
            "content": (
                "You are a helpful assistant in a Flutter app. "
                "Give accurate, concise answers. "
                "Do not make unsupported claims."
            ),
        },
        *messages,
    ]

    try:
        response = requests.post(
            "http://127.0.0.1:11434/api/chat",
            json={
                "model": "qwen3.5:0.8b",
                "messages": ollama_messages,
                "stream": False,
                "think": False,
                "options": {
                    "num_predict": 300,
                },
            },
            timeout=120,
        )

        if not response.ok:
            app.logger.error("Ollama error: %s", response.text)
            return jsonify(
                error="Ollama returned an error."
            ), 502

        result = response.json()
        message = result.get("message")

        if (
            not isinstance(message, dict)
            or not isinstance(message.get("content"), str)
        ):
            return jsonify(
                error="Ollama returned an invalid response."
            ), 502

        return jsonify(reply=message["content"])

    except requests.RequestException:
        app.logger.exception("Ollama connection error")
        return jsonify(
            error=(
                "Could not connect to Ollama. "
                "Check that Ollama is running."
            )
        ), 502

    except ValueError:
        app.logger.exception("Invalid JSON from Ollama")
        return jsonify(
            error="Ollama returned an invalid response."
        ), 502


# -------------------------
# START SERVER
# -------------------------

if __name__ == "__main__":
    print(f"Running on http://{HOST}:{PORT}")
    app.run(host=HOST, port=PORT)
