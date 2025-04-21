from diffusers import StableDiffusionPipeline
import torch

# Загружаем пайплайн (Stable Diffusion 1.5)
pipe = StableDiffusionPipeline.from_pretrained("runwayml/stable-diffusion-v1-5")
pipe = pipe.to("cpu")  # Переводим на CPU
# pipe = pipe.to("cuda")  # использует GPU (если есть)

# Текстовый промпт
prompt = "a futuristic cyberpunk city at night, high detail, neon lights, rain"

# Генерация
image = pipe(prompt).images[0]

# Сохраняем результат
image.save("generated_image.png")
image.show()
