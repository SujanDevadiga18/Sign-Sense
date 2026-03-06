import os
import json
import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, transforms, models
from torch.utils.data import DataLoader, Subset
from sklearn.model_selection import train_test_split

# 1. Setup & Security Bypass
os.environ['TORCH_HOME'] = './models_cache'
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# 2. Enhanced Data Augmentation
# This teaches the AI to handle different hand tilts and lighting
train_transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.RandomRotation(20), 
    transforms.ColorJitter(brightness=0.3, contrast=0.3),
    transforms.RandomHorizontalFlip(),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

# 3. Load and Split Dataset (80% Train, 20% Validation)
full_dataset = datasets.ImageFolder('dataset', transform=train_transform)
class_names = full_dataset.classes
with open('classes.json', 'w') as f:
    json.dump(class_names, f)

indices = list(range(len(full_dataset)))
train_idx, val_idx = train_test_split(indices, test_size=0.2, stratify=full_dataset.targets)

train_loader = DataLoader(Subset(full_dataset, train_idx), batch_size=32, shuffle=True)
val_loader = DataLoader(Subset(full_dataset, val_idx), batch_size=32, shuffle=False)

# 4. Model Fine-Tuning (MobileNetV2)
model = models.mobilenet_v2(weights=models.MobileNet_V2_Weights.DEFAULT)

# Freeze base layers, but unfreeze the last few for specialized learning
for param in model.features[:-3].parameters():
    param.requires_grad = False

model.classifier[1] = nn.Sequential(
    nn.Linear(model.classifier[1].in_features, 512),
    nn.ReLU(),
    nn.Dropout(0.3), # Prevents overfitting
    nn.Linear(512, len(class_names))
)
model = model.to(device)

# 5. Optimization with Learning Rate Decay
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.0001)
scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, 'min', patience=2)

# 6. Training Loop (10 Epochs for better convergence)
print(f"🚀 Training on {len(class_names)} classes...")
for epoch in range(10):
    model.train()
    for inputs, labels in train_loader:
        inputs, labels = inputs.to(device), labels.to(device)
        optimizer.zero_grad(); outputs = model(inputs)
        loss = criterion(outputs, labels); loss.backward(); optimizer.step()

    # Validation
    model.eval(); val_acc = 0; val_loss = 0
    with torch.no_grad():
        for inputs, labels in val_loader:
            inputs, labels = inputs.to(device), labels.to(device)
            outputs = model(inputs)
            val_loss += criterion(outputs, labels).item()
            _, preds = torch.max(outputs, 1)
            val_acc += torch.sum(preds == labels.data)

    acc = val_acc.double() / len(val_idx)
    scheduler.step(val_loss/len(val_loader))
    print(f"Epoch {epoch+1}/10 | Validation Accuracy: {acc:.2%}")

torch.save(model.state_dict(), 'sign_model.pth')
print("🎉 Enhanced model saved!")