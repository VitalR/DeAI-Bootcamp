'use client';

import React, { useState } from 'react';

function JokeGenerator() {
  const [topic, setTopic] = useState('');
  const [tone, setTone] = useState('');
  const [type, setType] = useState('');
  const [temperature, setTemperature] = useState(0.5);
  const [joke, setJoke] = useState('');
  const [evaluation, setEvaluation] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isEvaluating, setIsEvaluating] = useState(false);

  const handleGenerateJoke = async () => {
    setIsLoading(true);
    setEvaluation(''); // Clear previous evaluation

    try {
      // Call the API route
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ topic, tone, type, temperature }),
      });

      if (!response.ok) {
        throw new Error('Failed to generate joke');
      }

      const data = await response.json();
      setJoke(data.content);
    } catch (error) {
      console.error('Error:', error);
      setJoke('Failed to generate joke. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleEvaluateJoke = async () => {
    if (!joke) return;

    setIsEvaluating(true);

    try {
      const response = await fetch('/api/chat', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ joke }),
      });

      if (!response.ok) {
        throw new Error('Failed to evaluate joke');
      }

      const data = await response.json();
      setEvaluation(data.evaluation);
    } catch (error) {
      console.error('Error:', error);
      setEvaluation('Failed to evaluate joke. Please try again.');
    } finally {
      setIsEvaluating(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 to-gray-800 text-white p-6">
      <div className="max-w-4xl mx-auto bg-gray-800 rounded-xl shadow-2xl p-8 border border-gray-700">
        <h1 className="text-4xl font-bold mb-8 text-center text-yellow-400">
          Joke Generator
        </h1>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          <div className="mb-4">
            <label className="block mb-2 text-lg font-medium">Topic:</label>
            <select
              className="w-full p-3 bg-gray-700 text-white border border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500"
              value={topic}
              onChange={(e) => setTopic(e.target.value)}
            >
              <option value="">Select a topic</option>
              <option value="work">Work</option>
              <option value="people">People</option>
              <option value="animals">Animals</option>
              <option value="food">Food</option>
              <option value="television">Television</option>
            </select>
          </div>
          <div className="mb-4">
            <label className="block mb-2 text-lg font-medium">Tone:</label>
            <select
              className="w-full p-3 bg-gray-700 text-white border border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500"
              value={tone}
              onChange={(e) => setTone(e.target.value)}
            >
              <option value="">Select a tone</option>
              <option value="witty">Witty</option>
              <option value="sarcastic">Sarcastic</option>
              <option value="silly">Silly</option>
              <option value="dark">Dark</option>
              <option value="goofy">Goofy</option>
            </select>
          </div>
          <div className="mb-4">
            <label className="block mb-2 text-lg font-medium">Type:</label>
            <select
              className="w-full p-3 bg-gray-700 text-white border border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500"
              value={type}
              onChange={(e) => setType(e.target.value)}
            >
              <option value="">Select a type</option>
              <option value="pun">Pun</option>
              <option value="knock-knock">Knock-Knock</option>
              <option value="story">Story</option>
            </select>
          </div>
          <div className="mb-4">
            <label className="block mb-2 text-lg font-medium">
              Creativity: {temperature}
            </label>
            <input
              type="range"
              min="0"
              max="1"
              step="0.1"
              value={temperature}
              onChange={(e) => setTemperature(parseFloat(e.target.value))}
              className="w-full h-2 bg-gray-700 rounded-lg appearance-none cursor-pointer"
            />
            <div className="flex justify-between text-xs mt-1">
              <span>Predictable</span>
              <span>Creative</span>
            </div>
          </div>
        </div>

        <div className="text-center mb-8">
          <button
            onClick={handleGenerateJoke}
            disabled={isLoading || !topic || !tone || !type}
            className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-8 rounded-full disabled:opacity-50 transition-all duration-200 text-lg shadow-lg"
          >
            {isLoading ? 'Generating...' : 'Generate Joke'}
          </button>
        </div>

        {joke && (
          <div className="bg-white dark:bg-gray-700 p-6 rounded-lg shadow-lg border border-gray-600 mb-6">
            <h2 className="text-2xl font-bold mb-4 text-yellow-400">
              Your Joke:
            </h2>
            <p className="whitespace-pre-line text-white text-lg leading-relaxed">
              {joke}
            </p>

            <div className="mt-6 text-center">
              <button
                onClick={handleEvaluateJoke}
                disabled={isEvaluating}
                className="bg-purple-600 hover:bg-purple-700 text-white font-bold py-2 px-6 rounded-full disabled:opacity-50 transition-all duration-200 text-md shadow-lg"
              >
                {isEvaluating ? 'Evaluating...' : 'Evaluate This Joke'}
              </button>
            </div>
          </div>
        )}

        {evaluation && (
          <div className="bg-gray-700 p-6 rounded-lg shadow-lg border border-gray-600">
            <h2 className="text-2xl font-bold mb-4 text-yellow-400">
              Joke Evaluation:
            </h2>

            <div className="space-y-3">
              {evaluation.split('\n').map((line, index) => {
                // Check if this is a criteria line
                if (line.includes('/10')) {
                  const [criteria, comment] = line.split(' - ');
                  if (criteria && comment) {
                    const [criteriaName, rating] = criteria.split(':');

                    // Calculate color based on rating
                    let ratingColor = 'text-gray-300';
                    if (
                      criteriaName.includes('Funny') ||
                      criteriaName.includes('Appropriate') ||
                      criteriaName.includes('Originality') ||
                      criteriaName.includes('Delivery')
                    ) {
                      const ratingNum = parseInt(rating.trim().split('/')[0]);
                      if (ratingNum >= 8) ratingColor = 'text-green-400';
                      else if (ratingNum >= 5) ratingColor = 'text-yellow-400';
                      else ratingColor = 'text-red-400';
                    } else if (criteriaName.includes('Offensive')) {
                      const ratingNum = parseInt(rating.trim().split('/')[0]);
                      if (ratingNum <= 3) ratingColor = 'text-green-400';
                      else if (ratingNum <= 6) ratingColor = 'text-yellow-400';
                      else ratingColor = 'text-red-400';
                    }

                    return (
                      <div key={index} className="mb-2">
                        <div className="flex justify-between items-center">
                          <span className="font-bold text-md">
                            {criteriaName}:
                          </span>
                          <span
                            className={`font-mono font-bold ${ratingColor}`}
                          >
                            {rating.trim()}
                          </span>
                        </div>
                        <p className="text-white">{comment}</p>
                      </div>
                    );
                  }
                }

                // Regular line (overall assessment)
                return (
                  <p key={index} className="text-white text-lg">
                    {line}
                  </p>
                );
              })}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default JokeGenerator;
