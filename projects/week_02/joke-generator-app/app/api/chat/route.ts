// api/chat/route.ts
import OpenAI from 'openai';
import { NextResponse } from 'next/server';

export const runtime = 'edge';

// This runs on the server only
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

export async function POST(req: Request) {
  try {
    const { topic, tone, type, temperature } = await req.json();

    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      temperature: temperature || 0.7,
      messages: [
        {
          role: 'system',
          content: `You are a joke generator. Create a ${type} joke about ${topic} with a ${tone} tone.`,
        },
      ],
    });

    // Get the content from the response
    const content =
      response.choices[0]?.message?.content || 'No joke generated.';

    return NextResponse.json({ content });
  } catch (error) {
    console.error('Error generating joke:', error);
    return NextResponse.json(
      { error: 'Failed to generate joke' },
      { status: 500 }
    );
  }
}

// New API route for evaluating jokes
export async function PUT(req: Request) {
  try {
    const { joke } = await req.json();

    if (!joke) {
      return NextResponse.json(
        { error: 'No joke provided for evaluation' },
        { status: 400 }
      );
    }

    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      temperature: 0.7,
      messages: [
        {
          role: 'system',
          content: `You are a professional joke evaluator. Analyze the following joke and provide a structured evaluation with specific ratings and comments on these exact criteria:

1. Funny: Rate from 1-10 how humorous the joke is
2. Appropriate: Rate from 1-10 how suitable the joke is for general audiences
3. Offensive: Rate from 1-10 how likely the joke is to offend certain groups (1 = not offensive, 10 = highly offensive)
4. Originality: Rate from 1-10 how original the joke is
5. Delivery: Rate from 1-10 how well the joke is structured and delivered

Format your response as:
[Criteria]: [Rating]/10 - [Brief comment]

Then provide a 2-3 sentence overall assessment at the end.`,
        },
        {
          role: 'user',
          content: joke,
        },
      ],
    });

    const evaluation =
      response.choices[0]?.message?.content || 'Unable to evaluate the joke.';

    return NextResponse.json({ evaluation });
  } catch (error) {
    console.error('Error evaluating joke:', error);
    return NextResponse.json(
      { error: 'Failed to evaluate joke' },
      { status: 500 }
    );
  }
}
