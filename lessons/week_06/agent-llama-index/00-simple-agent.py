from llama_index.core.tools import FunctionTool
from llama_index.llms.openai import OpenAI
from llama_index.core.agent import ReActAgent

# Define the function
def multiply(a: int, b: int) -> int:
 """Multiply two integers and returns the result integer"""
 return a * b

# Define and configure the agent
multiply_tool = FunctionTool.from_defaults(fn=multiply)
llm = OpenAI(model="gpt-4o-mini")
agent = ReActAgent.from_tools([multiply_tool], llm=llm, verbose=True)

# Test the agent
agent.chat("What is 123 * (1 + 2 + 3)?")

# Run the agent
# python3 00-simple-agent.py