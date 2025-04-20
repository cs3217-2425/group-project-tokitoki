//
//  BattleEndVisualFX.swift
//  TokiToki
//
//  Created by wesho on 18/4/25.
//

import UIKit

class BattleEndVisualFX {
    private weak var parentViewController: UIViewController?
    private var overlayView: UIView?
    private var countdownLabel: UILabel?
    private var messageLabel: UILabel?
    private var timeRemaining: Int = 3
    private var timer: Timer?
    private var navigationHandler: (() -> Void)?

    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }

    func play(isWin: Bool, autoNavigateAfter seconds: Int = 3, message: String? = nil, navigateAction: @escaping () -> Void) {
        guard let parentViewController = parentViewController else { return }
        self.navigationHandler = navigateAction
        self.timeRemaining = seconds

        // Create overlay
        let overlay = UIView(frame: parentViewController.view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        parentViewController.view.addSubview(overlay)
        self.overlayView = overlay

        // Create container for content
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(white: 0.15, alpha: 0.9)
        container.layer.cornerRadius = 20
        container.layer.borderWidth = 3
        container.layer.borderColor = isWin ? UIColor.systemGreen.cgColor : UIColor.systemRed.cgColor
        overlay.addSubview(container)

        // Result title
        let resultLabel = UILabel()
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.text = isWin ? "Victory!" : "Defeat!"
        resultLabel.textColor = isWin ? .systemGreen : .systemRed
        resultLabel.font = UIFont.boldSystemFont(ofSize: 36)
        resultLabel.textAlignment = .center
        container.addSubview(resultLabel)

        // Optional message text
        let messageText = UILabel()
        messageText.translatesAutoresizingMaskIntoConstraints = false
        messageText.text = message ?? (isWin ? "You've won the battle!" : "You've been defeated!")
        messageText.textColor = .white
        messageText.font = UIFont.systemFont(ofSize: 18)
        messageText.textAlignment = .center
        messageText.numberOfLines = 0
        container.addSubview(messageText)
        self.messageLabel = messageText

        // Countdown indicator
        let countdown = UILabel()
        countdown.translatesAutoresizingMaskIntoConstraints = false
        countdown.text = "Returning in \(timeRemaining)..."
        countdown.textColor = .lightGray
        countdown.font = UIFont.systemFont(ofSize: 16)
        countdown.textAlignment = .center
        container.addSubview(countdown)
        self.countdownLabel = countdown

        // Layout constraints
        NSLayoutConstraint.activate([
            // Container positioning
            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            container.widthAnchor.constraint(equalTo: overlay.widthAnchor, multiplier: 0.85),
            container.heightAnchor.constraint(lessThanOrEqualTo: overlay.heightAnchor, multiplier: 0.5),

            // Result label
            resultLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 25),
            resultLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            // Message text
            messageText.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            messageText.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            messageText.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            // Countdown label
            countdown.topAnchor.constraint(equalTo: messageText.bottomAnchor, constant: 30),
            countdown.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            countdown.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
        ])

        // Start timer for countdown
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                     selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }

    func updateMessage(_ newMessage: String) {
        messageLabel?.text = newMessage
    }

    @objc private func updateCountdown() {
        timeRemaining -= 1

        countdownLabel?.text = "Returning in \(timeRemaining)..."

        if timeRemaining <= 0 {
            timer?.invalidate()
            navigateAway()
        }
    }

    private func navigateAway() {
        UIView.animate(withDuration: 0.5, animations: {
            self.overlayView?.alpha = 0
        }, completion: { _ in
            self.overlayView?.removeFromSuperview()
            self.navigationHandler?()
        })
    }

    func cleanup() {
        timer?.invalidate()
        timer = nil
        overlayView?.removeFromSuperview()
    }
}
