from transformers import pipeline
import sys

classifier = pipeline("sentiment-analysis")

# Check if command line argument is provided
if len(sys.argv) > 1:
    text = sys.argv[1]
else:
    text = input("Please enter the text to analyze: ")

result = classifier(text)[0]

print(
    f"The text \"{text}\" was classified as {result['label']} with a score of {round(result['score'], 4) * 100}%"
)

# python3 SentimentAnalysisExampleV1.py "I love this amazing product!"