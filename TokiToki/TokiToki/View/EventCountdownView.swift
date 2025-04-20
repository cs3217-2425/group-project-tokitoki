//
//  EventCountdownView.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 15/4/25.
//
import UIKit

class EventCountdownView: UIView {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let countdownLabel = UILabel()
    private let iconImageView = UIImageView()
    private let containerView = UIView()

    private var event: (any IGachaEvent)?
    private var timer: Timer?
    private let progressBar = UIProgressView(progressViewStyle: .default)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // Container view with gradient background
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        // Create a gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.9).cgColor,
            UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 0.9).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = bounds
        containerView.layer.insertSublayer(gradientLayer, at: 0)

        // Title label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // Description label
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)

        // Countdown label
        countdownLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        countdownLabel.textColor = UIColor.white
        countdownLabel.textAlignment = .right
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(countdownLabel)

        // Icon image view
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconImageView)

        // Layout constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: countdownLabel.leadingAnchor, constant: -8),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: countdownLabel.leadingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),

            countdownLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            countdownLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            countdownLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])

        // Add shadow to container
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
    }

    func configure(with event: any IGachaEvent) {
        self.event = event
        titleLabel.text = event.name
        descriptionLabel.text = event.description

        // Set icon based on event type
        if let elementEvent = event as? ElementEvent {
            switch elementEvent.elementType {
            case .fire:
                iconImageView.image = UIImage(systemName: "flame.fill")
                iconImageView.tintColor = .systemOrange
            case .water:
                iconImageView.image = UIImage(systemName: "drop.fill")
                iconImageView.tintColor = .systemBlue
            case .earth:
                iconImageView.image = UIImage(systemName: "leaf.fill")
                iconImageView.tintColor = .systemGreen
            case .air:
                iconImageView.image = UIImage(systemName: "wind")
                iconImageView.tintColor = .systemTeal
            case .light:
                iconImageView.image = UIImage(systemName: "sun.max.fill")
                iconImageView.tintColor = .systemYellow
            case .dark:
                iconImageView.image = UIImage(systemName: "moon.fill")
                iconImageView.tintColor = .systemPurple
            case .neutral:
                iconImageView.image = UIImage(systemName: "circle.fill")
                iconImageView.tintColor = .lightGray
            case .lightning:
                iconImageView.image = UIImage(systemName: "bolt.fill")
                iconImageView.tintColor = .systemYellow
            case .ice:
                iconImageView.image = UIImage(systemName: "snow")
                iconImageView.tintColor = .systemCyan
            }
        } else if let _ = event as? ItemBoostEvent {
            iconImageView.image = UIImage(systemName: "star.fill")
            iconImageView.tintColor = .systemYellow
        } else {
            iconImageView.image = UIImage(systemName: "sparkles")
            iconImageView.tintColor = .white
        }

        // Update the countdown
        updateCountdown()

        // Start the timer
        startCountdownTimer()
    }

    private func startCountdownTimer() {
        // Stop any existing timer
        timer?.invalidate()

        // Create a new timer that updates every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCountdown()
        }
    }

    private func updateCountdown() {
        guard let event = event else { return }

        let now = Date()
        if now >= event.endDate {
            countdownLabel.text = "Ended"
            timer?.invalidate()
            return
        }

        let timeRemaining = event.endDate.timeIntervalSince(now)
        let days = Int(timeRemaining / (60 * 60 * 24))
        let hours = Int((timeRemaining / (60 * 60)).truncatingRemainder(dividingBy: 24))
        let minutes = Int((timeRemaining / 60).truncatingRemainder(dividingBy: 60))
        let seconds = Int(timeRemaining.truncatingRemainder(dividingBy: 60))

        if days > 0 {
            countdownLabel.text = String(format: "%dd %02dh", days, hours)
        } else {
            countdownLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }

    deinit {
        timer?.invalidate()
    }
}
