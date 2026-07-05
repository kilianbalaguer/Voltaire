# Model Management - User Experience Guide

## User Journey

### Starting Point
User goes to Settings → "Manage models"

### Step 1: Main Manage Models View
```
┌─────────────────────────────────────┐
│  Manage Models                   ✕  │
├─────────────────────────────────────┤
│                                     │
│  Storage Used                       │
│  ┌─────────────────────────────────┐│
│  │ Models installed      (3)       ││
│  └─────────────────────────────────┘│
│                                     │
│  Available Models                   │
│  ┌─────────────────────────────────┐│
│  │ 🧠 DeepSeek R1                  ││
│  │    Advanced reasoning models     ││
│  │                        ✓ 2 of 5 ││
│  ├─────────────────────────────────┤│
│  │ 📊 Qwen 2.5                     ││
│  │    Alibaba's language models    ││
│  │                        ✓ 1 of 3 ││
│  ├─────────────────────────────────┤│
│  │ ✨ Gemma 2                      ││
│  │    Google's efficient models    ││
│  │                        ✓ 0 of 2 ││
│  ├─────────────────────────────────┤│
│  │ 🎙️  Falcon 3                    ││
│  │    Technology Innovation Inst.   ││
│  │                        ✓ 0 of 1 ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

### Step 2: Tap on a Family (e.g., "Qwen 2.5")
```
┌─────────────────────────────────────┐
│  < Qwen 2.5              [INFO]  ✕  │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────────┐│
│  │ Qwen2.5-1.5B-Instruct-4bit    ││
│  │ 0.87 GB                         ││
│  │         ✓ Select    Delete     ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ Qwen2.5-3B-Instruct-4bit      ││
│  │ 1.2 GB                          ││
│  │           Download             ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ Qwen2.5-7B-Instruct-4bit      ││
│  │ 2.5 GB                          ││
│  │      45% ▓▓▓▓░░░░░            ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

## Model States and Actions

### State 1: NOT INSTALLED
```
Model Name (Size)
            [Download]
```
- Shows "Download" button
- Tapping starts download process
- Progress bar appears once download begins

### State 2: DOWNLOADING
```
Model Name (Size)
      [45% ▓▓▓▓░░░░░]
```
- Shows progress bar with percentage
- Real-time updates
- Can still navigate away (cancels download)

### State 3: INSTALLED (Not Selected)
```
Model Name (Size)
      [○ Select] [Delete]
```
- Shows empty circle to select
- "Delete" button in red
- Select to make it current model

### State 4: INSTALLED & SELECTED
```
Model Name (Size)
      [✓ Select] [Delete]
```
- Shows filled checkmark (blue)
- Model is currently active
- Can still delete if needed

## Workflow Examples

### Workflow 1: Download and Use New Model
```
1. Open Manage Models
   ↓
2. Tap model family
   ↓
3. Tap "Download" on new model
   ↓
4. Wait for progress (0% → 100%)
   ↓
5. Model becomes installed with checkmark
   ↓
6. Done! Model ready to use in chat
```

### Workflow 2: Switch Between Installed Models
```
1. Open Manage Models
   ↓
2. Tap model family
   ↓
3. Tap checkmark on different model
   ↓
4. Model becomes current (blue checkmark)
   ↓
5. Done! Back to chat with new model active
```

### Workflow 3: Delete Unused Model
```
1. Open Manage Models
   ↓
2. Tap model family
   ↓
3. Tap "Delete" on installed model
   ↓
4. Model removed from installed list
   ↓
5. Done! Storage freed up
```

## Integration with Chat View

From the chat view, users can:
1. Tap the brain icon in toolbar
2. See dropdown menu with installed models
3. Select different model quickly
4. Or tap "Download more models..." to go to Manage Models

This maintains the existing chat flow while adding the new detailed management view.

## Key User Benefits

✅ **Clear Hierarchy**
- Browse families first
- Then dive into specific models
- Clean navigation flow

✅ **Visual Clarity**
- Icons distinguish model families
- Checkmarks show selection
- Colors show actions (red for delete)
- Progress bars for downloads

✅ **Quick Actions**
- Install, select, or delete in one tap
- No modal dialogs needed
- Direct state feedback

✅ **Information Display**
- Model names clearly visible
- File sizes shown for all models
- Installation status at a glance
- Progress percentage during download

## Accessibility Features

- Large touch targets (buttons and selections)
- Clear visual hierarchy with fonts and colors
- Semantic labels on all buttons
- Proper contrast ratios
- Works with VoiceOver (standard List support)

## Performance Considerations

- List loads all families efficiently
- Lazy loading of model details
- Proper task cancellation prevents memory leaks
- Progress updates throttled to 0.1s intervals
- No blocking operations on main thread
