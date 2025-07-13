import UIKit

public class PixLensDebugLauncher {
    public static func enableFloatingButton() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let windowScene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let window = windowScene.windows.first else {
                print("❌ Could not access window")
                return
            }

            let button = UIButton(type: .system)
            button.setTitle("📷 Choose Image", for: .normal)
            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(nil, action: #selector(openImagePicker), for: .touchUpInside)

            window.addSubview(button)

            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -20),
                button.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -40),
                button.widthAnchor.constraint(equalToConstant: 180),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }

    @objc static func openImagePicker() {
        guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("❌ Could not open image picker")
            return
        }

        let tempVC = UIViewController()
        tempVC.modalPresentationStyle = .overFullScreen
        window.rootViewController?.present(tempVC, animated: false) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = tempVC as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate)

            tempVC.present(picker, animated: true)
        }
    }

}
