import React, { useState, useRef, useEffect } from 'react';
import './ChatInterface.css';
import { Send, Bot, User, Calendar, Heart, TrendingUp } from 'lucide-react';
import { generatePersonalizedResponse } from '../../services/claudeAPI';
import { useUser } from '../../context/UserContext';

// Define proper types
interface Cycle {
  startDate: Date;
  currentDay: number;
  phase: string;
}

interface JournalEntry {
  id: string;
  date: string;
  mood: string | string[];
  symptoms: string[];
  cycleDay?: number;
  notes?: string;
  voice_note?: string | null;
  content?: string;
}

interface ChatInterfaceProps {
  journalEntries: JournalEntry[];
  currentCycle: Cycle;
}

const ChatInterface: React.FC<ChatInterfaceProps> = ({ journalEntries, currentCycle }) => {
    // Use context for persistent messages
    const { messages, setMessages, addMessage } = useUser();
    const [newMessage, setNewMessage] = useState('');
    const [isTyping, setIsTyping] = useState(false);
    const scrollAreaRef = useRef<HTMLDivElement>(null);

    // Initialize with welcome message if no messages exist
    useEffect(() => {
        if (messages.length === 0) {
            addMessage({
                type: 'ai',
                content: "Hi! I'm Luna, your personal cycle companion. I've been analyzing your journal entries and I'm here to help you understand your patterns better. How are you feeling today?",
                timestamp: new Date()
            });
        }
    }, [messages.length, addMessage]);

    const sendMessage = async () => {
        if (!newMessage.trim()) return;

        // Add user message
        addMessage({
            type: 'user',
            content: newMessage,
            timestamp: new Date()
        });

        const currentMessage = newMessage;
        setNewMessage('');
        setIsTyping(true);

        try {
            // Call Claude API with proper data transformation
            const transformedJournalEntries = journalEntries.map(entry => ({
                id: entry.id,
                date: entry.date,
                mood: Array.isArray(entry.mood) ? entry.mood.join(', ') : entry.mood,
                symptoms: entry.symptoms,
                cycleDay: entry.cycleDay || 1,
                content: entry.content || entry.notes || 'No content available'
            }));

            const aiContent = await generatePersonalizedResponse(
                currentMessage,
                transformedJournalEntries,
                currentCycle.currentDay
            );

            // Add AI response
            addMessage({
                type: 'ai',
                content: aiContent,
                timestamp: new Date()
            });
        } catch (error) {
            console.error('Chat error:', error);
            addMessage({
                type: 'ai',
                content: "I'm having a small hiccup connecting to my full capabilities right now. Let me try to help based on what I can see from your recent patterns. How are you feeling today?",
                timestamp: new Date()
            });
        }
        setIsTyping(false);
    };

    const handleKeyPress = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    };

    useEffect(() => {
        if (scrollAreaRef.current) {
            scrollAreaRef.current.scrollTop = scrollAreaRef.current.scrollHeight;
        }
    }, [messages, isTyping]);

    const formatTime = (timestamp: Date) => {
        return timestamp.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    };

    const quickActions = [
        { icon: <Heart className="quick-icon pink" />, text: "How am I feeling compared to last month?" },
        { icon: <Calendar className="quick-icon purple" />, text: "When is my next period due?" },
        { icon: <TrendingUp className="quick-icon blue" />, text: "Show me my mood patterns" }
    ];

    return (
        <div className="chat-container">
            {/* Chat Header */}
            <div className="chat-header">
                <div className="chat-header-left">
                    <div className="chat-avatar">
                        <Bot className="chat-avatar-icon" />
                    </div>
                    <div>
                        <div className="chat-title">Luna AI</div>
                        <div className="chat-subtitle">Your intelligent cycle companion</div>
                    </div>
                </div>
                <div className="chat-header-right">
                    <span className="chat-online-dot"></span>
                    <span className="chat-online-text">Online</span>
                </div>
            </div>

            {/* Quick Actions */}
            <div className="chat-quick-actions">
                <div className="chat-quick-title">Quick Questions</div>
                <div className="chat-quick-list">
                    {quickActions.map((action, idx) => (
                        <button
                            key={idx}
                            className="chat-quick-btn"
                            onClick={() => setNewMessage(action.text)}
                            type="button"
                        >
                            {action.icon}
                            <span>{action.text}</span>
                        </button>
                    ))}
                </div>
            </div>

            {/* Chat Messages */}
            <div className="chat-messages" ref={scrollAreaRef}>
                {messages.map((message) => (
                    <div key={message.id} className={`chat-message-row ${message.type === 'user' ? 'user' : 'ai'}`}>
                        <div className="chat-message-avatar">
                            {message.type === 'ai' ? (
                                <div className="chat-avatar ai"><Bot className="chat-avatar-icon" /></div>
                            ) : (
                                <div className="chat-avatar user"><User className="chat-avatar-icon" /></div>
                            )}
                        </div>
                        <div className="chat-message-bubble">
                            <div className="chat-message-content">{message.content}</div>
                            <div className="chat-message-time">{formatTime(message.timestamp)}</div>
                        </div>
                    </div>
                ))}
                {isTyping && (
                    <div className="chat-message-row ai">
                        <div className="chat-message-avatar">
                            <div className="chat-avatar ai"><Bot className="chat-avatar-icon" /></div>
                        </div>
                        <div className="chat-message-bubble">
                            <div className="chat-message-typing">
                                <span className="typing-dot"></span>
                                <span className="typing-dot"></span>
                                <span className="typing-dot"></span>
                            </div>
                        </div>
                    </div>
                )}
            </div>

            {/* Message Input */}
            <div className="chat-input-row">
                <input
                    className="chat-input"
                    placeholder="Ask me about your cycle, patterns, or how you're feeling..."
                    value={newMessage}
                    onChange={(e) => setNewMessage(e.target.value)}
                    onKeyDown={handleKeyPress}
                />
                <button
                    className="chat-send-btn"
                    onClick={sendMessage}
                    disabled={!newMessage.trim() || isTyping}
                    type="button"
                >
                    <Send className="chat-send-icon" />
                </button>
            </div>

            {/* Context Info */}
            <div className="chat-context">
                <div><strong>Current Context:</strong> Day {currentCycle.currentDay} • {currentCycle.phase} phase</div>
                <div><strong>Recent Entries:</strong> {journalEntries.length} journal entries available for analysis</div>
                <div className="chat-context-note">Luna can reference your specific journal entries and cycle data to provide personalized insights.</div>
            </div>
        </div>
    );
};

export default ChatInterface;