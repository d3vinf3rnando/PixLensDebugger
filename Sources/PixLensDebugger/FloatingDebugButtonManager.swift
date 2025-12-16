//
//  FloatingDebugButtonManager.swift
//  PixLensDebugger
//
//  Created by Devin Fernando on 2025-12-16.
//

import UIKit

public final class FloatingDebugButtonManager: NSObject,
                                               UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate {

    public static let shared = FloatingDebugButtonManager()

    private let floatingButton = UIButton(type: .system)

    private override init() {
        super.init()
    }

    // MARK: - Public API

    public func enable() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                print("❌ PixLensDebugger: Key window not found")
                return
            }

            // Prevent duplicates
            if window.subviews.contains(self.floatingButton) { return }

            self.setupButton(in: window)
        }
    }

    // MARK: - Setup

    private func setupButton(in window: UIWindow) {
        floatingButton.setTitle("📷 Choose Image", for: .normal)
        floatingButton.backgroundColor = UIColor(
            red: 0.203, green: 0.471, blue: 0.965, alpha: 1.0
        )
        floatingButton.setTitleColor(.white, for: .normal)
        floatingButton.layer.cornerRadius = 12
        floatingButton.frame = CGRect(
            x: window.bounds.width - 220,
            y: window.bounds.height - 120,
            width: 200,
            height: 50
        )
        floatingButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]

        floatingButton.addTarget(
            self,
            action: #selector(openImagePicker),
            for: .touchUpInside
        )

        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleDrag(_:))
        )
        floatingButton.addGestureRecognizer(panGesture)

        window.addSubview(floatingButton)
        window.bringSubviewToFront(floatingButton)

        print("✅ PixLensDebugger floating button enabled")
    }

    // MARK: - Actions

    @objc private func openImagePicker() {
        guard let rootVC = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController else { return }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        rootVC.present(picker, animated: true)
    }

    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view,
              let superview = view.superview else { return }

        let translation = gesture.translation(in: superview)
        view.center = CGPoint(
            x: view.center.x + translation.x,
            y: view.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: superview)
    }

    // MARK: - UIImagePicker Delegate

    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            floatingButton.isHidden = true

            OverlayDebugger.shared.showOverlay(with: image)
            OverlayDebugger.shared.onOverlayClosed = { [weak self] in
                self?.floatingButton.isHidden = false
            }
        }
    }

    public func imagePickerControllerDidCancel(
        _ picker: UIImagePickerController
    ) {
        picker.dismiss(animated: true)
    }
}

