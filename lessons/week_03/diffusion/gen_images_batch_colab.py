"""
How to use this in Google Colab:

1. Go to: https://colab.research.google.com/
2. Paste this entire code into a code cell
3. Upload a `prompts.txt` file with one prompt per line (or edit the default list)
4. Go to: Runtime → Change runtime type → Select GPU
5. Click ▶️ and wait for the images to be generated
6. A ZIP file will be available for download at the end
"""

# 🧱 Install dependencies
!pip install -q diffusers==0.25.0 transformers==4.39.3 torch torchvision accelerate huggingface_hub==0.19.4 numpy<2.0

from diffusers import StableDiffusionPipeline
import torch
import os
from zipfile import ZipFile
from PIL import Image

# 📌 Try to load prompts from file if available
prompts = []
if os.path.exists("prompts.txt"):
    with open("prompts.txt", "r", encoding="utf-8") as f:
        prompts = [line.strip() for line in f if line.strip()]
    print(f"📄 Loaded {len(prompts)} prompts from prompts.txt")
else:
    # fallback list
    prompts = [
        "a futuristic city skyline at sunset, high detail",
        "a dragon flying above the clouds",
        "a cat reading a book in a cozy library",
        "a cyberpunk samurai in a rainy alley",
        "a peaceful forest with glowing mushrooms"
    ]
    print("✍️ Using hardcoded prompt list")

# 💻 Set device
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"🚀 Using device: {device}")

# 🔄 Load model
pipe = StableDiffusionPipeline.from_pretrained("runwayml/stable-diffusion-v1-5")
pipe = pipe.to(device)
pipe.enable_attention_slicing()

# 📁 Prepare output directory
output_dir = "output"
os.makedirs(output_dir, exist_ok=True)

# 🎨 Generate images
for idx, prompt in enumerate(prompts, 1):
    print(f"[{idx}/{len(prompts)}] Generating: {prompt}")
    image = pipe(prompt, num_inference_steps=30).images[0]
    image_path = os.path.join(output_dir, f"image_{idx}.png")
    image.save(image_path)

# 🗜️ Create zip archive
zip_filename = "generated_images.zip"
with ZipFile(zip_filename, "w") as zipf:
    for filename in os.listdir(output_dir):
        zipf.write(os.path.join(output_dir, filename), arcname=filename)

print(f"\n✅ All images saved to '{output_dir}/' and zipped to '{zip_filename}'")
