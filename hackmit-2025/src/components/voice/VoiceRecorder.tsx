import React, { useState, useRef, useEffect } from 'react';
import './VoiceRecorder.css';
import { Mic, Play } from 'lucide-react';

const mockVoiceNotes = [
  {
    mood: 'happy',
    date: '2024-12-13',
    time: '02:34',
    text: "Today I'm feeling really energetic and happy. I went for a morning run and had a healthy breakfast. I notice my skin is looking clearer too, which always makes me feel more confident.",
    tags: ['energy', 'exercise', 'skin-health'],
  },
  {
    mood: 'neutral',
    date: '2024-12-12',
    time: '01:45',
    text: "Had some mild cramps this morning but they're manageable. I made some chamomile tea and did some gentle stretches which seemed to help.",
    tags: ['cramps', 'self-care', 'remedies'],
  },
];

const moodColors = {
  happy: 'badge-green',
  neutral: 'badge-gray',
  sad: 'badge-blue',
  energetic: 'badge-purple',
  anxious: 'badge-yellow',
};

export default function VoiceRecorder() {
  const [isRecording, setIsRecording] = useState(false);
  const [timer, setTimer] = useState(0);

  // Timer logic
  useEffect(() => {
    let interval: NodeJS.Timeout | null = null;
    if (isRecording) {
      interval = setInterval(() => setTimer(t => t + 1), 1000);
    } else if (!isRecording && timer !== 0) {
      clearInterval(interval!);
    }
    return () => clearInterval(interval!);
  }, [isRecording, timer]);

  const formatTime = (seconds: number) => {
    const m = String(Math.floor(seconds / 60)).padStart(2, '0');
    const s = String(seconds % 60).padStart(2, '0');
    return `${m}:${s}`;
  };

  return (
    <div className="voice-container">
      {/* Recorder Section */}
      <div className="voice-card">
        <div className="voice-header">
          <span className="voice-header-icon"><Mic /></span>
          <span className="voice-header-title">Voice Recorder with Real-time Transcription</span>
        </div>
        <div className="voice-recorder-center">
          <div className="voice-mic-circle">
            <Mic className="voice-mic-icon" />
          </div>
          <div className="voice-timer">{formatTime(timer)}</div>
          <button
            className={`voice-record-btn${isRecording ? ' recording' : ''}`}
            onClick={() => setIsRecording(r => !r)}
            type="button"
          >
            {isRecording ? 'Stop Recording' : 'Start Recording'}
          </button>
        </div>
      </div>

      {/* Recent Voice Notes */}
      <div className="voice-notes-card">
        <div className="voice-notes-title">Recent Voice Notes</div>
        {mockVoiceNotes.map((note, idx) => (
          <div key={idx} className="voice-note-row">
            <div className="voice-note-meta">
              <span className={`voice-note-mood badge ${moodColors[note.mood]}`}>{note.mood}</span>
              <span className="voice-note-date">{note.date}</span>
              <span className="voice-note-time">{note.time}</span>
            </div>
            <div className="voice-note-text">"{note.text}"</div>
            <div className="voice-note-tags">
              {note.tags.map(tag => (
                <span key={tag} className="voice-note-tag">#{tag}</span>
              ))}
            </div>
            <button className="voice-note-play-btn" type="button">
              <Play className="voice-note-play-icon" />
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}