import io
import json
import torch
import torch.nn as nn
import cv2
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
from torchvision import models

app = Flask(__name__)
CORS(app)

# Load classes: 0-9 and A-Z
with open('classes.json', 'r') as f:
    class_names = json.load(f)

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Rebuild model architecture (MobileNetV2)
model = models.mobilenet_v2(weights=None)

# Detect architecture from weights
state_dict = torch.load('sign_model.pth', map_location=device, weights_only=True)
if 'classifier.1.weight' in state_dict:
    # Old simple architecture
    model.classifier[1] = nn.Linear(model.classifier[1].in_features, len(class_names))
else:
    # New Sequential architecture
    model.classifier[1] = nn.Sequential(
        nn.Linear(model.classifier[1].in_features, 512),
        nn.ReLU(),
        nn.Dropout(0.3),
        nn.Linear(512, len(class_names))
    )

# Load weights and force Float32 to fix Double/Float RuntimeError
model.load_state_dict(state_dict)
model = model.to(device).float() 
model.eval()

def preprocess_opencv(image_bytes):
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, (224, 224))
    
    # Normalize to match PyTorch training standards
    img = img.astype(np.float32) / 255.0
    img = (img - [0.485, 0.456, 0.406]) / [0.229, 0.224, 0.225]
    img = np.transpose(img, (2, 0, 1))
    
    # Ensure explicit .float() conversion
    return torch.from_numpy(img).unsqueeze(0).to(device).float()

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image'}), 400
    try:
        file = request.files['image'].read()
        input_tensor = preprocess_opencv(file)
        with torch.no_grad():
            outputs = model(input_tensor)
            prob = torch.nn.functional.softmax(outputs[0], dim=0)
            conf, idx = torch.max(prob, 0)
        return jsonify({
            'character': class_names[idx.item()],
            'confidence': float(conf.item())
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("🚀 Flask AI Server running on http://0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000, debug=False)