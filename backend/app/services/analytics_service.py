from datetime import datetime, timedelta, timezone

from app.schemas.dashboard_schema import CategoryBreakdown, DashboardResponse
from app.schemas.expense_schema import ExpenseResponse
from app.services.ai_expense_service import build_ai_spending_insights


async def build_dashboard(expenses: list[ExpenseResponse]) -> DashboardResponse:
    now = datetime.now(timezone.utc)
    today = now.date()
    week_start = today - timedelta(days=today.weekday())
    previous_week_start = week_start - timedelta(days=7)
    previous_week_end = week_start - timedelta(days=1)

    daily_total = 0.0
    weekly_total = 0.0
    monthly_total = 0.0
    category_totals: dict[str, float] = {}
    current_week_category_totals: dict[str, float] = {}
    previous_week_category_totals: dict[str, float] = {}

    for expense in expenses:
        expense_date = expense.date.astimezone(timezone.utc).date()

        if expense_date == today:
            daily_total += expense.amount

        if expense_date >= week_start:
            weekly_total += expense.amount
            current_week_category_totals[expense.category] = (
                current_week_category_totals.get(expense.category, 0) + expense.amount
            )

        if previous_week_start <= expense_date <= previous_week_end:
            previous_week_category_totals[expense.category] = (
                previous_week_category_totals.get(expense.category, 0) + expense.amount
            )

        if expense_date.year == today.year and expense_date.month == today.month:
            monthly_total += expense.amount

        category_totals[expense.category] = (
            category_totals.get(expense.category, 0) + expense.amount
        )

    category_breakdown = [
        CategoryBreakdown(category=category, total=total)
        for category, total in sorted(
            category_totals.items(),
            key=lambda item: item[1],
            reverse=True,
        )
    ]
    insights = await build_ai_spending_insights(
        current_week_category_totals=current_week_category_totals,
        previous_week_category_totals=previous_week_category_totals,
        monthly_total=monthly_total,
        weekly_total=weekly_total,
    ) or build_spending_insights(
        current_week_category_totals=current_week_category_totals,
        previous_week_category_totals=previous_week_category_totals,
        monthly_total=monthly_total,
        weekly_total=weekly_total,
    )

    return DashboardResponse(
        daily_total=round(daily_total, 2),
        weekly_total=round(weekly_total, 2),
        monthly_total=round(monthly_total, 2),
        category_breakdown=category_breakdown,
        insights=insights,
    )


def build_spending_insights(
    *,
    current_week_category_totals: dict[str, float],
    previous_week_category_totals: dict[str, float],
    monthly_total: float,
    weekly_total: float,
) -> list[str]:
    insights: list[str] = []

    comparison_candidates: list[tuple[str, float]] = []
    categories = set(current_week_category_totals) | set(previous_week_category_totals)

    for category in categories:
        current_total = current_week_category_totals.get(category, 0.0)
        previous_total = previous_week_category_totals.get(category, 0.0)

        if current_total <= 0:
            continue

        if previous_total > 0:
            change_pct = ((current_total - previous_total) / previous_total) * 100
            comparison_candidates.append((category, change_pct))
        elif current_total > 0:
            insights.append(
                f"{category} spending started this week at {current_total:.0f}."
            )

    if comparison_candidates:
        category, change_pct = max(comparison_candidates, key=lambda item: abs(item[1]))
        direction = "increased" if change_pct >= 0 else "decreased"
        insights.insert(
            0,
            f"{category} spending {direction} {abs(change_pct):.0f}% compared to last week.",
        )

    if monthly_total > 0:
        top_category = None
        top_total = 0.0
        if current_week_category_totals:
            top_category, top_total = max(
                current_week_category_totals.items(),
                key=lambda item: item[1],
            )
        if top_category is not None:
            insights.append(
                f"{top_category} is your strongest spending category this week at {top_total:.0f}."
            )

    if weekly_total > 0 and monthly_total > 0:
        weekly_share = (weekly_total / monthly_total) * 100
        insights.append(
            f"This week accounts for {weekly_share:.0f}% of your spending this month."
        )

    return insights[:3]
