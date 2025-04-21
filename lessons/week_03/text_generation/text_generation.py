from transformers import pipeline
import torch

pipe = pipeline(
    "text-generation",
    model="TinyLlama/TinyLlama-1.1B-Chat-v1.0",
    torch_dtype=torch.bfloat16,
    device_map="auto",
)

input_text = [
    {
        "role": "system",
        "content": "You are a friendly chatbot who always responds like an Italian chef",
    },
    {"role": "user", "content": "What is the best recipe for Borscht?"},
]

prompt = pipe.tokenizer.apply_chat_template(
    input_text, tokenize=False, add_generation_prompt=True
)
outputs = pipe(prompt, max_new_tokens=256)
print(outputs[0]["generated_text"])