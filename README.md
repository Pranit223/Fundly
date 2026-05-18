# AI Expense Tracker

Full-stack expense tracker built with Flutter, FastAPI, and MongoDB.

## Step-by-step backend setup

1. Install MongoDB locally or create a free MongoDB Atlas cluster.
2. Open a terminal inside `backend`.
3. Create a virtual environment:

```bash
python -m venv .venv
```

4. Activate it on Windows:

```bash
.venv\Scripts\activate
```

5. Install dependencies:

```bash
pip install -r requirements.txt
```

6. Copy `.env.example` to `.env`.
7. Update `MONGODB_URL`, `MONGODB_DB`, and `JWT_SECRET_KEY`.
8. Optional for real local AI: install Ollama, run `ollama pull llama3.2`, and keep Ollama running.
9. You can configure `OLLAMA_URL` and `OLLAMA_MODEL` in `.env`.
10. Start the FastAPI server:

```bash
uvicorn app.main:app --reload
```

9. Open Swagger docs at `http://127.0.0.1:8000/docs`.

## Backend structure

```text
backend/
  app/
    main.py
    routes/
    models/
    schemas/
    services/
    database/
```

## MongoDB collections

- `users`
- `expenses`

## Flutter setup

1. From the project root, install Flutter dependencies:

```bash
flutter pub get
```

2. Open `lib/src/core/config/app_config.dart`.
3. Set the right backend URL:

- Android emulator: `http://10.0.2.2:8000`
- iOS simulator: `http://127.0.0.1:8000`
- Physical device: use your computer IP, for example `http://192.168.1.10:8000`

4. Run the app:

```bash
flutter run
```

## Flutter screens

- Login Screen
- Signup Screen
- Home Dashboard
- Add Expense Screen
- Expense List Screen

## Main API routes

- `POST /signup`
- `POST /login`
- `POST /expense`
- `GET /expenses`
- `PUT /expense/{id}`
- `DELETE /expense/{id}`
- `GET /dashboard`
- `GET /alerts`

## Free AI categorization

The backend uses free rule-based categorization with regex and keyword matching.

Examples:

- `zomato`, `restaurant`, `cafe` -> `Food`
- `uber`, `ola`, `taxi` -> `Transport`
- `amazon`, `flipkart` -> `Shopping`

You can extend this in `backend/app/services/categorization_service.py`.

## Real local AI with Ollama

The app now supports real local AI through Ollama.

1. Install [Ollama](https://ollama.com/)
2. Pull a model:

```bash
ollama pull llama3.2
```

3. Start Ollama on your machine
4. Keep these values in `backend/.env`:

```env
OLLAMA_URL=http://127.0.0.1:11434/api/generate
OLLAMA_MODEL=llama3.2
```

If Ollama is not running, the app automatically falls back to local rule-based categorization and rule-based insights.

## What you need to configure manually

- MongoDB URL in `backend/.env`
- Database name in `backend/.env`
- JWT secret in `backend/.env`
- API base URL in `lib/src/core/config/app_config.dart`
- MongoDB service or Atlas cluster availability

## Common errors and fixes

- `401 Unauthorized`
  Fix: login again, check JWT header, and make sure token is stored properly.
- `503 Database connection is not ready`
  Fix: start MongoDB or correct the MongoDB URI in `.env`.
- Flutter cannot connect to backend
  Fix: use `10.0.2.2` for Android emulator, not `localhost`.
- `Invalid email or password`
  Fix: signup first or verify the password entered.
- `422 Unprocessable Entity`
  Fix: check request body fields like `amount`, `note`, and `date`.

## Improvements you can add later

- Better local AI categorization logic
- Category budgets and recurring expenses
- Charts for weekly and monthly trends
- Push or local notifications
- Export to CSV or PDF
- OCR bill scanning
