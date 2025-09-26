import React, { useState } from 'react';
import './PatternInsights.css';
import { TrendingUp, Activity, Calendar, PieChart, Heart, Zap, Cloud, Target, Clock } from 'lucide-react';

const PatternInsights = () => {
  const [activeTab, setActiveTab] = useState('mood-trends');

  // Mock data based on your screenshots
  const moodTrendsData = [
    { day: 1, mood: 3, energy: 2 },
    { day: 3, mood: 2, energy: 2 },
    { day: 5, mood: 3, energy: 3 },
    { day: 8, mood: 4, energy: 4 },
    { day: 10, mood: 5, energy: 5 },
    { day: 12, mood: 4, energy: 4 },
    { day: 14, mood: 5, energy: 5 },
    { day: 16, mood: 4, energy: 4 },
    { day: 18, mood: 3, energy: 3 },
    { day: 21, mood: 2, energy: 2 },
    { day: 24, mood: 2, energy: 2 },
    { day: 26, mood: 3, energy: 3 },
    { day: 28, mood: 2, energy: 2 }
  ];

  const symptomsData = [
    { symptom: 'Breast Tenderness', frequency: 6, severity: 3.2 },
    { symptom: 'Acne', frequency: 5, severity: 2.8 },
    { symptom: 'Fatigue', frequency: 4, severity: 3.5 },
    { symptom: 'Mood Swings', frequency: 4, severity: 3.8 },
    { symptom: 'Headache', frequency: 3, severity: 2.5 },
    { symptom: 'Bloating', frequency: 3, severity: 3.0 },
    { symptom: 'Cramps', frequency: 2, severity: 4.2 }
  ];

  const phaseSymptoms = [
    {
      phase: 'Menstrual',
      symptoms: ['Cramps (75%)', 'Fatigue (60%)', 'Lower back pain (40%)'],
      color: '#ef4444'
    },
    {
      phase: 'Follicular', 
      symptoms: ['High energy (80%)', 'Clear skin (65%)', 'Good mood (70%)'],
      color: '#10b981'
    },
    {
      phase: 'Ovulatory',
      symptoms: ['Peak energy (85%)', 'Mild bloating (30%)', 'Increased libido (70%)'],
      color: '#f59e0b'
    },
    {
      phase: 'Luteal',
      symptoms: ['Bloating (80%)', 'Mood swings (65%)', 'Breast tenderness (55%)'],
      color: '#8b5cf6'
    }
  ];

  const correlationData = [
    { factor: 'Sleep Quality', mood: 4.0, energy: 4.2, symptoms: -3.5 },
    { factor: 'Exercise', mood: 3.8, energy: 4.5, symptoms: -3.2 },
    { factor: 'Stress', mood: -4.2, energy: -3.8, symptoms: 4.5 },
    { factor: 'Caffeine', mood: -2.5, energy: 1.8, symptoms: 2.2 },
    { factor: 'Water Intake', mood: 2.0, energy: 2.5, symptoms: -2.8 }
  ];

  const cycleHealthData = [
    { metric: 'Regularity', score: 8.2, max: 10 },
    { metric: 'Symptom Management', score: 8, max: 10 },
    { metric: 'Mood Stability', score: 7, max: 10 },
    { metric: 'Overall Health Score', score: 9, max: 10 }
  ];

  const keyCorrelations = [
    {
      title: 'Sleep Quality',
      description: 'Strong positive impact on mood and energy',
      impact: 'Strong Positive',
      icon: Heart
    },
    {
      title: 'Exercise',
      description: 'Consistently improves mood and reduces symptoms',
      impact: 'Positive',
      icon: Zap
    },
    {
      title: 'Stress',
      description: 'Major factor in symptom severity',
      impact: 'Strong Negative',
      icon: Cloud
    }
  ];

  const formatCorrelationValue = (value: number) => {
    return value > 0 ? `+${value.toFixed(1)}` : value.toFixed(1);
  };

  const getCorrelationColor = (value: number) => {
    if (value >= 3) return '#22c55e';
    if (value >= 1) return '#86efac';
    if (value <= -3) return '#ef4444';
    if (value <= -1) return '#fca5a5';
    return '#6b7280';
  };

  return (
    <div className="moodviz-container">
      {/* Pattern Insights Tabs */}
      <div className="pattern-tabs">
        <button 
          className={`pattern-tab-btn ${activeTab === 'mood-trends' ? 'active' : ''}`}
          onClick={() => setActiveTab('mood-trends')}
        >
          <TrendingUp className="pattern-tab-icon" />
          Mood Trends
        </button>
        <button 
          className={`pattern-tab-btn ${activeTab === 'symptoms' ? 'active' : ''}`}
          onClick={() => setActiveTab('symptoms')}
        >
          <Activity className="pattern-tab-icon" />
          Symptoms
        </button>
        <button 
          className={`pattern-tab-btn ${activeTab === 'cycle-health' ? 'active' : ''}`}
          onClick={() => setActiveTab('cycle-health')}
        >
          <Calendar className="pattern-tab-icon" />
          Cycle Health
        </button>
        <button 
          className={`pattern-tab-btn ${activeTab === 'correlations' ? 'active' : ''}`}
          onClick={() => setActiveTab('correlations')}
        >
          <PieChart className="pattern-tab-icon" />
          Correlations
        </button>
      </div>

      {/* Mood Trends Section */}
      {activeTab === 'mood-trends' && (
        <div className="pattern-section">
          <div className="pattern-card">
            <div className="pattern-card-title">Mood & Energy Throughout Cycle</div>
            <div className="pattern-chart">
              {/* Chart would go here - using mock data visualization */}
              <div className="mock-chart">
                <div className="chart-y-axis">
                  <span>5</span>
                  <span>4</span>
                  <span>3</span>
                  <span>2</span>
                  <span>1</span>
                </div>
                <div className="chart-bars">
                  {moodTrendsData.map((data, index) => (
                    <div key={index} className="chart-bar-group">
                      <div 
                        className="chart-bar mood-bar" 
                        style={{ height: `${data.mood * 20}%` }}
                      ></div>
                      <div 
                        className="chart-bar energy-bar" 
                        style={{ height: `${data.energy * 20}%` }}
                      ></div>
                      <span className="chart-day">{data.day}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
          
          <div className="pattern-insights-row">
            <div className="pattern-insight-card green">
              <div className="pattern-insight-title">Peak Energy</div>
              <div className="pattern-insight-phase">Days 8-14 (Follicular/Ovulatory)</div>
              <div className="pattern-insight-desc">Best time for important tasks</div>
            </div>
            <div className="pattern-insight-card yellow">
              <div className="pattern-insight-title">Mood Dips</div>
              <div className="pattern-insight-phase">Days 21-26 (Late Luteal)</div>
              <div className="pattern-insight-desc">Plan extra self-care</div>
            </div>
            <div className="pattern-insight-card purple">
              <div className="pattern-insight-title">Recovery</div>
              <div className="pattern-insight-phase">Days 5-7 (Late Menstrual)</div>
              <div className="pattern-insight-desc">Mood starts improving</div>
            </div>
          </div>
        </div>
      )}

      {/* Symptoms Section */}
      {activeTab === 'symptoms' && (
        <div className="pattern-section">
          <div className="symptoms-grid">
            <div className="symptoms-card">
              <h3 className="symptoms-title">Most Common Symptoms</h3>
              <div className="symptoms-list">
                {symptomsData.map((symptom, index) => (
                  <div key={index} className="symptom-item">
                    <span className="symptom-name">{symptom.symptom}</span>
                    <div className="symptom-frequency">
                      <div 
                        className="frequency-bar"
                        style={{ width: `${(symptom.frequency / 6) * 100}%` }}
                      ></div>
                    </div>
                    <span className="symptom-count">{symptom.frequency}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="phase-symptoms-card">
              <h3 className="symptoms-title">Symptom Patterns by Phase</h3>
              <div className="phase-grid">
                {phaseSymptoms.map((phase, index) => (
                  <div key={index} className="phase-column">
                    <h4 className="phase-title" style={{ color: phase.color }}>
                      {phase.phase}
                    </h4>
                    <ul className="phase-symptoms-list">
                      {phase.symptoms.map((symptom, sIndex) => (
                        <li key={sIndex} className="phase-symptom">
                          {symptom}
                        </li>
                      ))}
                    </ul>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Correlations Section */}
      {activeTab === 'correlations' && (
        <div className="pattern-section">
          <div className="correlations-grid">
            <div className="correlations-card">
              <h3 className="correlations-title">Lifestyle Factor Correlations</h3>
              <div className="correlations-table">
                <div className="table-header">
                  <span>Factor</span>
                  <span>Mood</span>
                  <span>Energy</span>
                  <span>Symptoms</span>
                </div>
                {correlationData.map((item, index) => (
                  <div key={index} className="table-row">
                    <span className="factor-name">{item.factor}</span>
                    <span 
                      className="correlation-value"
                      style={{ color: getCorrelationColor(item.mood) }}
                    >
                      {formatCorrelationValue(item.mood)}
                    </span>
                    <span 
                      className="correlation-value"
                      style={{ color: getCorrelationColor(item.energy) }}
                    >
                      {formatCorrelationValue(item.energy)}
                    </span>
                    <span 
                      className="correlation-value"
                      style={{ color: getCorrelationColor(item.symptoms) }}
                    >
                      {formatCorrelationValue(item.symptoms)}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            <div className="key-correlations-card">
              <h3 className="correlations-title">Key Correlations</h3>
              <div className="key-correlations-list">
                {keyCorrelations.map((correlation, index) => {
                  const Icon = correlation.icon;
                  return (
                    <div key={index} className="key-correlation-item">
                      <div className="correlation-header">
                        <Icon className="correlation-icon" />
                        <span className="correlation-factor">{correlation.title}</span>
                        <span className={`correlation-impact ${correlation.impact.toLowerCase().includes('positive') ? 'positive' : 'negative'}`}>
                          {correlation.impact}
                        </span>
                      </div>
                      <p className="correlation-desc">{correlation.description}</p>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Cycle Health Section */}
      {activeTab === 'cycle-health' && (
        <div className="pattern-section">
          <div className="cycle-health-grid">
            <div className="health-scores-card">
              <h3 className="health-title">Cycle Health Score</h3>
              <div className="health-scores">
                {cycleHealthData.map((health, index) => (
                  <div key={index} className="health-score-item">
                    <div className="health-score-header">
                      <span className="health-metric">{health.metric}</span>
                      <span className="health-value">{health.score}/10</span>
                    </div>
                    <div className="health-progress-bar">
                      <div 
                        className="health-progress-fill"
                        style={{ width: `${(health.score / health.max) * 100}%` }}
                      ></div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="cycle-stats-card">
              <h3 className="health-title">Cycle Statistics</h3>
              <div className="cycle-stats">
                <div className="stat-item">
                  <Target className="stat-icon" />
                  <div className="stat-info">
                    <span className="stat-value">28-32</span>
                    <span className="stat-label">Cycle Length Range</span>
                  </div>
                </div>
                <div className="stat-item">
                  <Clock className="stat-icon" />
                  <div className="stat-info">
                    <span className="stat-value">5-7</span>
                    <span className="stat-label">Period Duration</span>
                  </div>
                </div>
                <div className="stat-item">
                  <Activity className="stat-icon" />
                  <div className="stat-info">
                    <span className="stat-value">85%</span>
                    <span className="stat-label">Regularity Score</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default PatternInsights;