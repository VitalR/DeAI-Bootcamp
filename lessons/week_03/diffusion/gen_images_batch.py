import os
from diffusers import StableDiffusionPipeline
import torch

# Список промптов
prompts = [
    "a cyberpunk city at night, neon lights, high detail",
    "a fantasy landscape with dragons and floating islands",
    "a cat astronaut floating in space, cartoon style",
    "a medieval village in the morning fog",
    "futuristic AI robot reading a book in a library"
]

# Убедимся, что директория для вывода есть
output_dir = "output"
os.makedirs(output_dir, exist_ok=True)

# Загрузка пайплайна
print("⏳ Loading model...")
pipe = StableDiffusionPipeline.from_pretrained("runwayml/stable-diffusion-v1-5")
pipe = pipe.to("cpu")  # используем CPU
print("✅ Model loaded.")

# Генерация изображений
for idx, prompt in enumerate(prompts, start=1):
    print(f"🎨 Generating image {idx}/{len(prompts)}: \"{prompt}\"")
    image = pipe(prompt, num_inference_steps=30).images[0]  # можно уменьшить шаги на CPU
    image_path = os.path.join(output_dir, f"img_{idx}.png")
    image.save(image_path)
    print(f"✅ Saved to {image_path}")

print("\n🏁 Done generating all images!")
