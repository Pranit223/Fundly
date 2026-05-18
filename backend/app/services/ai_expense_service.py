from app.schemas.ai_schema import AICategorySuggestionResponse
from app.services.categorization_service import categorize_expense
from app.services.ollama_service import generate_json

VALID_CATEGORIES = {
    "Food",
    "Transport",
    "Shopping",
    "Bills",
    "Health",
    "Entertainment",
    "Other",
}


async def get_ai_category_suggestion(note: str) -> AICategorySuggestionResponse:
    prompt = f"""
You classify personal expenses into exactly one category.

Allowed categories:
- Food
- Transport
- Shopping
- Bills
- Health
- Entertainment
- Other

Expense note:
{note}

Return strict JSON with keys:
- category
- reason
- confidence

Rules:
- confidence must be between 0 and 1
- keep reason under 20 words
- choose only from the allowed categories
""".strip()

    ai_result = await generate_json(prompt)
    if ai_result is not None:
        category = str(ai_result.get("category", "")).strip().title()
        reason = str(ai_result.get("reason", "")).strip()
        confidence = _normalize_confidence(ai_result.get("confidence"))

        if category in VALID_CATEGORIES and reason:
            return AICategorySuggestionResponse(
                category=category,
                reason=reason,
                confidence=confidence,
                source="ollama",
            )

    fallback_category = categorize_expense(note, None)
    return AICategorySuggestionResponse(
        category=fallback_category,
        reason="Matched local expense patterns.",
        confidence=0.42 if fallback_category == "Other" else 0.68,
        source="rules",
    )


async def build_ai_spending_insights(
    *,
    current_week_category_totals: dict[str, float],
    previous_week_category_totals: dict[str, float],
    monthly_total: float,
    weekly_total: float,
) -> list[str] | None:
    prompt = f"""
You are an expense tracker assistant.
Write up to 3 short insights about the user's spending.
Each insight must be one sentence and under 18 words.
Focus on trends, biggest category changes, or weekly/monthly patterns.

Current week totals by category:
{current_week_category_totals}

Previous week totals by category:
{previous_week_category_totals}

Current month total:
{monthly_total}

Current week total:
{weekly_total}

Return strict JSON with one key:
- insights

The insights value must be an array of strings.
""".strip()

    ai_result = await generate_json(prompt)
    if ai_result is None:
        return None

    insights = ai_result.get("insights")
    if not isinstance(insights, list):
        return None

    cleaned = [
        str(item).strip()
        for item in insights
        if isinstance(item, str) and str(item).strip()
    ]
    return cleaned[:3] or None


def _normalize_confidence(value) -> float:
    try:
        confidence = float(value)
    except (TypeError, ValueError):
        return 0.75

    return max(0.0, min(confidence, 1.0))
