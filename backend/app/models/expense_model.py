from datetime import datetime, timezone

from bson import ObjectId


def build_expense_document(
    user_id: str,
    amount: float,
    category: str,
    note: str,
    expense_date: datetime,
) -> dict:
    return {
        "_id": ObjectId(),
        "user_id": ObjectId(user_id),
        "amount": amount,
        "category": category,
        "note": note,
        "date": expense_date,
        "created_at": datetime.now(timezone.utc),
        "updated_at": datetime.now(timezone.utc),
    }


def serialize_expense(document: dict) -> dict:
    return {
        "id": str(document["_id"]),
        "user_id": str(document["user_id"]),
        "amount": float(document["amount"]),
        "category": document["category"],
        "note": document["note"],
        "date": document["date"],
    }
