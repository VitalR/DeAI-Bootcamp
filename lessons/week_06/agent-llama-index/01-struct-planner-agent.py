from llama_index.core.tools import FunctionTool
from llama_index.llms.openai import OpenAI
from llama_index.core.agent import (
    StructuredPlannerAgent,
    FunctionCallingAgentWorker,
)

def multiply(a: int, b: int) -> int:
 """Multiply two integers and returns the result integer"""
 return a * b

multiply_tool = FunctionTool.from_defaults(fn=multiply)
llm = OpenAI(model="gpt-4o-mini")
worker = FunctionCallingAgentWorker.from_tools([multiply_tool], llm=llm, verbose=True)
worker_agent = StructuredPlannerAgent(worker, [multiply_tool], verbose=True)

worker_agent.chat("Solve the equation x = 123 * (x + 2y + 3)")

# python3 01-struct-planner-agent.py