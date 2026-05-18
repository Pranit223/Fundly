from datetime import datetime, timezone

from bson import ObjectId
from fastapi import HTTPException, status

from app.models.expense_model import build_expense_document, serialize_expense
from app.schemas.expense_schema import (
    ExpenseCreateRequest,
    ExpenseResponse,
    ExpenseUpdateRequest,
)
from app.services.ai_expense_service import get_ai_category_suggestion
from app.services.categorization_service import categorize_expense


def _parse_date(value: str | None) -> datetime | None:
    if value is None:
        return None
    try:
        return datetime.fromisoformat(value)
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Dates must be valid ISO-8601 strings.",
        ) from error


async def create_expense(
    payload: ExpenseCreateRequest,
    user_id: str,
    expenses_collection,
) -> ExpenseResponse:
    category = payload.category
    if category is None or not category.strip():
        suggestion = await get_ai_category_suggestion(payload.note)
        category = suggestion.category
    else:
        category = categorize_expense(payload.note, category)
    document = build_expense_document(
        user_id=user_id,
        amount=payload.amount,
        category=category,
        note=payload.note.strip(),
        expense_date=payload.date,
    )
    await expenses_collection.insert_one(document)
    return ExpenseResponse(**serialize_expense(document))


async def get_expenses(
    user_id: str,
    expenses_collection,
    category: str | None = None,
    start_date: str | None = None,
    end_date: str | None = None,
) -> list[ExpenseResponse]:
    filters: dict = {"user_id": ObjectId(user_id)}
    expense_date_filter: dict = {}

    parsed_start = _parse_date(start_date)
    parsed_end = _parse_date(end_date)

    if parsed_start is not None:
        expense_date_filter["$gte"] = parsed_start

    if parsed_end is not None:
        expense_date_filter["$lte"] = parsed_end

    if expense_date_filter:
        filters["date"] = expense_date_filter

    if category:
        filters["category"] = category

    documents = await expenses_collection.find(filters).sort("date", -1).to_list(500)
    return [ExpenseResponse(**serialize_expense(document)) for document in documents]


async def update_expense(
    expense_id: str,
    payload: ExpenseUpdateRequest,
    user_id: str,
    expenses_collection,
) -> ExpenseResponse:
    document = await _get_owned_expense(
        expense_id=expense_id,
        user_id=user_id,
        expenses_collection=expenses_collection,
    )

    if payload.category is None or not payload.category.strip():
        suggestion = await get_ai_category_suggestion(payload.note)
        category = suggestion.category
    else:
        category = categorize_expense(payload.note, payload.category)
    updated_values = {
        "amount": payload.amount,
        "category": category,
        "note": payload.note.strip(),
        "date": payload.date,
        "updated_at": datetime.now(timezone.utc),
    }

    await expenses_collection.update_one(
        {"_id": document["_id"]},
        {"$set": updated_values},
    )

    document.update(updated_values)
    return ExpenseResponse(**serialize_expense(document))


async def delete_expense(
    expense_id: str,
    user_id: str,
    expenses_collection,
) -> None:
    document = await _get_owned_expense(
        expense_id=expense_id,
        user_id=user_id,
        expenses_collection=expenses_collection,
    )
    await expenses_collection.delete_one({"_id": document["_id"]})


async def _get_owned_expense(
    expense_id: str,
    user_id: str,
    expenses_collection,
) -> dict:
    if not ObjectId.is_valid(expense_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid expense id.",
        )

    document = await expenses_collection.find_one(
        {"_id": ObjectId(expense_id), "user_id": ObjectId(user_id)}
    )

    if document is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Expense not found.",
        )

    return document
