from pydantic import BaseModel, Field


class AICategorySuggestionRequest(BaseModel):
    note: str = Field(min_length=2, max_length=250)


class AICategorySuggestionResponse(BaseModel):
    category: str
    reason: str
    confidence: float
    source: str
