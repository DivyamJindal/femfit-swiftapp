const moodKeywords = {
  anxious: ['anxious', 'worried', 'stressed', 'nervous', 'panic'],
  happy: ['happy', 'joyful', 'excited', 'great', 'amazing'],
  sad: ['sad', 'down', 'depressed', 'low', 'blue'],
  angry: ['angry', 'frustrated', 'annoyed', 'mad', 'irritated'],
  tired: ['tired', 'exhausted', 'drained', 'sleepy', 'fatigued']
};

export const detectMoods = (text) => {
  const detectedMoods = [];
  const lowerText = text.toLowerCase();
  
  Object.entries(moodKeywords).forEach(([mood, keywords]) => {
    if (keywords.some(keyword => lowerText.includes(keyword))) {
      detectedMoods.push(mood);
    }
  });
  
  return detectedMoods.length > 0 ? detectedMoods : ['neutral'];
};