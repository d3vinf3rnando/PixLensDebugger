//
//  ViewController.swift
//  PixLens
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let floatingButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
        setupFloatingButton()
        #endif
    }

    private func setupFloatingButton() {
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.setTitle("📷 Choose Image", for: .normal)
        floatingButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
        floatingButton.setTitleColor(.white, for: .normal)
        floatingButton.layer.cornerRadius = 12
        floatingButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)

        view.addSubview(floatingButton)

        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            floatingButton.widthAnchor.constraint(equalToConstant: 200),
            floatingButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }



//    @objc func handleDrag(_ gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: view)
//        if let gestureView = gesture.view {
//            gestureView.center = CGPoint(x: gestureView.center.x + translation.x,
//                                         y: gestureView.center.y + translation.y)
//        }
//        gesture.setTranslation(.zero, in: view)
//    }

    @objc func openImagePicker() {
        print("📸 Opening image picker...")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("🧠 Picker returned media")
        picker.dismiss(animated: true)

        if let selectedImage = info[.originalImage] as? UIImage {
            print("✅ Image selected")
            OverlayDebugger.shared.showOverlay(with: selectedImage)
            OverlayDebugger.shared.onOverlayClosed = { [weak self] in
                self?.floatingButton.isHidden = false
            }
            // 👇 Hide the floating button after image is selected
            floatingButton.isHidden = true
        } else {
            print("❌ Could not extract image from picker info")
        }
    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        print("⚠️ Picker canceled")
    }
}
