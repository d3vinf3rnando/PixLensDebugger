import UIKit

public class PixLensDebugLauncher {
    public static func enableFloatingButton() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = scene.windows.first else {
            print("❌ Could not attach floating button")
            return
        }

        let button = UIButton(type: .system)
        button.setTitle("📷 Choose Image", for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(button)

        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -40),
            button.widthAnchor.constraint(equalToConstant: 180),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])

        button.addTarget(nil, action: #selector(openImagePicker), for: .touchUpInside)
    }

    @objc static func openImagePicker() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            print("❌ Could not open picker")
            return
        }

        let picker = UIImagePickerController()
        picker.delegate = rootVC as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        picker.sourceType = .photoLibrary
        rootVC.present(picker, animated: true)
    }
}
