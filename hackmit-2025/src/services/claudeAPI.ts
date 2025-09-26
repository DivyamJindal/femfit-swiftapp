const API_KEY = import.meta.env.VITE_CLAUDE_API_KEY;

export type JournalEntry = {
  id?: string | number;
  date: string;
  mood: string | string[];
  symptoms: string[];
  notes?: string;
  voice_note?: string | null;
  cycleDay?: number;
  content?: string;
};

export const getCyclePhase = (day: number): string => {
  if (day >= 1 && day <= 5) return 'Menstrual';
  if (day >= 6 && day <= 13) return 'Follicular';
  if (day >= 14 && day <= 16) return 'Ovulatory';
  if (day >= 17 && day <= 28) return 'Luteal';
  return 'Unknown';
};

// Mock intelligent responses that reference actual user data
const generateMockResponse = (
  userMessage: string,
  recentEntries: any[],
  currentCycleDay: number
): string => {
  const phase = getCyclePhase(currentCycleDay);
  const lowerMessage = userMessage.toLowerCase();

  // Extract patterns from actual journal entries
  const recentMoods = recentEntries.map(e => e.mood).filter(Boolean);
  const recentSymptoms = recentEntries.flatMap(e => e.symptoms || []);
  const mostRecentEntry = recentEntries[0];

  // Generate contextual responses based on actual data
  if (lowerMessage.includes('feel') || lowerMessage.includes('mood')) {
    if (mostRecentEntry) {
      return `I can see from your recent entry on ${mostRecentEntry.date} that you mentioned feeling ${mostRecentEntry.mood}${mostRecentEntry.symptoms.length > 0 ? ` and experiencing ${mostRecentEntry.symptoms.join(', ')}` : ''}. On day ${currentCycleDay} of your ${phase.toLowerCase()} phase, these feelings are completely normal. ${phase === 'Follicular' ? 'This is typically when energy starts building!' : phase === 'Luteal' ? 'Your body is preparing for your next cycle.' : 'Every phase brings its own experiences.'}`;
    }
    return `You're on day ${currentCycleDay} of your cycle (${phase.toLowerCase()} phase). How are you feeling today? I'm here to help you understand your patterns.`;
  }

  if (lowerMessage.includes('pattern') || lowerMessage.includes('trend')) {
    if (recentMoods.length > 0) {
      return `Looking at your recent entries, I notice you've been tracking moods like ${recentMoods.slice(0, 3).join(', ')}. ${phase === 'Follicular' ? 'This aligns well with the energy boost many experience during this phase!' : 'These patterns help us understand how your cycle affects your wellbeing.'}`;
    }
    return `Based on your tracking, you're currently in your ${phase.toLowerCase()} phase (day ${currentCycleDay}). Keep journaling - the more data we have, the better insights I can provide!`;
  }

  if (lowerMessage.includes('symptom') || lowerMessage.includes('cramp') || lowerMessage.includes('pain')) {
    if (recentSymptoms.length > 0) {
      return `I see you've been tracking ${recentSymptoms.join(', ')} recently. ${phase === 'Menstrual' ? 'These are very common during your period.' : 'Tracking these symptoms helps identify patterns throughout your cycle.'} Have you noticed what helps manage them?`;
    }
    return `You're on day ${currentCycleDay} - how is your body feeling today? Tracking symptoms helps us understand your unique patterns.`;
  }

  if (lowerMessage.includes('next') && lowerMessage.includes('period')) {
    const daysUntilNext = 28 - currentCycleDay;
    return `Based on your current cycle day (${currentCycleDay}), your next period is likely in about ${daysUntilNext} days. Of course, every body is different - I'll get better at predicting as we track more cycles together!`;
  }

  // Default personalized response
  if (mostRecentEntry) {
    return `I remember from your ${mostRecentEntry.date} entry where you mentioned ${mostRecentEntry.content}. You're currently on day ${currentCycleDay} of your ${phase.toLowerCase()} phase. What would you like to explore about your cycle today?`;
  }

  return `You're on day ${currentCycleDay} of your cycle (${phase.toLowerCase()} phase). I'm here to help you understand your patterns and support your wellness journey. What's on your mind?`;
};

export const generatePersonalizedResponse = async (
  userMessage: string,
  journalHistory: JournalEntry[],
  currentCycleDay: number
): Promise<string> => {
  // Simulate API delay for realism
  await new Promise(resolve => setTimeout(resolve, 1000 + Math.random() * 2000));

  const recentEntries = journalHistory.slice(-5).map(entry => ({
    date: entry.date,
    mood: Array.isArray(entry.mood) ? entry.mood.join(', ') : entry.mood,
    symptoms: entry.symptoms,
    cycleDay: entry.cycleDay,
    content: entry.content || entry.notes || 'No content'
  }));

  try {
    // Generate intelligent mock response
    const response = generateMockResponse(userMessage, recentEntries, currentCycleDay);
    return response;
  } catch (error) {
    console.error('Mock API Error:', error);
    
    const phase = getCyclePhase(currentCycleDay);
    return `I can see you're on day ${currentCycleDay} of your cycle (${phase} phase). ${
      recentEntries.length > 0 
        ? `From your recent entries, I notice you've been tracking ${recentEntries[0].mood} moods. ` 
        : ''
    }How are you feeling today? I'm here to support you!`;
  }
};