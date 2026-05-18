from datetime import datetime

from pydantic import BaseModel, Field


class ExpenseBase(BaseModel):
    amount: float = Field(gt=0)
    category: str | None = Field(default=None, max_length=50)
    note: str = Field(min_length=2, max_length=250)
    date: datetime


class ExpenseCreateRequest(ExpenseBase):
    pass


class ExpenseUpdateRequest(ExpenseBase):
    pass


class ExpenseResponse(BaseModel):
    id: str
    user_id: str
    amount: float
    category: str
    note: str
    date: datetime
