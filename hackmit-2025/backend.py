from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional
import sqlite3
from datetime import date

DB_PATH = "periodically.db"
app = FastAPI()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# ---- Add CORS BEFORE routes ----
origins = [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,  # or ["*"] for dev
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Pydantic model matching frontend data
class JournalEntry(BaseModel):
    log_date: date
    day_rating: Optional[int] = None
    journal_entry: Optional[str] = None
    moods: List[str] = []
    symptoms: List[str] = []
    energy: Optional[int] = None
    sleep: Optional[int] = None
    stress: Optional[int] = None
    exercise: Optional[int] = None
    nutrition: Optional[int] = None
    social_connection: Optional[int] = None


def insert_journal(entry: JournalEntry):
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON;")  # enforce FKs
    cur = conn.cursor()

    # Insert or update daily_logs
    cur.execute(
        """
        INSERT INTO daily_logs (
            log_date, day_rating, journal_entry, energy, sleep, stress, exercise, nutrition, social_connection
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(log_date) DO UPDATE SET
            day_rating=excluded.day_rating,
            journal_entry=excluded.journal_entry,
            energy=excluded.energy,
            sleep=excluded.sleep,
            stress=excluded.stress,
            exercise=excluded.exercise,
            nutrition=excluded.nutrition,
            social_connection=excluded.social_connection
        """,
        (
            entry.log_date,
            entry.day_rating,
            entry.journal_entry,
            entry.energy,
            entry.sleep,
            entry.stress,
            entry.exercise,
            entry.nutrition,
            entry.social_connection,
        ),
    )
    conn.commit()

    # Get log_id
    cur.execute("SELECT log_id FROM daily_logs WHERE log_date = ?", (entry.log_date,))
    log_id = cur.fetchone()[0]

    # --- Handle moods ---
    cur.execute("DELETE FROM daily_log_moods WHERE log_id = ?", (log_id,))
    for mood in entry.moods:
        cur.execute("INSERT OR IGNORE INTO moods (name) VALUES (?)", (mood,))
        cur.execute("SELECT mood_id FROM moods WHERE name = ?", (mood,))
        mood_id = cur.fetchone()[0]
        cur.execute(
            "INSERT OR IGNORE INTO daily_log_moods (log_id, mood_id) VALUES (?, ?)",
            (log_id, mood_id),
        )

    # --- Handle symptoms ---
    cur.execute("DELETE FROM daily_log_symptoms WHERE log_id = ?", (log_id,))
    for symptom in entry.symptoms:
        cur.execute("INSERT OR IGNORE INTO symptoms (name) VALUES (?)", (symptom,))
        cur.execute("SELECT symptom_id FROM symptoms WHERE name = ?", (symptom,))
        symptom_id = cur.fetchone()[0]
        cur.execute(
            "INSERT OR IGNORE INTO daily_log_symptoms (log_id, symptom_id) VALUES (?, ?)",
            (log_id, symptom_id),
        )

    conn.commit()
    conn.close()

from typing import List


class DailyLogOut(BaseModel):
    log_date: date
    day_rating: Optional[int] = None
    journal_entry: Optional[str] = None
    moods: List[str] = []
    symptoms: List[str] = []
    energy: Optional[int] = None
    sleep: Optional[int] = None
    stress: Optional[int] = None
    exercise: Optional[int] = None
    nutrition: Optional[int] = None
    social_connection: Optional[int] = None


@app.get("/logs", response_model=List[DailyLogOut])
def get_logs():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.execute(
        "SELECT log_id, log_date, day_rating, journal_entry, energy, sleep, stress, exercise, nutrition, social_connection FROM daily_logs"
    )
    logs = cur.fetchall()

    result = []
    for (
        log_id,
        log_date,
        day_rating,
        journal_entry,
        energy,
        sleep,
        stress,
        exercise,
        nutrition,
        social_connection,
    ) in logs:

        # Fetch moods
        cur.execute(
            "SELECT m.name FROM daily_log_moods dlm JOIN moods m ON dlm.mood_id = m.mood_id WHERE dlm.log_id = ?",
            (log_id,),
        )
        moods = [row[0] for row in cur.fetchall()]

        # Fetch symptoms
        cur.execute(
            "SELECT s.name FROM daily_log_symptoms dls JOIN symptoms s ON dls.symptom_id = s.symptom_id WHERE dls.log_id = ?",
            (log_id,),
        )
        symptoms = [row[0] for row in cur.fetchall()]

        result.append(
            {
                "log_date": log_date,
                "day_rating": day_rating,
                "journal_entry": journal_entry,
                "moods": moods,
                "symptoms": symptoms,
                "energy": energy,
                "sleep": sleep,
                "stress": stress,
                "exercise": exercise,
                "nutrition": nutrition,
                "social_connection": social_connection,
            }
        )

    conn.close()
    return result

@app.post("/submit")
def submit_journal(entry: JournalEntry):
    insert_journal(entry)
    return {"status": "success"}
