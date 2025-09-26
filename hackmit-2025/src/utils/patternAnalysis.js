export const analyzePatterns = (journalEntries) => {
  const patterns = {};
  
  journalEntries.forEach(entry => {
    const cycleDay = entry.cycleDay;
    if (!patterns[cycleDay]) patterns[cycleDay] = [];
    patterns[cycleDay].push(...entry.moods);
  });
  
  // Find most common moods per cycle day
  const insights = Object.entries(patterns).map(([day, moods]) => {
    const moodCounts = moods.reduce((acc, mood) => {
      acc[mood] = (acc[mood] || 0) + 1;
      return acc;
    }, {});
    
    const topMood = Object.keys(moodCounts).reduce((a, b) => 
      moodCounts[a] > moodCounts[b] ? a : b
    );
    
    return { day: parseInt(day), topMood, confidence: moodCounts[topMood] };
  });
  
  return insights;
};