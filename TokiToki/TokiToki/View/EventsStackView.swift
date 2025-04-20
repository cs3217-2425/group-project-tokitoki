//
//  EventsStackView.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 15/4/25.
//
import UIKit

class EventsStackView: UIStackView {
    private var eventViews: [EventCountdownView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        axis = .vertical
        alignment = .fill
        distribution = .fillEqually
        spacing = 8
        translatesAutoresizingMaskIntoConstraints = false
    }

    func configure(with events: [any IGachaEvent]) {
        // Clear existing views
        eventViews.forEach { $0.removeFromSuperview() }
        eventViews.removeAll()

        if events.isEmpty {
            // Show "No active events" label
            let noEventsLabel = UILabel()
            noEventsLabel.text = "No active events"
            noEventsLabel.textAlignment = .center
            noEventsLabel.textColor = .lightGray
            noEventsLabel.font = UIFont.italicSystemFont(ofSize: 16)
            addArrangedSubview(noEventsLabel)
            return
        }

        // Add a view for each active event
        for event in events {
            let eventView = EventCountdownView()
            eventView.configure(with: event)
            eventView.heightAnchor.constraint(equalToConstant: 80).isActive = true

            addArrangedSubview(eventView)
            eventViews.append(eventView)
        }
    }
}
