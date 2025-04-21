import os
from dotenv import load_dotenv
from openai import OpenAI

# Load environment variables from .env file
load_dotenv()

# Retrieve API key
api_key = os.getenv("OPENAI_API_KEY")

# Initialize OpenAI client
client = OpenAI(api_key=api_key)

response = client.images.generate(
    model="dall-e-2",
    prompt="pizza & borscht",
    size="512x512",
    n=1,
)

print(response.data[0].url)