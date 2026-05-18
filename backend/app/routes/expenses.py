from fastapi import APIRouter, Depends, Query, status

from app.database.dependencies import (
    get_current_user,
    get_expense_collection,
)
from app.schemas.dashboard_schema import AlertResponse, DashboardResponse
from app.schemas.ai_schema import (
    AICategorySuggestionRequest,
    AICategorySuggestionResponse,
)
from app.schemas.expense_schema import (
    ExpenseCreateRequest,
    ExpenseResponse,
    ExpenseUpdateRequest,
)
from app.services.ai_expense_service import get_ai_category_suggestion
from app.services.alert_service import build_alerts
from app.services.analytics_service import build_dashboard
from app.services.expense_service import (
    create_expense,
    delete_expense,
    get_expenses,
    update_expense,
)

router = APIRouter(tags=["expenses"])


@router.post("/expense", response_model=ExpenseResponse, status_code=status.HTTP_201_CREATED)
async def add_expense(
    payload: ExpenseCreateRequest,
    current_user: dict = Depends(get_current_user),
    expenses_collection=Depends(get_expense_collection),
) -> ExpenseResponse:
    return await create_expense(
        payload=payload,
        user_id=str(current_user["_id"]),
        expenses_collection=expenses_collection,
    )


@router.get("/expenses", response_model=list[ExpenseResponse])
async def list_expenses(
    category: str | None = Query(default=None),
    start_date: str | None = Query(default=None),
    end_date: str | None = Query(default=None),
    current_user: dict = Depends(get_current_user),
    expenses_collection=Depends(get_expense_collection),
) -> list[ExpenseResponse]:
    return await get_expenses(
        user_id=str(current_user["_id"]),
        expenses_collection=expenses_collection,
        category=category,
        start_date=start_date,
        end_date=end_date,
    )


@router.put("/expense/{expense_id}", response_model=ExpenseResponse)
async def edit_expense(
    expense_id: str,
    payload: ExpenseUpdateRequest,
    current_user: dict = Depends(get_current_user),
    expenses_collection=Depends(get_expense_collection),
) -> ExpenseResponse:
    return await update_expense(
        expense_id=expense_id,
        payload=payload,
        user_id=str(current_user["_id"]),
        expenses_collection=expenses_collection,
    )


@router.delete("/expense/{expense_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_expense(
    expense_id: str,
    current_user: dict = Depends(get_current_user),
    expenses_collection=Depends(get_expense_collection),
) -> None:
    await delete_expense(
        expense_id=expense_id,
        user_id=str(current_user["_id"]),
        expenses_collection=expenses_collection,
    )


@router.get("/dashboard", response_model=DashboardResponse)
async def dashboard(
    current_user: dict = Depends(get_current_user),
    expenses_collection=Depends(get_expense_collection),
) -> DashboardResponse:
    expenses = await get_expenses(
        user_id=str(current_user["_id"]),
        expenses_collection=expenses_collection,
    )
    return await build_dashboard(expenses)


@router.get("/alerts", response_model=list[AlertResponse])
async def alerts(
    current_user: dict = Depends(get_current_user),
    expenses_collection=Depends(get_expense_collection),
) -> list[AlertResponse]:
    expenses = await get_expenses(
        user_id=str(current_user["_id"]),
        expenses_collection=expenses_collection,
    )
    monthly_budget = current_user.get("monthly_budget")
    return build_alerts(expenses=expenses, monthly_budget=monthly_budget)


@router.post("/ai/category-suggestion", response_model=AICategorySuggestionResponse)
async def ai_category_suggestion(
    payload: AICategorySuggestionRequest,
    current_user: dict = Depends(get_current_user),
) -> AICategorySuggestionResponse:
    del current_user
    return await get_ai_category_suggestion(payload.note)
