## 🧑‍🍳 AI Chef GPT – Your Virtual Cooking Assistant

Welcome to AI Chef GPT, a smart virtual chef that helps you cook delicious meals! Whether you need dish suggestions based on ingredients, detailed recipes, or recipe critiques and improvements, AI Chef GPT is here to assist you.

📌 Features

✅ Choose from multiple chef personalities, each with a unique style

✅ Get dish suggestions based on available ingredients

✅ Request detailed step-by-step recipes for specific dishes

✅ Receive constructive critiques and improvement suggestions for your recipes

✅ Uses OpenAI’s API to generate intelligent and context-aware responses

🚀 Getting Started

1️⃣ Install Dependencies

Make sure you have Python 3.7+ installed. Then, set up your environment:

### Clone this repository
```bash
git clone <repo_link>
```

### Navigate to the project folder
```bash
cd lesson_04_ai_chef_project
```

### Create a virtual environment
```bash
python3 -m venv venv
```

### Activate the virtual environment
```bash
source venv/bin/activate  # Mac/Linux
venv\Scripts\activate  # Windows
```

### Install required dependencies
```bash
pip install -r requirements.txt
```

2️⃣ Set Up Your API Key
This project requires an OpenAI API Key to function.

Create a .env file in the project directory:
```bash
touch .env
```

Add your API key inside .env:
```bash
OPENAI_API_KEY=your_api_key_here
```

3️⃣ Run the AI Chef

Start the interactive AI Chef by running:

```bash
python3 ai_chef_gpt.py
```

You'll be asked to choose a chef personality, and then you can start interacting! 🎉

### 🍽️ How to Use

Once the AI Chef is running, select an option: 

1️⃣ Ingredient-Based Dish Suggestions → AI suggests dish names (no full recipes).

2️⃣ Request a Recipe for a Specific Dish → Get a detailed recipe with preparation steps.

3️⃣ Recipe Critique & Improvements → AI analyzes a given recipe and suggests improvements.

4️⃣ Exit → Close the program.

👨‍🍳 Available Chef Personalities

| Chef Name | Specialty |
| :--- | :--- |
| Raj | Indian cuisine, expert in Biryani & spices |
| Giovanni | Traditional Italian pasta & sauces |
| Vovó Maria | Brazilian grandma, home-style comfort food |
| Chef Pierre | French fine dining, strict technique |
| Big Tex | American BBQ pitmaster, smoked meats |
| Neo-Chef | Futuristic AI, molecular gastronomy |
| Zen Master Hideo | Mindful cooking, balance & simplicity |

Each chef brings unique expertise, cooking techniques, and personality to their responses! 🎭🍲

🔧 Troubleshooting

If ModuleNotFoundError: 
No module named 'dotenv', run:
```bash
pip install python-dotenv
```
If OpenAI API issues occur, verify your API key is set correctly in .env.

If other dependency errors occur, reinstall everything:
```bash
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

📜 License
This project is open-source and free to use. Feel free to modify and extend it! 🎉