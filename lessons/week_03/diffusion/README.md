# 🧠 Stable Diffusion Batch Generator (Colab Edition)

Generate multiple images using text prompts with [Stable Diffusion v1.5](https://huggingface.co/runwayml/stable-diffusion-v1-5) via 🤗 Diffusers — directly in **Google Colab**, with **GPU acceleration**.

---

## 🚀 [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/VitalR/DeAI-Bootcamp/blob/main/lessons/week_03/diffusion/gen_images_batch_colab.ipynb)

---

## 📋 How to Use (in Colab)

1. Click the **“Open in Colab”** button above
2. Upload a `prompts.txt` file (optional) with one prompt per line  
   (or use the default embedded prompt list)
3. Go to **`Runtime → Change runtime type → GPU`**
4. Click ▶️ to run the cell
5. Wait for image generation to complete (~5–30s per image on GPU)
6. A `.zip` archive with all generated images will be provided for download

---

## 📄 Example `prompts.txt`

```
a cyberpunk city at night, neon lights, high detail
a peaceful forest with glowing mushrooms
a futuristic AI robot painting a sunset
a dragon flying over a medieval castle
a cozy library with a cat reading a book
```
---

## ⚙️ Under the Hood
```
StableDiffusionPipeline from 🤗 diffusers

30 denoising steps per image

GPU-accelerated with automatic CUDA support

Optional prompt loading from prompts.txt

Images saved to output/, zipped as generated_images.zip
```
---

## 📁 Output Structure
```
output/
├── image_1.png
├── image_2.png
├── ...
generated_images.zip
```