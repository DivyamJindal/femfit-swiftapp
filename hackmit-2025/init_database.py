import sqlite3

DB_PATH = "periodically.db"

MOODS = [
    "Happy",
    "Calm",
    "Energetic",
    "Tired",
    "Sad",
    "Anxious",
    "Irritable",
    "Confident",
    "Focused",
    "Relaxed",
]

SYMPTOMS = [
    "Cramps",
    "Bloating",
    "Headache",
    "Fatigue",
    "Back pain",
    "Breast tenderness",
    "Acne",
    "Nausea",
    "Food cravings",
    "Digestive issues",
    "Sleep changes",
    "Mood swings",
    "Dizziness",
    "Water retention",
    "Muscle aches",
]


def init_db():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    # --- Tables ---
    cur.execute(
        """
    CREATE TABLE IF NOT EXISTS periods (
        period_id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_date DATE NOT NULL,
        end_date DATE
    );"""
    )

    cur.execute(
        """
CREATE TABLE IF NOT EXISTS daily_logs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    log_date DATE NOT NULL,
    day_rating INTEGER CHECK (day_rating BETWEEN 1 AND 10),
    journal_entry TEXT,
    energy INTEGER CHECK(energy BETWEEN 1 AND 10),
    sleep INTEGER CHECK(sleep BETWEEN 1 AND 10),
    stress INTEGER CHECK(stress BETWEEN 1 AND 10),
    exercise INTEGER CHECK(exercise BETWEEN 1 AND 10),
    nutrition INTEGER CHECK(nutrition BETWEEN 1 AND 10),
    social_connection INTEGER CHECK(social_connection BETWEEN 1 AND 10),
    UNIQUE(log_date)
);"""
    )

    cur.execute(
        """
    CREATE TABLE IF NOT EXISTS moods (
        mood_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
    );"""
    )

    cur.execute(
        """
    CREATE TABLE IF NOT EXISTS symptoms (
        symptom_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
    );"""
    )

    cur.execute(
        """
    CREATE TABLE IF NOT EXISTS daily_log_moods (
        log_id INTEGER NOT NULL,
        mood_id INTEGER NOT NULL,
        PRIMARY KEY(log_id, mood_id),
        FOREIGN KEY(log_id) REFERENCES daily_logs(log_id) ON DELETE CASCADE,
        FOREIGN KEY(mood_id) REFERENCES moods(mood_id) ON DELETE CASCADE
    );"""
    )

    cur.execute(
        """
    CREATE TABLE IF NOT EXISTS daily_log_symptoms (
        log_id INTEGER NOT NULL,
        symptom_id INTEGER NOT NULL,
        PRIMARY KEY(log_id, symptom_id),
        FOREIGN KEY(log_id) REFERENCES daily_logs(log_id) ON DELETE CASCADE,
        FOREIGN KEY(symptom_id) REFERENCES symptoms(symptom_id) ON DELETE CASCADE
    );"""
    )

    # --- Populate moods and symptoms ---
    for mood in MOODS:
        cur.execute("INSERT OR IGNORE INTO moods (name) VALUES (?);", (mood,))

    for symptom in SYMPTOMS:
        cur.execute("INSERT OR IGNORE INTO symptoms (name) VALUES (?);", (symptom,))

    conn.commit()
    conn.close()


def clear_db():
    """
    Resets database and removes all entries.
    """
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    cur.execute("DROP TABLE IF EXISTS daily_log_symptoms")
    cur.execute("DROP TABLE IF EXISTS daily_log_moods")
    cur.execute("DROP TABLE IF EXISTS daily_logs")
    cur.execute("DROP TABLE IF EXISTS periods")
    cur.execute("DROP TABLE IF EXISTS symptoms")
    cur.execute("DROP TABLE IF EXISTS moods")

    conn.commit()
    conn.close()

    init_db()


if __name__ == "__main__":
    init_db()

init_db()
