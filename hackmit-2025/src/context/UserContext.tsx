import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

// Types
export interface Message {
  id: number;
  type: 'user' | 'ai';
  content: string;
  timestamp: Date;
}

export interface JournalEntry {
  id: string;
  date: string;
  mood: string | string[];
  symptoms: string[];
  cycleDay: number;
  notes: string;
  voice_note: string | null;
  content: string;
}

export interface UserContextType {
  // Messages for chat
  messages: Message[];
  setMessages: React.Dispatch<React.SetStateAction<Message[]>>;
  addMessage: (message: Omit<Message, 'id'>) => void;
  
  // Journal entries
  journalEntries: JournalEntry[];
  setJournalEntries: React.Dispatch<React.SetStateAction<JournalEntry[]>>;
  addJournalEntry: (entry: Omit<JournalEntry, 'id'>) => void;
  
  // Voice recordings
  voiceRecordings: string[];
  setVoiceRecordings: React.Dispatch<React.SetStateAction<string[]>>;
  addVoiceRecording: (recording: string) => void;
}

// Create context
const UserContext = createContext<UserContextType | undefined>(undefined);

// Helper functions for localStorage
const saveToStorage = (key: string, data: any) => {
  try {
    localStorage.setItem(key, JSON.stringify(data));
  } catch (error) {
    console.warn(`Failed to save ${key} to localStorage:`, error);
  }
};

const loadFromStorage = <T,>(key: string, defaultValue: T): T => {
  try {
    const stored = localStorage.getItem(key);
    if (stored) {
      const parsed = JSON.parse(stored);
      // Handle Date objects in messages
      if (key === 'luna_messages') {
        return parsed.map((msg: any) => ({
          ...msg,
          timestamp: new Date(msg.timestamp)
        }));
      }
      return parsed;
    }
  } catch (error) {
    console.warn(`Failed to load ${key} from localStorage:`, error);
  }
  return defaultValue;
};

// Provider component
export const UserProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  // Initialize state from localStorage or defaults
  const [messages, setMessages] = useState<Message[]>(() => 
    loadFromStorage('luna_messages', [
      {
        id: 1,
        type: 'ai' as const,
        content: "Hi! I'm Luna, your personal cycle companion. I've been analyzing your journal entries and I'm here to help you understand your patterns better. How are you feeling today?",
        timestamp: new Date()
      }
    ])
  );

  const [journalEntries, setJournalEntries] = useState<JournalEntry[]>(() =>
    loadFromStorage('luna_journal_entries', [])
  );

  const [voiceRecordings, setVoiceRecordings] = useState<string[]>(() =>
    loadFromStorage('luna_voice_recordings', [])
  );

  // Save to localStorage whenever state changes
  useEffect(() => {
    saveToStorage('luna_messages', messages);
  }, [messages]);

  useEffect(() => {
    saveToStorage('luna_journal_entries', journalEntries);
  }, [journalEntries]);

  useEffect(() => {
    saveToStorage('luna_voice_recordings', voiceRecordings);
  }, [voiceRecordings]);

  // Helper functions
  const addMessage = (message: Omit<Message, 'id'>) => {
    const newMessage: Message = {
      ...message,
      id: Date.now() + Math.random(), // Ensure unique ID
    };
    setMessages(prev => [...prev, newMessage]);
  };

  const addJournalEntry = (entry: Omit<JournalEntry, 'id'>) => {
    const newEntry: JournalEntry = {
      ...entry,
      id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
    };
    setJournalEntries(prev => [...prev, newEntry]);
  };

  const addVoiceRecording = (recording: string) => {
    setVoiceRecordings(prev => [...prev, recording]);
  };

  const value: UserContextType = {
    messages,
    setMessages,
    addMessage,
    journalEntries,
    setJournalEntries,
    addJournalEntry,
    voiceRecordings,
    setVoiceRecordings,
    addVoiceRecording,
  };

  return (
    <UserContext.Provider value={value}>
      {children}
    </UserContext.Provider>
  );
};

// Custom hook to use the context
export const useUser = (): UserContextType => {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
};