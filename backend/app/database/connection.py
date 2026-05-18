import os

from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase


class MongoDatabase:
    client: AsyncIOMotorClient | None = None
    database: AsyncIOMotorDatabase | None = None


mongo_db = MongoDatabase()


async def connect_to_mongo() -> None:
    mongo_uri = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
    database_name = os.getenv("MONGODB_DB", "expense_tracker")

    mongo_db.client = AsyncIOMotorClient(mongo_uri)
    mongo_db.database = mongo_db.client[database_name]


async def close_mongo_connection() -> None:
    if mongo_db.client is not None:
        mongo_db.client.close()
