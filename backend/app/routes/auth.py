from fastapi import APIRouter, Depends

from app.database.dependencies import get_user_collection
from app.schemas.auth_schema import AuthResponse, LoginRequest, SignupRequest
from app.services.auth_service import login_user, signup_user

router = APIRouter(tags=["auth"])


@router.post("/signup", response_model=AuthResponse, status_code=201)
async def signup(
    payload: SignupRequest,
    users_collection=Depends(get_user_collection),
) -> AuthResponse:
    return await signup_user(payload=payload, users_collection=users_collection)


@router.post("/login", response_model=AuthResponse)
async def login(
    payload: LoginRequest,
    users_collection=Depends(get_user_collection),
) -> AuthResponse:
    return await login_user(payload=payload, users_collection=users_collection)
