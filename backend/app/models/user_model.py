from datetime import datetime, timezone

from bson import ObjectId


def build_user_document(
    email: str,
    hashed_password: str,
    monthly_budget: float | None,
) -> dict:
    return {
        "_id": ObjectId(),
        "email": email,
        "hashed_password": hashed_password,
        "monthly_budget": monthly_budget,
        "created_at": datetime.now(timezone.utc),
    }


def serialize_user(document: dict) -> dict:
    return {
        "id": str(document["_id"]),
        "email": document["email"],
        "monthly_budget": document.get("monthly_budget"),
    }
