
<img width="5160" height="1024" alt="PixLensDebuggerBanner" src="https://github.com/user-attachments/assets/2abd5e40-4038-46b1-862f-0b239e1a266a" />


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

## 🎬 Video Guide



https://github.com/user-attachments/assets/8a3a9306-5def-4a41-b536-d03ed4530b0e


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

### Step 1: Import into Your ViewController

swift
```import PixLensDebugger```

### Step 2: Add Floating Button Setup to Your ViewController
```
 private let floatingButton = UIButton(type: .system)
```

### Step 3: Enable Floating Button (Debug-only)
Add the following to your root ViewController.swift:

```
override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        #if DEBUG
        setupFloatingButton()
        #endif
       
    }


private func setupFloatingButton() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let windowScene = UIApplication.shared.connectedScenes
                      .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                print("❌ Could not find key window")
                return
            }

            // Avoid duplicates
            if window.subviews.contains(self.floatingButton) { return }

            self.floatingButton.setTitle("📷 Choose Image", for: .normal)
            self.floatingButton.backgroundColor = UIColor(red: 0.203, green: 0.471, blue: 0.965, alpha: 1.0)


            self.floatingButton.setTitleColor(.white, for: .normal)
            self.floatingButton.layer.cornerRadius = 12
            self.floatingButton.frame = CGRect(x: window.bounds.width - 220, y: window.bounds.height - 120, width: 200, height: 50)
            self.floatingButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
            self.floatingButton.addTarget(self, action: #selector(self.openImagePicker), for: .touchUpInside)

            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDrag(_:)))
            self.floatingButton.addGestureRecognizer(panGesture)

            window.addSubview(self.floatingButton)
            window.bringSubviewToFront(self.floatingButton)
            print("✅ Floating button added to window")
        }
    }


```

###  Step 4: Open Image Picker and Show Overlay
Add this to your ViewController:
```
    @objc private func openImagePicker() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            present(picker, animated: true)
        }
    
    @objc func handleDrag(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if let gestureView = gesture.view {
            gestureView.center = CGPoint(x: gestureView.center.x + translation.x,
                                         y: gestureView.center.y + translation.y)
        }
        gesture.setTranslation(.zero, in: view)
    }

    
    func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)

            if let selectedImage = info[.originalImage] as? UIImage {
                OverlayDebugger.shared.showOverlay(with: selectedImage)
                OverlayDebugger.shared.onOverlayClosed = { [weak self] in
                    self?.floatingButton.isHidden = false
                }
                floatingButton.isHidden = true
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






