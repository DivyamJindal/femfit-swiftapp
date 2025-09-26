import React, { useState } from "react";
import "./JournalEntry.css";

const moods = [
  { label: "Happy", icon: "😊", value: "happy" },
  { label: "Calm", icon: "😌", value: "calm" },
  { label: "Energetic", icon: "⚡", value: "energetic" },
  { label: "Tired", icon: "😴", value: "tired" },
  { label: "Sad", icon: "☁️", value: "sad" },
  { label: "Anxious", icon: "😟", value: "anxious" },
  { label: "Irritable", icon: "😠", value: "irritable" },
  { label: "Confident", icon: "💪", value: "confident" },
  { label: "Focused", icon: "🧐", value: "focused" },
  { label: "Relaxed", icon: "🛀", value: "relaxed" },
];

const symptoms = [
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
];

export default function JournalEntry() {
  const [selectedMoods, setSelectedMoods] = useState<string[]>([]);
  const [selectedSymptoms, setSelectedSymptoms] = useState<string[]>([]);
  const [journalEntry, setJournalEntry] = useState<string>("");
  const [energy, setEnergy] = useState<number>(3);
  const [sleep, setSleep] = useState<number>(4);
  const [stress, setStress] = useState<number>(2);
  const [exercise, setExercise] = useState<number>(3);
  const [nutrition, setNutrition] = useState<number>(4);
  const [social, setSocial] = useState<number>(4);

  const toggleItem = (
    item: string,
    list: string[],
    setList: React.Dispatch<React.SetStateAction<string[]>>
  ) => {
    setList((prev) =>
      prev.includes(item) ? prev.filter((i) => i !== item) : [...prev, item]
    );
  };

  const handleSubmit = async () => {
    const data = {
      log_date: new Date().toISOString().split("T")[0],
      moods: selectedMoods,
      symptoms: selectedSymptoms,
      journal_entry: journalEntry,
      energy,
      sleep,
      stress,
      exercise,
      nutrition,
      social_connection: social,
    };

    try {
      const res = await fetch("http://localhost:8000/submit", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });

      if (!res.ok) {
        throw new Error(`Server error: ${res.status}`);
      }

      const json = await res.json();
      console.log(json);
      alert("Saved successfully!");
    } catch (err) {
      console.error(err);
      alert("Failed to save");
    }
  };

  const renderSlider = (
    label: string,
    value: number,
    setValue: React.Dispatch<React.SetStateAction<number>>,
    min = 1,
    max = 10
  ) => (
    <div className="journal-section">
      <div className="journal-section-title">{label}</div>
      <input
        type="range"
        min={min}
        max={max}
        value={value}
        onChange={(e) => setValue(Number(e.target.value))}
      />
      <div className="slider-value">{value}</div>
    </div>
  );

  return (
    <div className="journal-container">
      {/* Mood Selection */}
      <div className="journal-section">
        <div className="journal-section-title">
          <span role="img" aria-label="smile" className="journal-icon">
            😊
          </span>
          How are you feeling today?
        </div>
        <div className="mood-options">
          {moods.map((mood) => (
            <button
              key={mood.value}
              className={`mood-card${
                selectedMoods.includes(mood.value) ? " selected" : ""
              }`}
              onClick={() =>
                toggleItem(mood.value, selectedMoods, setSelectedMoods)
              }
              type="button"
            >
              <span className="mood-card-icon">{mood.icon}</span>
              <span className="mood-card-label">{mood.label}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Symptoms */}
      <div className="journal-section">
        <div className="journal-section-title">Track Symptoms</div>
        <div className="symptom-tags">
          {symptoms.map((symptom) => (
            <button
              key={symptom}
              className={`symptom-tag${
                selectedSymptoms.includes(symptom) ? " active" : ""
              }`}
              onClick={() =>
                toggleItem(symptom, selectedSymptoms, setSelectedSymptoms)
              }
              type="button"
            >
              {symptom}
            </button>
          ))}
        </div>
      </div>

      {/* Sliders for numeric metrics */}
      {renderSlider("Energy Level", energy, setEnergy)}
      {renderSlider("Sleep Quality", sleep, setSleep)}
      {renderSlider("Stress Level", stress, setStress)}
      {renderSlider("Exercise", exercise, setExercise)}
      {renderSlider("Nutrition", nutrition, setNutrition)}
      {renderSlider("Social Connection", social, setSocial)}
      

      {/* Notes */}
      <div className="journal-section">
        <div className="journal-section-title">Notes & Thoughts</div>
        <textarea
          className="notes-input"
          placeholder="How are you feeling? What's on your mind today?"
          value={journalEntry}
          onChange={(e) => setJournalEntry(e.target.value)}
        />
      </div>

      <button type="button" onClick={handleSubmit}>
        Save
      </button>
    </div>
  );
}
