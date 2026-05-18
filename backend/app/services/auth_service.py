import os
from datetime import datetime, timedelta, timezone

from fastapi import HTTPException, status
from jose import jwt
from passlib.context import CryptContext

from app.models.user_model import build_user_document, serialize_user
from app.schemas.auth_schema import AuthResponse, LoginRequest, SignupRequest, UserResponse

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

SECRET_KEY = os.getenv("JWT_SECRET_KEY", "change-this-secret-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(user_id: str) -> str:
    expire_at = datetime.now(timezone.utc) + timedelta(
        minutes=ACCESS_TOKEN_EXPIRE_MINUTES
    )
    payload = {
        "sub": user_id,
        "exp": expire_at,
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def decode_access_token(token: str) -> dict:
    return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])


async def signup_user(payload: SignupRequest, users_collection) -> AuthResponse:
    existing_user = await users_collection.find_one({"email": payload.email.lower()})

    if existing_user is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="An account with this email already exists.",
        )

    user_document = build_user_document(
        email=payload.email.lower(),
        hashed_password=hash_password(payload.password),
        monthly_budget=payload.monthly_budget,
    )

    await users_collection.insert_one(user_document)

    user = UserResponse(**serialize_user(user_document))
    token = create_access_token(user.id)

    return AuthResponse(access_token=token, user=user)


async def login_user(payload: LoginRequest, users_collection) -> AuthResponse:
    user_document = await users_collection.find_one({"email": payload.email.lower()})

    if user_document is None or not verify_password(
        payload.password,
        user_document["hashed_password"],
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    user = UserResponse(**serialize_user(user_document))
    token = create_access_token(user.id)

    return AuthResponse(access_token=token, user=user)
