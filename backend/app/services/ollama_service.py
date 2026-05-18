import asyncio
import json
import os
from urllib import error, request


OLLAMA_URL = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434/api/generate")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.2")


async def generate_json(prompt: str) -> dict | None:
    payload = {
        "model": OLLAMA_MODEL,
        "prompt": prompt,
        "stream": False,
        "format": "json",
    }

    return await asyncio.to_thread(_post_to_ollama, payload)


def _post_to_ollama(payload: dict) -> dict | None:
    encoded = json.dumps(payload).encode("utf-8")
    req = request.Request(
        OLLAMA_URL,
        data=encoded,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with request.urlopen(req, timeout=20) as response:
            raw = json.loads(response.read().decode("utf-8"))
    except (error.URLError, TimeoutError, json.JSONDecodeError):
        return None

    body = raw.get("response")
    if not isinstance(body, str):
        return None

    try:
        parsed = json.loads(body)
    except json.JSONDecodeError:
        return None

    if isinstance(parsed, dict):
        return parsed

    return None
