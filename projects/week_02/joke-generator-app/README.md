# Joke Generator App

## Overview

The Joke Generator is an AI-powered web application that creates custom jokes based on user-selected parameters. Users can specify the topic, tone, and type of joke they want, and the application will generate a joke using OpenAI's GPT model. Additionally, the app features an AI-powered evaluation system that rates the generated jokes on various criteria.

## Features

### Joke Generation

- **Customizable Parameters**: Users can select from various options:
  - **Topics**: Work, people, animals, food, television
  - **Tones**: Witty, sarcastic, silly, dark, goofy
  - **Types**: Pun, knock-knock, story
- **Creativity Control**: Adjust the "temperature" parameter to control how creative or predictable the jokes are
- **Real-time Generation**: Jokes are generated on-demand with a user-friendly loading state

### Joke Evaluation

- **AI-Powered Analysis**: Each joke can be evaluated by AI on multiple criteria:
  - **Funny**: How humorous the joke is (1-10)
  - **Appropriate**: How suitable it is for general audiences (1-10)
  - **Offensive**: Likelihood of offending various groups (1-10, lower is better)
  - **Originality**: How original the joke is (1-10)
  - **Delivery**: Quality of the joke's structure and flow (1-10)
- **Visual Feedback**: Color-coded ratings make it easy to quickly assess the joke's quality
- **Detailed Comments**: Specific feedback is provided for each criterion

### User Interface

- **Modern Design**: Dark theme with accent colors for better readability
- **Responsive Layout**: Works well on both desktop and mobile devices
- **Intuitive Controls**: Clear labels and interactive elements
- **Visual Hierarchy**: Important information is emphasized through sizing and color

## Technology Stack

- **Frontend**: React, TypeScript, Tailwind CSS
- **Backend**: Next.js API routes (serverless functions)
- **AI Integration**: OpenAI GPT API
- **Deployment**: Vercel (recommended)

## Getting Started

### Prerequisites

- Node.js (version 18.18.0 or later)
- An OpenAI API key

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```
3. Create a `.env.local` file in the root directory with your OpenAI API key:
   ```
   OPENAI_API_KEY=your_api_key_here
   ```

### Running the App

```bash
npm run dev
```

Navigate to `http://localhost:3000` to use the application.

## Usage

1. Select a topic, tone, and joke type from the dropdown menus
2. Adjust the creativity slider if desired
3. Click "Generate Joke" to create a new joke
4. Once a joke is generated, you can click "Evaluate This Joke" to get AI feedback
5. The evaluation will display with ratings and comments for each criterion

## License

MIT

## Acknowledgments

- Built with OpenAI's API
- Created as part of the AI Bootcamp Week 2 Project
