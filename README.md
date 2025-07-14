<img width="5160" height="1024" alt="PixLensDebuggerBanner" src="https://github.com/user-attachments/assets/ef5b7288-c075-4276-9a46-a973bdd31fdc" />


---
# 📸 PixLensDebugger V.1

**PixLensDebugger** is a lightweight debug tool for iOS developers that helps ensure pixel-perfect UI by overlaying reference images (e.g., from Figma) directly on top of a running app.

---

## 🚀 Features

- Overlay any image on top of your running app for visual comparison.
- Adjust opacity and position with built-in controls.
- Floating debug button only visible in debug builds.
- Built for **UIKit** (SwiftUI supported with manual hook).
- Safe and non-intrusive — does not affect production builds.

---

## 📦 Installation

Add `PixLensDebugger` via **Swift Package Manager**:

1. Go to **Xcode > File > Add Packages...**
2. Paste the repo URL:  https://github.com/d3vinf3rnando/PixLensDebugger.git
3. Choose the latest version or `main` branch.
4. Add to your target.

---

## 🔧 Integration Steps

> ❗️This package requires minimal manual setup inside your app — giving full flexibility.

### Step 1: Import in Your ViewController

swift
```import PixLensDebugger```

### Step 2: Enable Floating Button (Debug-only)
Add the following to your root ViewController.swift:

```
#if DEBUG
override func viewDidLoad() {
    super.viewDidLoad()
    setupFloatingButton()
}
#endif

private func setupFloatingButton() {
    let button = UIButton(type: .system)
    button.setTitle("📷 Choose Image", for: .normal)
    button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 12
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
    view.addSubview(button)

    NSLayoutConstraint.activate([
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        button.widthAnchor.constraint(equalToConstant: 200),
        button.heightAnchor.constraint(equalToConstant: 50)
    ])
}

```

###  Step 3: Open Image Picker and Show Overlay
Add this to your ViewController:
```
@objc func openImagePicker() {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = .photoLibrary
    present(picker, animated: true)
}

func imagePickerController(_ picker: UIImagePickerController,
                           didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)
    if let selectedImage = info[.originalImage] as? UIImage {
        OverlayDebugger.shared.showOverlay(with: selectedImage)
    }
}

func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
}
```
---

### 🧪 How It Works
Once an image is selected, a transparent overlay will appear with the following controls:

🔍 Opacity slider

👆 Drag-and-drop repositioning

↕️ Directional nudge buttons

♻️ Reset

❌ Close overlay

You can use this to visually align and test any UI screen — no need for external comparison tools.

---

###  🖼 Screenshots
Coming soon — include GIFs or screenshots of overlay in action.

---

###  ⚠️ Notes
This tool is for debug/testing only.

Overlay uses a high window level (.alert + 1) so it appears above everything.

If your app uses SwiftUI, create a wrapper UIViewController to host this.

Works with any image exported from Figma, Zeplin, etc.

---

👨‍💻 Author
Devin Fernando






