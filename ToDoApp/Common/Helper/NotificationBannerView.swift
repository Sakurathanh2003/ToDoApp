//
//  NotificationBannerView.swift
//  PhotoConverter
//
//  Created by Manh Nguyen Ngoc on 20/04/2022.
//

import UIKit

enum NotificationBannerMode {
    case dark
    case lightBlur
}

enum NotificationBannerIconType {
    case warning
    case success
}

class NotificationBannerView: UIView {
    static func show(_ message: String, mode: NotificationBannerMode = .dark, icon: NotificationBannerIconType, duration: Double = 3) {
        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else {
            return
        }
        
        if let oldBanner = window.subviews.first(where: {$0 is NotificationBannerView}) {
            oldBanner.removeFromSuperview()
        }
        
        let notificationBannerView = NotificationBannerView(message: message, mode: mode, icon: icon, duration: duration)
        notificationBannerView.config()
        
        window.addSubview(notificationBannerView)
        notificationBannerView.fitSuperviewConstraint()
        
        notificationBannerView.startShowingAnimation()
        notificationBannerView.startAutoDismiss()
    }
    
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.dismiss()
    }
    
    // MARK: - Init
    init(message: String, mode: NotificationBannerMode, icon: NotificationBannerIconType, duration: Double = 3) {
        self.message = message
        self.mode = mode
        self.icon = icon
        self.duration = duration
        super.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Variable
    private let mode: NotificationBannerMode
    private let icon: NotificationBannerIconType
    private let duration: Double
    private let message: String
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.cornerRadius = 5
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Poppins-Medium", size: 12)
        label.textColor = UIColor.black
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: icon == .warning ? "ic_warning_banner" : "ic_success_banner")
        return imageView
    }()
    
    // MARK: - Config
    private func config() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(imageView)
        containerView.addSubview(messageLabel)
        self.addSubview(containerView)
        
        var activeConstraints: [NSLayoutConstraint] = [
            containerView.leftAnchor.constraint(greaterThanOrEqualTo: self.leftAnchor, constant: 24),
            containerView.rightAnchor.constraint(lessThanOrEqualTo: self.rightAnchor, constant: -24),
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20),
            imageView.rightAnchor.constraint(equalTo: messageLabel.leftAnchor, constant: -20),
            imageView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            messageLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20),
            messageLabel.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10),
            messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ]
        
        if mode == .dark {
            activeConstraints.append(containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 120))
        } else {
            activeConstraints.append(containerView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 120))
        }
        
        NSLayoutConstraint.activate(activeConstraints)
        configBackground()
    }
    
    private func configBackground() {
        if icon == .success {
            containerView.borderWidth = 1
            containerView.borderColor = UIColor(rgb: 0x40BF62)
            containerView.backgroundColor = UIColor(rgb: 0xB4FFC8).withAlphaComponent(0.6)
            return
        }
        
        containerView.borderWidth = 1
        containerView.borderColor = UIColor(rgb: 0xFFD056)
        containerView.backgroundColor = UIColor(rgb: 0xFFC700).withAlphaComponent(0.6)
    }
    
    // MARK: - Animation
    private func startShowingAnimation() {
        self.alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @objc private func dismiss() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(dismiss), object: nil)
        
        self.alpha = 1
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    private func startAutoDismiss() {
        self.perform(#selector(dismiss), with: nil, afterDelay: duration)
    }
}
