//
//  GachaViewController.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import UIKit

protocol GachaViewControllerDelegate: AnyObject {
    func didSelectPack(pack: GachaPack)
}

class GachaViewController: UIViewController {
    // MARK: - Constants

    static let DEFAULT_DAILY_PULL_LIMIT = 3

    // MARK: - Outlets

    @IBOutlet private var gachaPackLabel: UILabel!
    @IBOutlet private var packSelectorLabel: UILabel!
    @IBOutlet private var playerCurrencyLabel: UILabel!
    @IBOutlet private var dailyPullsCountLabel: UILabel!
    @IBOutlet private var buyPullButton: UIButton!

    // MARK: - Dependencies

    // These properties can be injected
    private var playerManager: PlayerManagerProtocol!
    private var eventService: EventServiceProtocol?
    private var gachaService: GachaServiceProtocol?

    // Factory dependencies
    private var tokiFactory: TokiFactoryProtocol?
    private var skillsFactory: SkillsFactoryProtocol?
    private var equipmentRepository: EquipmentRepositoryProtocol?

    // MARK: - UI Properties

    private var gachaPackCollectionViewController: CollectionViewController!
    private let logger = Logger(subsystem: "GachaViewController")

    // Events container
    private var eventsContainerView: UIView!
    private var eventsStackView: EventsStackView!
    private var eventsHeaderLabel: UILabel!
    private var eventsRefreshTimer: Timer?

    // State
    private var selectedGachaPack: GachaPack?

    // MARK: - Dependency Injection Methods

    /// Inject the player manager dependency
    func injectPlayerManager(_ manager: PlayerManagerProtocol) {
        self.playerManager = manager
    }

    /// Inject the event service dependency
    func injectEventService(_ service: EventServiceProtocol) {
        self.eventService = service
    }

    /// Inject the gacha service dependency
    func injectGachaService(_ service: GachaServiceProtocol) {
        self.gachaService = service
    }

    /// Inject the toki factory dependency
    func injectTokiFactory(_ factory: TokiFactoryProtocol) {
        self.tokiFactory = factory
    }

    /// Inject the skills factory dependency
    func injectSkillsFactory(_ factory: SkillsFactoryProtocol) {
        self.skillsFactory = factory
    }

    /// Inject the equipment factory dependency
    func injectEquipmentRepository(_ factory: EquipmentRepositoryProtocol) {
        self.equipmentRepository = factory
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // If dependencies haven't been injected yet, use the default approach temporarily
        // This allows backwards compatibility during the refactoring period
        setupDependenciesIfNeeded()

        // Style the labels
        setupLabels()

        // Setup events UI
        setupEventsUI()

        // Load packs
        loadGachaPacks()

        // Select first pack by default
        selectedGachaPack = gachaService?.getAllPacks().first
        updatePackSelectorLabel()
        updatePlayerCurrencyLabel()
        updateDailyPullsLabel()

        // Update the events display
        updateEventsDisplay()

        // Setup refresh timer for events (every minute)
        setupEventsRefreshTimer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePlayerCurrencyLabel()
        updateDailyPullsLabel()
        updateEventsDisplay()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        eventsRefreshTimer?.invalidate()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let collectionVC = segue.destination as? CollectionViewController {
            self.gachaPackCollectionViewController = collectionVC
            collectionVC.delegate = self

            // If packs already loaded, update the collection view
            if let packs = gachaService?.getAllPacks(), !packs.isEmpty {
                collectionVC.packs = packs
            }
        }
    }

    // MARK: - Setup Methods

    private func setupDependenciesIfNeeded() {
        // Only create dependencies if they weren't injected
        // This is a temporary solution during the refactoring phase

        // Set up factories first if they weren't injected
        if skillsFactory == nil {
            skillsFactory = SkillsFactory()
        }

        if tokiFactory == nil && skillsFactory != nil {
            tokiFactory = TokiFactory(skillsFactory: skillsFactory!)
        }

        if equipmentRepository == nil {
            equipmentRepository = EquipmentRepository()
        }

        // Then set up services that depend on factories
        if eventService == nil && tokiFactory != nil && equipmentRepository != nil {
            eventService = EventService(
                tokiFactory: tokiFactory!,
                equipmentRepository: equipmentRepository!
            )
        }

        if gachaService == nil &&
           tokiFactory != nil &&
            equipmentRepository != nil &&
           skillsFactory != nil &&
           eventService != nil {
            gachaService = GachaService(
                tokiFactory: tokiFactory!,
                equipmentRepository: equipmentRepository!,
                skillsFactory: skillsFactory!,
                eventService: eventService!
            )
        }

        // For player manager, use the shared instance if not injected
        // This will be removed once all view controllers use DI
        if playerManager == nil {
            self.playerManager = PlayerManager()
        }
    }

    private func setupLabels() {
        packSelectorLabel.textAlignment = .center
        playerCurrencyLabel.textAlignment = .center
        dailyPullsCountLabel.textAlignment = .center
        buyPullButton.isHidden = true
    }

    private func setupEventsUI() {
        // Create Events container view
        eventsContainerView = UIView()
        eventsContainerView.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        eventsContainerView.layer.cornerRadius = 12
        eventsContainerView.layer.masksToBounds = true
        eventsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(eventsContainerView)

        // Events header label
        eventsHeaderLabel = UILabel()
        eventsHeaderLabel.text = "ACTIVE EVENTS"
        eventsHeaderLabel.font = UIFont.boldSystemFont(ofSize: 18)
        eventsHeaderLabel.textColor = .white
        eventsHeaderLabel.textAlignment = .center
        eventsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        eventsContainerView.addSubview(eventsHeaderLabel)

        // Events stack view
        eventsStackView = EventsStackView()
        eventsStackView.translatesAutoresizingMaskIntoConstraints = false
        eventsContainerView.addSubview(eventsStackView)

        // Position the events container at the bottom of the screen
        NSLayoutConstraint.activate([
            eventsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            eventsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            eventsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            eventsHeaderLabel.topAnchor.constraint(equalTo: eventsContainerView.topAnchor, constant: 8),
            eventsHeaderLabel.leadingAnchor.constraint(equalTo: eventsContainerView.leadingAnchor),
            eventsHeaderLabel.trailingAnchor.constraint(equalTo: eventsContainerView.trailingAnchor),

            eventsStackView.topAnchor.constraint(equalTo: eventsHeaderLabel.bottomAnchor, constant: 8),
            eventsStackView.leadingAnchor.constraint(equalTo: eventsContainerView.leadingAnchor, constant: 16),
            eventsStackView.trailingAnchor.constraint(equalTo: eventsContainerView.trailingAnchor, constant: -16),
            eventsStackView.bottomAnchor.constraint(equalTo: eventsContainerView.bottomAnchor, constant: -16)
        ])
    }

    private func setupEventsRefreshTimer() {
        // Stop any existing timer
        eventsRefreshTimer?.invalidate()

        // Create a new timer that updates every minute
        eventsRefreshTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateEventsDisplay()
        }
    }

    // MARK: - Data Loading and UI Updates

    private func loadGachaPacks() {
        if let packs = gachaService?.getAllPacks(), !packs.isEmpty {
            // Update collection view with packs
            gachaPackCollectionViewController?.packs = packs
        }
    }

    private func updatePackSelectorLabel() {
        // This is now handled by the collection view
    }

    private func updatePlayerCurrencyLabel() {
        let player = playerManager.getOrCreatePlayer(name: "Player")
        playerCurrencyLabel.text = "\(player.currency)"

        if let selectedPack = selectedGachaPack {
            if player.canSpendCurrency(selectedPack.cost) {
                playerCurrencyLabel.textColor = .white
            } else {
                playerCurrencyLabel.textColor = .systemRed
            }
        } else {
            playerCurrencyLabel.textColor = .white
        }
    }

    private func updateDailyPullsLabel() {
        let remainingPulls = playerManager.getRemainingDailyPulls()
        dailyPullsCountLabel.text = "\(remainingPulls) / \(GachaViewController.DEFAULT_DAILY_PULL_LIMIT) DAILY PULLS"
        buyPullButton.isHidden = remainingPulls > 0
    }

    private func updateEventsDisplay() {
        guard let eventService = eventService else { return }

        // Get active events
        let activeEvents = eventService.getActiveEvents()

        // Set height constraint for events container based on number of events
        let headerHeight: CGFloat = 40
        let eventHeight: CGFloat = 80
        let eventSpacing: CGFloat = 8
        let verticalPadding: CGFloat = 16

        let contentHeight = headerHeight + verticalPadding +
        (activeEvents.isEmpty ? 40 : (CGFloat(activeEvents.count) * (eventHeight + eventSpacing) - eventSpacing))

        // Remove existing height constraint
        eventsContainerView.constraints.filter {
            $0.firstAttribute == .height && $0.firstItem === eventsContainerView
        }.forEach {
            eventsContainerView.removeConstraint($0)
        }

        // Add new height constraint
        eventsContainerView.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true

        // Configure the events stack view
        eventsStackView.configure(with: activeEvents)

        // Update layout
        view.layoutIfNeeded()
    }

    // MARK: - Gacha Functionality

    /// Perform a gacha draw for the given pack
    func performDraw(for pack: GachaPack) {
        guard let gachaService = gachaService as? GachaService else {
            showErrorMessage("Gacha Service not initialized or not correct type")
            return
        }

        // Check if player has reached daily limit
        if playerManager.hasReachedDailyPullLimit() {
            showErrorMessage("Daily pull limit reached. Try again tomorrow!")
            return
        }

        // Get current player state to check if they can afford the pack
        let player = playerManager.getOrCreatePlayer(name: "Player")

        // Check if player has enough currency
        if !player.canSpendCurrency(pack.cost) {
            showErrorMessage("Not enough currency. Need \(pack.cost)")
            return
        }

        // Call the PlayerManager's drawFromGachaPack method which handles all player updates
        let drawnItems = playerManager.drawFromGachaPack(
            packName: pack.name,
            count: 1,
            gachaService: gachaService
        )

        if drawnItems.isEmpty {
            showErrorMessage("No items drawn. Daily limit may have been reached.")
            return
        }

        let item = drawnItems[0]
        let event = GachaPullEvent(
            itemName: item.name,
            rarity: item.rarity
        )
        EventBus.shared.post(event)

        // Update currency display immediately after purchase
        updatePlayerCurrencyLabel()

        // Update daily pulls display
        updateDailyPullsLabel()

        // Update the draw button state
        updatePackSelectorLabel()

        // Display drawn items
        displayDrawnItems(drawnItems)
    }

    // MARK: - UI Feedback

    private func showErrorMessage(_ message: String) {
        packSelectorLabel.text = message
        packSelectorLabel.textColor = .systemRed
        logger.log(message)

        // Animate the label to draw attention
        UIView.animate(withDuration: 0.1, animations: {
            self.packSelectorLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.packSelectorLabel.transform = .identity
            }
        })

        // Reset color after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.packSelectorLabel.textColor = .white
            self.updatePackSelectorLabel()
        }
    }

    private func displayDrawnItems(_ items: [any IGachaItem]) {
        guard !items.isEmpty else {
            packSelectorLabel.text = "No items drawn."
            return
        }

        let itemDescriptions = items.map { item in
            formatItemDescription(item)
        }.joined(separator: ", ")

        // Show drawn item with animation
        packSelectorLabel.text = itemDescriptions

        // Reset color after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.updatePackSelectorLabel()
        }

        // Play a celebration animation for the drawn item
        playCelebrationAnimation()
    }

    private func formatItemDescription(_ item: any IGachaItem) -> String {
        let itemType: String

        switch item {
        case let toki as TokiGachaItem:
            itemType = "Toki"
        case let equipment as EquipmentGachaItem:
            itemType = "Equipment"
        default:
            itemType = "Unknown"
        }

        let elementEmoji = getElementEmoji(for: item.elementType.first)

        return "\(item.rarity.rawValue.capitalized) \(itemType): \(item.name) \(elementEmoji)"
    }

    private func getElementEmoji(for elementType: ElementType?) -> String {
        guard let elementType = elementType else { return "⚪️" }

        switch elementType {
        case .fire: return "🔥"
        case .water: return "💧"
        case .earth: return "🌍"
        case .air: return "🌬️"
        case .light: return "✨"
        case .dark: return "🌑"
        case .neutral: return "⚪️"
        case .lightning: return "⚡️"
        case .ice: return "❄️"
        }
    }

    @IBAction func buyPullButtonTapped(_ sender: UIButton) {
        if playerManager.buyGachaPull() {
            print("Gacha pull purchased successfully.")
            // Update currency display immediately after purchase
            updatePlayerCurrencyLabel()

            // Update daily pulls display
            updateDailyPullsLabel()
        } else {
            showErrorMessage("Failed to purchase gacha pull.")
        }

    }

    private func playCelebrationAnimation() {
        // Create a simple particle effect for celebration
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        emitterLayer.emitterShape = .point
        emitterLayer.emitterSize = CGSize(width: 1, height: 1)

        let cell = CAEmitterCell()
        cell.birthRate = 20
        cell.lifetime = 1.5
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionRange = .pi * 2
        cell.scale = 0.2
        cell.scaleRange = 0.1
        cell.contents = UIImage(systemName: "star.fill")?.cgImage
        cell.color = UIColor.systemYellow.cgColor

        emitterLayer.emitterCells = [cell]
        view.layer.addSublayer(emitterLayer)

        // Remove the emitter after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            emitterLayer.removeFromSuperlayer()
        }
    }
}

// MARK: - GachaViewControllerDelegate
extension GachaViewController: GachaViewControllerDelegate {
    func didSelectPack(pack: GachaPack) {
        selectedGachaPack = pack
        updatePackSelectorLabel()
        updatePlayerCurrencyLabel()
    }
}
