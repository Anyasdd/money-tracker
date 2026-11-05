import os
from pathlib import Path
from datetime import datetime
from decimal import Decimal
from typing import Literal

import asyncpg
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field


load_dotenv(Path(__file__).resolve().parent / ".env")

app = FastAPI(title="Money Tracker API")


async def get_db_connection():
    return await asyncpg.connect(
        host=os.getenv("DB_HOST"),
        port=int(os.getenv("DB_PORT", "5433")),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )


# Модель для добавления транзакции
class TransactionCreate(BaseModel):
    type: Literal["income", "expense"]
    amount: Decimal = Field(gt=0, max_digits=12, decimal_places=2)
    category: str = Field(min_length=1, max_length=50)
    description: str | None = None


# Модель для ответа сервера
class TransactionResponse(TransactionCreate):
    id: int
    created_at: datetime


class BalanceResponse(BaseModel):
    total_income: Decimal
    total_expense: Decimal
    balance: Decimal
    transaction_count: int

# Проверка сервера
@app.get("/health")
async def health():
    return {"status": "ok"}


# Проверка базы данных
@app.get("/db-check")
async def db_check():
    conn = await get_db_connection()

    try:
        result = await conn.fetchval("SELECT 1")

        return {
            "database": "connected",
            "result": result
        }
    finally:
        await conn.close()


# Добавление новой транзакции
@app.post(
    "/transactions",
    response_model=TransactionResponse,
    status_code=201
)
async def create_transaction(transaction: TransactionCreate):
    conn = await get_db_connection()

    try:
        row = await conn.fetchrow(
            """
            INSERT INTO transactions
                (type, amount, category, description)
            VALUES ($1, $2, $3, $4)
            RETURNING *
            """,
            transaction.type,
            transaction.amount,
            transaction.category,
            transaction.description
        )

        return dict(row)

    finally:
        await conn.close()


# Получение всех транзакций
@app.get(
    "/transactions",
    response_model=list[TransactionResponse]
)
async def get_transactions():
    conn = await get_db_connection()

    try:
        rows = await conn.fetch(
            """
            SELECT *
            FROM transactions
            ORDER BY created_at DESC, id DESC
            """
        )

        return [dict(row) for row in rows]

    finally:
        await conn.close()


# Удаление транзакции
@app.delete("/transactions/{transaction_id}")
async def delete_transaction(transaction_id: int):
    conn = await get_db_connection()

    try:
        deleted_id = await conn.fetchval(
            """
            DELETE FROM transactions
            WHERE id = $1
            RETURNING id
            """,
            transaction_id
        )

        if deleted_id is None:
            raise HTTPException(
                status_code=404,
                detail="Transaction not found"
            )

        return {"message": "Transaction deleted successfully"}

    finally:
        await conn.close()


# Редактирование транзакции
@app.put(
    "/transactions/{transaction_id}",
    response_model=TransactionResponse
)
async def update_transaction(
    transaction_id: int,
    transaction: TransactionCreate
):
    conn = await get_db_connection()

    try:
        row = await conn.fetchrow(
            """
            UPDATE transactions
            SET
                type = $1,
                amount = $2,
                category = $3,
                description = $4
            WHERE id = $5
            RETURNING *
            """,
            transaction.type,
            transaction.amount,
            transaction.category,
            transaction.description,
            transaction_id
        )

        if row is None:
            raise HTTPException(
                status_code=404,
                detail="Transaction not found"
            )

        return dict(row)

    finally:
        await conn.close()


# Получение общего баланса
@app.get("/balance", response_model=BalanceResponse)
async def get_balance():
    conn = await get_db_connection()

    try:
        row = await conn.fetchrow(
            """
            SELECT
                COALESCE(
                    SUM(amount) FILTER (WHERE type = 'income'),
                    0
                ) AS total_income,

                COALESCE(
                    SUM(amount) FILTER (WHERE type = 'expense'),
                    0
                ) AS total_expense,

                COUNT(*) AS transaction_count

            FROM transactions
            """
        )

        total_income = row["total_income"]
        total_expense = row["total_expense"]

        return {
            "total_income": total_income,
            "total_expense": total_expense,
            "balance": total_income - total_expense,
            "transaction_count": row["transaction_count"]
        }

    finally:
        await conn.close()