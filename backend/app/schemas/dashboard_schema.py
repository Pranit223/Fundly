from pydantic import BaseModel


class CategoryBreakdown(BaseModel):
    category: str
    total: float


class DashboardResponse(BaseModel):
    daily_total: float
    weekly_total: float
    monthly_total: float
    category_breakdown: list[CategoryBreakdown]
    insights: list[str]


class AlertResponse(BaseModel):
    type: str
    message: str
