from llama_index.core import VectorStoreIndex, Settings
from llama_index.core.tools import QueryEngineTool
from llama_index.core.agent import ReActAgent
from llama_parse import LlamaParse
from llama_index.llms.openai import OpenAI
from dotenv import load_dotenv
import os

Settings.llm = OpenAI(model="gpt-4o-mini", temperature=0)

load_dotenv()
api_key = os.getenv('LLAMA_PARSE_API_KEY')
documents = LlamaParse(api_key=api_key, result_type="markdown").load_data("./zork1.pdf")
index = VectorStoreIndex.from_documents(documents)
query_engine = index.as_query_engine()

query_tool = QueryEngineTool.from_defaults(
    query_engine,
    name="Zork",
    description="A RAG engine with the Game Manual for Zork I: The Great Underground Empire.",
)

agent = ReActAgent.from_tools([query_tool], verbose=True)

agent.chat("How to play Zork?")

agent.chat("Explain a step by step on how to beat the first level of Zork.")