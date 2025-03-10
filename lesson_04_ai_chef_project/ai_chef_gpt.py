import os
from dotenv import load_dotenv
from openai import OpenAI

# Load environment variables from .env file
load_dotenv()

# Retrieve API key
api_key = os.getenv("OPENAI_API_KEY")

# Initialize OpenAI client
client = OpenAI(api_key=api_key)

# User selects a chef personality
print("\n🌟 Choose your AI Chef's personality:")
chefs = {
    "1": "Raj, a young, enthusiastic Indian chef specializing in Biryani. You are passionate about spices and know every regional variety of Biryani by heart. You love giving side dish and drink pairings.",
    "2": "Giovanni, a seasoned Italian chef with a deep love for pasta-making. You emphasize fresh ingredients, homemade sauces, and traditional Italian methods. Your recipes are full of nostalgia and warmth.",
    "3": "Vovó Maria, an old Brazilian grandma who loves traditional dishes. You always have heartwarming stories to share with your recipes, making cooking a nostalgic experience.",
    "4": "Chef Pierre, a strict French culinary instructor who demands precision. You take cooking seriously and will guide users to achieve perfection in their dishes.",
    "5": "Big Tex, a friendly American BBQ pitmaster who loves smoked meats and grilling. You provide expert tips on BBQ, rubs, and marinades.",
    "6": "Neo-Chef, a futuristic AI chef from 2077. You use molecular gastronomy techniques and high-tech precision cooking methods.",
    "7": "Zen Master Hideo, a Buddhist monk who believes in mindful cooking. Your recipes focus on balance, simplicity, and nourishment."
}

# Display chef choices
for num, desc in chefs.items():
    print(f"{num} - {desc.split('.')[0]}")

# User selects a chef
choice = input("\nEnter the number corresponding to your preferred chef: ")
selected_chef = chefs.get(choice, chefs["2"])  # Default to Italian chef if invalid input

# Set System Message with Chef's Personality and Instructions
system_prompt = (
    f"You are {selected_chef} "
    "Your goal is to assist users in three ways:\n"
    "1️⃣ If given a list of ingredients, suggest ONLY dish names (without full recipes).\n"
    "2️⃣ If given a dish name, provide a detailed recipe with clear preparation steps.\n"
    "3️⃣ If given a recipe, analyze it and offer constructive critique and improvement suggestions.\n"
    "If the input doesn't match any of these three cases, politely decline and guide the user to make a valid request."
)

messages = [{"role": "system", "content": system_prompt}]

# Function to interact with the AI chef
def ask_chef(prompt):
    messages.append({"role": "user", "content": prompt})
    stream = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=messages,
        stream=True,
    )
    
    collected_messages = []
    for chunk in stream:
        chunk_message = chunk.choices[0].delta.content or ""
        print(chunk_message, end="")
        collected_messages.append(chunk_message)

    messages.append({"role": "assistant", "content": "".join(collected_messages)})
    print("\n")  # Print newline for readability

# User interaction loop
while True:
    print(f"\n👨‍🍳 Hello! I am {selected_chef.split(',')[0]}. What can I do for you today?")
    print("1 - Suggest a dish based on ingredients")
    print("2 - Get a recipe for a specific dish")
    print("3 - Critique and improve a recipe")
    print("4 - Exit")

    choice = input("Enter the number of your choice: ")

    if choice == "1":
        ingredients = input("Enter ingredients you have (comma-separated): ")
        ask_chef(f"I have {ingredients}. What dishes can I make with these ingredients? Please suggest only dish names, no full recipes.")

    elif choice == "2":
        dish = input("Enter the dish name: ")
        ask_chef(f"Can you provide a detailed recipe and preparation steps for making {dish}?")

    elif choice == "3":
        recipe = input("Paste your recipe here: ")
        ask_chef(f"Here's a recipe: {recipe}. Can you critique it and suggest improvements?")

    elif choice == "4":
        print(f"Goodbye! {selected_chef.split(',')[0]} wishes you happy cooking! 🍽️")
        break

    else:
        print("Invalid choice. Please enter 1, 2, 3, or 4.")
