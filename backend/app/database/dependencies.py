from bson import ObjectId
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.database.connection import mongo_db
from app.services.auth_service import decode_access_token

security = HTTPBearer()


def get_database():
    if mongo_db.database is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database connection is not ready.",
        )
    return mongo_db.database


def get_user_collection(database=Depends(get_database)):
    return database["users"]


def get_expense_collection(database=Depends(get_database)):
    return database["expenses"]


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    users_collection=Depends(get_user_collection),
):
    token = credentials.credentials

    try:
        payload = decode_access_token(token)
        user_id = payload.get("sub")
    except Exception as error:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token.",
        ) from error

    if not user_id or not ObjectId.is_valid(user_id):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload.",
        )

    user = await users_collection.find_one({"_id": ObjectId(user_id)})

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found.",
        )

    return user
