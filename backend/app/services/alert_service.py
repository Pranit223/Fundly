from datetime import datetime, timezone

from app.schemas.dashboard_schema import AlertResponse
from app.schemas.expense_schema import ExpenseResponse


def build_alerts(
    expenses: list[ExpenseResponse],
    monthly_budget: float | None,
) -> list[AlertResponse]:
    alerts: list[AlertResponse] = []

    current_month_expenses = _current_month_expenses(expenses)
    monthly_total = sum(expense.amount for expense in current_month_expenses)

    if monthly_budget is not None and monthly_total > monthly_budget:
        alerts.append(
            AlertResponse(
                type="budget",
                message=(
                    f"Monthly spending has exceeded your limit by "
                    f"{monthly_total - monthly_budget:.2f}."
                ),
            )
        )

    if current_month_expenses:
        average_amount = monthly_total / len(current_month_expenses)
        threshold = max(average_amount * 2, 2000)
        unusually_large = [
            expense for expense in current_month_expenses if expense.amount >= threshold
        ]

        if unusually_large:
            largest = max(unusually_large, key=lambda expense: expense.amount)
            alerts.append(
                AlertResponse(
                    type="large_expense",
                    message=(
                        f"Unusually large expense detected: {largest.amount:.2f} "
                        f"for {largest.note}."
                    ),
                )
            )

    return alerts


def _current_month_expenses(expenses: list[ExpenseResponse]) -> list[ExpenseResponse]:
    current_date = datetime.now(timezone.utc)
    return [
        expense
        for expense in expenses
        if expense.date.astimezone(timezone.utc).year == current_date.year
        and expense.date.astimezone(timezone.utc).month == current_date.month
    ]
