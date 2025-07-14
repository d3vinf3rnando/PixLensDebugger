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

    @objc private func moveUp() { overlayImageView.frame.origin.y -= 1 }
    @objc private func moveDown() { overlayImageView.frame.origin.y += 1 }
    @objc private func moveLeft() { overlayImageView.frame.origin.x -= 1 }
    @objc private func moveRight() { overlayImageView.frame.origin.x += 1 }

    @objc private func resetOverlay() {
        UIView.animate(withDuration: 0.2) {
            self.overlayImageView.frame = UIScreen.main.bounds
        }
    }

    @objc private func closeOverlay() {
        OverlayDebugger.retainedWindow?.isHidden = true
        OverlayDebugger.retainedWindow = nil
        onOverlayClosed?()
    }

    @objc private func handleControlPanelDrag(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: view.superview)
        if gesture.state == .changed || gesture.state == .ended {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            gesture.setTranslation(.zero, in: view.superview)
        }
    }
}
