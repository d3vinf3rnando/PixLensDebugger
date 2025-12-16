//
//  OverlayDebugger.swift
//  PixLensDebugger
//

import UIKit

public class OverlayDebugger: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public static let shared = OverlayDebugger()
    
    private static var retainedWindow: UIWindow?
    public var onOverlayClosed: (() -> Void)?

    private var overlayImageView = UIImageView()
    private var controlPanel = UIView()
    
    private var opacitySlider = UISlider()
    private var toggleButton = UIButton(type: .system)
    private var upButton = UIButton(type: .system)
    private var downButton = UIButton(type: .system)
    private var leftButton = UIButton(type: .system)
    private var rightButton = UIButton(type: .system)
    private var resetButton = UIButton(type: .system)
    private var closeButton = UIButton(type: .system)
    
    //image scaling
    private var scaleSlider = UISlider()
    private var currentScale: CGFloat = 1.0

    private let minScale: CGFloat = 0.2
    private let maxScale: CGFloat = 3.0

    
    
    //15th dec update
    public func enableFloatingButton() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        let button = UIButton(type: .system)
        button.setTitle("📷 Choose Image", for: .normal)
        button.backgroundColor = UIColor(
            red: 52/255, green: 120/255, blue: 246/255, alpha: 1.0
        )
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.frame = CGRect(
            x: window.bounds.width - 220,
            y: window.bounds.height - 120,
            width: 200,
            height: 50
        )
        button.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        button.addTarget(self, action: #selector(openImagePickerFromDebugger), for: .touchUpInside)

        window.addSubview(button)
    }
    
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            showOverlay(with: image)
        }
    }


    
    //---
    
    public func showOverlay(with image: UIImage) {
        if OverlayDebugger.retainedWindow != nil {
            return
        }
        
        guard let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            print("❌ Could not find active scene")
            return
        }

        let overlayWindow = UIWindow(windowScene: scene)
        overlayWindow.frame = UIScreen.main.bounds
        overlayWindow.windowLevel = .alert + 1
        overlayWindow.backgroundColor = .clear
        OverlayDebugger.retainedWindow = overlayWindow

        let controller = UIViewController()
        overlayWindow.rootViewController = controller

        overlayImageView.frame = UIScreen.main.bounds
        overlayImageView.image = image
        overlayImageView.contentMode = .scaleAspectFit
        overlayImageView.alpha = 0.5
        overlayImageView.isUserInteractionEnabled = true
        controller.view.addSubview(overlayImageView)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        overlayImageView.addGestureRecognizer(panGesture)

        setupControls(in: controller.view)
        overlayWindow.makeKeyAndVisible()
    }

    private func setupControls(in view: UIView) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let panelWidth: CGFloat = 280
        let panelHeight: CGFloat = 220

        let panelX = (screenWidth - panelWidth) / 2
        let panelY = screenHeight - panelHeight - 30
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(handleControlPanelDrag(_:)))
        controlPanel.addGestureRecognizer(dragGesture)

        controlPanel.frame = CGRect(x: panelX, y: panelY, width: panelWidth, height: panelHeight)
        controlPanel.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        controlPanel.layer.cornerRadius = 12
        view.addSubview(controlPanel)

        opacitySlider.frame = CGRect(x: 10, y: 10, width: 200, height: 30)
        opacitySlider.minimumValue = 0.0
        opacitySlider.maximumValue = 1.0
        opacitySlider.value = 0.5
        opacitySlider.addTarget(self, action: #selector(opacityChanged), for: .valueChanged)
        controlPanel.addSubview(opacitySlider)
        
        //scale slider
        // ➖ Button
        let shrinkButton = UIButton(type: .system)
        shrinkButton.frame = CGRect(x: 10, y: 50, width: 30, height: 30)
        shrinkButton.setTitle("➖", for: .normal)
        shrinkButton.addTarget(self, action: #selector(decreaseScale), for: .touchUpInside)
        controlPanel.addSubview(shrinkButton)

        // Slider
        scaleSlider.frame = CGRect(x: 45, y: 50, width: 180, height: 30)
        scaleSlider.minimumValue = Float(minScale)
        scaleSlider.maximumValue = Float(maxScale)
        scaleSlider.value = Float(currentScale)
        scaleSlider.addTarget(self, action: #selector(scaleChanged), for: .valueChanged)
        controlPanel.addSubview(scaleSlider)

        // ➕ Button
        let enlargeButton = UIButton(type: .system)
        enlargeButton.frame = CGRect(x: 230, y: 50, width: 30, height: 30)
        enlargeButton.setTitle("➕", for: .normal)
        enlargeButton.addTarget(self, action: #selector(increaseScale), for: .touchUpInside)
        controlPanel.addSubview(enlargeButton)


        toggleButton.frame = CGRect(x: 215, y: 10, width: 50, height: 30)
        toggleButton.setTitle("Hide", for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleOverlay), for: .touchUpInside)
        controlPanel.addSubview(toggleButton)

        upButton.frame = CGRect(x: 120, y: 50, width: 40, height: 30)
        upButton.setTitle("↑", for: .normal)
        upButton.addTarget(self, action: #selector(moveUp), for: .touchUpInside)
        controlPanel.addSubview(upButton)

        leftButton.frame = CGRect(x: 80, y: 90, width: 40, height: 30)
        leftButton.setTitle("←", for: .normal)
        leftButton.addTarget(self, action: #selector(moveLeft), for: .touchUpInside)
        controlPanel.addSubview(leftButton)

        rightButton.frame = CGRect(x: 160, y: 90, width: 40, height: 30)
        rightButton.setTitle("→", for: .normal)
        rightButton.addTarget(self, action: #selector(moveRight), for: .touchUpInside)
        controlPanel.addSubview(rightButton)

        downButton.frame = CGRect(x: 120, y: 130, width: 40, height: 30)
        downButton.setTitle("↓", for: .normal)
        downButton.addTarget(self, action: #selector(moveDown), for: .touchUpInside)
        controlPanel.addSubview(downButton)

        resetButton.frame = CGRect(x: 10, y: 180, width: 60, height: 25)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action: #selector(resetOverlay), for: .touchUpInside)
        controlPanel.addSubview(resetButton)

        closeButton.frame = CGRect(x: 80, y: 180, width: 60, height: 25)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.red, for: .normal)
        closeButton.addTarget(self, action: #selector(closeOverlay), for: .touchUpInside)
        controlPanel.addSubview(closeButton)
    }

    @objc private func opacityChanged() {
        overlayImageView.alpha = CGFloat(opacitySlider.value)
    }

    @objc private func toggleOverlay() {
        overlayImageView.isHidden.toggle()
        toggleButton.setTitle(overlayImageView.isHidden ? "Show" : "Hide", for: .normal)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: overlayImageView.superview)
        if gesture.state == .changed || gesture.state == .ended {
            overlayImageView.center.x += translation.x
            overlayImageView.center.y += translation.y
            gesture.setTranslation(.zero, in: overlayImageView.superview)
        }
    }
    
    
    //slider
    @objc private func scaleChanged() {
        currentScale = CGFloat(scaleSlider.value)
        applyScale()
    }

    @objc private func increaseScale() {
        currentScale = min(currentScale + 0.1, maxScale)
        scaleSlider.value = Float(currentScale)
        applyScale()
    }

    @objc private func decreaseScale() {
        currentScale = max(currentScale - 0.1, minScale)
        scaleSlider.value = Float(currentScale)
        applyScale()
    }
    private func applyScale() {
        overlayImageView.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
    }

    

    @objc private func moveUp() { overlayImageView.frame.origin.y -= 1 }
    @objc private func moveDown() { overlayImageView.frame.origin.y += 1 }
    @objc private func moveLeft() { overlayImageView.frame.origin.x -= 1 }
    @objc private func moveRight() { overlayImageView.frame.origin.x += 1 }

    @objc private func resetOverlay() {
        currentScale = 1.0
        scaleSlider.value = 1.0
        
        UIView.animate(withDuration: 0.2) {
            self.overlayImageView.transform = .identity
            self.overlayImageView.frame = UIScreen.main.bounds
        }
    }

    
    private func topMostViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }

        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }


    @objc private func closeOverlay() {
        OverlayDebugger.retainedWindow?.isHidden = true
        OverlayDebugger.retainedWindow = nil
        onOverlayClosed?()
    }
    
    //15th dec update
    @objc private func openImagePickerFromDebugger() {
        guard let topVC = topMostViewController() else { return }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        topVC.present(picker, animated: true)
    }

    //---

    @objc private func handleControlPanelDrag(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: view.superview)
        if gesture.state == .changed || gesture.state == .ended {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            gesture.setTranslation(.zero, in: view.superview)
        }
    }
}
