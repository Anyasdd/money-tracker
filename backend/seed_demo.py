
import asyncio
import calendar
import os
import random

from datetime import date, datetime, timedelta, timezone
from decimal import Decimal
from pathlib import Path

import asyncpg
from dotenv import load_dotenv


# Используем существующие настройки PostgreSQL
load_dotenv(Path(__file__).resolve().parent / ".env")

BISHKEK_TZ = timezone(timedelta(hours=6))


# Категория, описание, минимальная и максимальная сумма
EXPENSES = [
    ("Еда", "Продукты в супермаркете", 400, 1500),
    ("Еда", "Обед в кафе", 200, 650),
    ("Транспорт", "Автобус", 20, 120),
    ("Еда", "Кофе", 130, 350),
    ("Еда", "Продукты", 500, 1800),
    ("Покупки", "Бытовые товары", 300, 1900),
    ("Транспорт", "Такси", 150, 550),
    ("Еда", "Обед", 250, 750),
    ("Здоровье", "Аптека", 220, 1100),
    ("Жильё", "Аренда жилья", 14000, 18000),
    ("Еда", "Доставка еды", 450, 1000),
    ("Транспорт", "Проезд", 20, 120),
    ("Еда", "Продукты", 500, 2000),
    ("Учёба", "Учебные материалы", 250, 1200),
    ("Еда", "Кафе с друзьями", 500, 1300),
    ("Развлечения", "Кино", 300, 650),
    ("Транспорт", "Такси", 180, 650),
    ("Покупки", "Одежда", 800, 3400),
    ("Еда", "Продукты", 450, 1500),
    ("Жильё", "Интернет", 600, 1100),
    ("Транспорт", "Автобус", 20, 120),
    ("Еда", "Перекус", 100, 400),
    ("Еда", "Продукты", 550, 1400),
    ("Другое", "Подарок", 300, 1200),
    ("Развлечения", "Подписка", 250, 750),
    ("Еда", "Обед", 250, 750),
    ("Транспорт", "Такси", 130, 500),
    ("Покупки", "Косметика", 300, 1200),
    ("Еда", "Продукты", 650, 2000),
    ("Здоровье", "Витамины", 300, 800),
]


def generate_transactions():
    today = date.today()
    rows = []

    # Последние 5 месяцев, включая текущий
    for months_back in range(4, -1, -1):
        month_index = (
            today.year * 12 + today.month - 1 - months_back
        )

        year, month_zero = divmod(month_index, 12)
        month = month_zero + 1

        rng = random.Random(year * 100 + month)

        last_day = calendar.monthrange(year, month)[1]

        # Для текущего месяца не создаём будущие операции
        if months_back == 0:
            last_day = min(last_day, max(1, today.day - 1))

        # Два дохода за месяц
        incomes = [
            ("Зарплата", "Зарплата за месяц", 56000, 65000, 3),
            ("Подработка", "Оплата проекта", 6000, 12000, 8),
        ]

        for index, (category, label, low, high, day) in enumerate(
            incomes, start=1
        ):
            if day > last_day:
                continue

            amount = Decimal(rng.randint(low, high))

            description = (
                f"{label} [DEMO MT] "
                f"{year}-{month:02d}-I{index:02d}"
            )

            created_at = datetime(
                year, month, day, 12, 0, tzinfo=BISHKEK_TZ
            )

            rows.append((
                "income",
                amount,
                category,
                description,
                created_at,
            ))

        # В завершённых месяцах 30 расходов.
        # В текущем — примерно по одному на прошедший день.
        expense_count = min(len(EXPENSES), last_day)

        for index, (category, label, low, high) in enumerate(
            EXPENSES[:expense_count], start=1
        ):
            day = rng.randint(1, last_day)

            amount = (
                Decimal(rng.randint(low, high))
                + Decimal(rng.choice([0, 0, 25, 50, 75])) / 100
            )

            description = (
                f"{label} [DEMO MT] "
                f"{year}-{month:02d}-E{index:02d}"
            )

            created_at = datetime(
                year,
                month,
                day,
                rng.randint(9, 21),
                rng.randint(0, 59),
                tzinfo=BISHKEK_TZ,
            )

            rows.append((
                "expense",
                amount,
                category,
                description,
                created_at,
            ))

    return rows


async def main():
    connection = await asyncpg.connect(
        host=os.getenv("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("DB_PORT", "5433")),
        database=os.getenv("DB_NAME", "money_tracker"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
    )

    inserted = 0
    skipped = 0

    try:
        rows = generate_transactions()

        async with connection.transaction():
            for row in rows:
                # Не вставляем повторно запись с той же
                # уникальной демо-меткой в описании.
                result = await connection.execute(
                    """
                    INSERT INTO transactions
                        (type, amount, category,
                         description, created_at)
                    SELECT
                        $1::varchar(10),
                        $2::numeric(12,2),
                        $3::varchar(50),
                        $4::text,
                        $5::timestamptz
                    WHERE NOT EXISTS (
                        SELECT 1 FROM transactions
                        WHERE description = $4::text
                    )
                    """,
                    *row,
                )

                if result == "INSERT 0 1":
                    inserted += 1
                else:
                    skipped += 1

        total = await connection.fetchval(
            "SELECT COUNT(*) FROM transactions"
        )

        print(f"Добавлено: {inserted}")
        print(f"Уже существовало: {skipped}")
        print(f"Всего транзакций в базе: {total}")

    finally:
        await connection.close()


if __name__ == "__main__":
    asyncio.run(main())
