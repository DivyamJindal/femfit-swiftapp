export interface JournalEntry {
  // Homepage component fields
  id: string;
  date: string;
  content: string;
  mood: "happy" | "energetic" | "neutral" | "sad";
  symptoms: string[];
  cycleDay: number;
  notes?: string;
  voice_note?: string;

  // MoodVisualization component fields
  log_date: string;
  day_rating: number;
  journal_entry: string;
  moods: string[];
  energy: number;
  sleep: number;
  stress: number;
  exercise: number;
  nutrition: number;
  social_connection: number;
}

export interface Cycle {
  startDate: Date;
  currentDay: number;
  phase: "menstrual" | "follicular" | "ovulatory" | "luteal";
}
