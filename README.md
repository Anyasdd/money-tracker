# Money Tracker

Money Tracker is a cross-platform mobile application for managing personal income and expenses.

The application is built with Flutter and Dart. It communicates with a custom Python FastAPI server and stores data in a PostgreSQL database.

## Features

- View total balance, income, and expenses.
- Add new income and expense transactions.
- View transaction history.
- Edit and delete existing transactions.
- Choose categories or create custom categories.
- View monthly expense statistics with a pie chart.
- Manage application state using BLoC.
- Handle HTTP requests asynchronously.

## Technologies

**Frontend:** Flutter, Dart, flutter_bloc, http, fl_chart, intl.

**Backend:** Python, FastAPI, asyncpg.

**Database:** PostgreSQL 15 running in Docker.

**Version control:** Git and GitHub.

## Project Structure

- `frontend/` — Flutter mobile application.
- `frontend/lib/bloc/` — BLoC events, states, and logic.
- `frontend/lib/models/` — data models.
- `frontend/lib/repositories/` — API communication.
- `frontend/lib/screens/` — application screens.
- `frontend/test/` — automated tests.
- `backend/main.py` — FastAPI server.
- `backend/init.sql` — database table creation script.
- `backend/requirements.txt` — Python dependencies.
- `backend/.env.example` — example environment configuration.

## How to Run

### 1. Start PostgreSQL

Install Docker Desktop and start the Docker Engine.

Create a PostgreSQL 15 container using the settings from `backend/.env.example`.

Use a local database named `money_tracker` and expose PostgreSQL on port `5433`.

Create the database table by executing `backend/init.sql`.

### 2. Start the Backend

Open the `backend` directory.

Create a Python virtual environment:

`python -m venv .venv`

Install dependencies:

`.\.venv\Scripts\python.exe -m pip install -r requirements.txt`

Create a `.env` file using `.env.example` and enter the correct database credentials.

Start the FastAPI server:

`.\.venv\Scripts\python.exe -m uvicorn main:app --reload`

The API will be available at:

`http://127.0.0.1:8000`

API documentation:

`http://127.0.0.1:8000/docs`

### 3. Start the Flutter Application

Open the `frontend` directory.

Install dependencies:

`flutter pub get`

Start an Android emulator and run:

`flutter run`

The Android emulator connects to the local backend using `http://10.0.2.2:8000`.

### 4. Run Tests

Inside the `frontend` directory, run:

`flutter analyze`

`flutter test`

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/health` | Check server status |
| GET | `/balance` | Get total balance |
| GET | `/transactions` | Get all transactions |
| POST | `/transactions` | Create a transaction |
| PUT | `/transactions/{id}` | Update a transaction |
| DELETE | `/transactions/{id}` | Delete a transaction |

## Architecture

The mobile application communicates with the backend using REST API requests.

**Flutter UI → BLoC → Repository → FastAPI → PostgreSQL**

BLoC manages loading, success, and error states.

Asynchronous operations are implemented using `async/await` in Dart and Python.

## Notes

This project is developed for educational purposes.

Database passwords and local environment files are excluded from Git using `.gitignore`.