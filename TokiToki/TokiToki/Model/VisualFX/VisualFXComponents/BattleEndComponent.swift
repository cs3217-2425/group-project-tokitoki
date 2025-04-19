//
//  BattleEndComponent.swift
//  TokiToki
//
//  Created by wesho on 18/4/25.
//

import UIKit

class BattleEndComponent: ScreenwideVisualFXComponent<BattleEndedEvent> {
    private var effect: BattleEndVisualFX?

    override func handleEvent(_ event: BattleEndedEvent) {
        guard let viewController = self.viewController else {
            return
        }

        let visualFX = BattleEndVisualFX(parentViewController: viewController)
        self.effect = visualFX

        let customMessage = getCustomMessage(event)

        visualFX.play(isWin: event.isWin, autoNavigateAfter: 5, message: customMessage) {
            // Navigate back when timer completes
            viewController.navigationController?.popViewController(animated: true)
        }
    }

    private func getCustomMessage(_ event: BattleEndedEvent) -> String {
        if event.isWin {
            return "Congratulations! Your team has triumphed over the enemy. You received " +
            "\(event.gold) gold and each toki received \(event.exp) XP."
        } else {
            return "Your team has been defeated. Better luck next time! Don’t give up " +
            "— train harder and come back stronger!"
        }
    }
}
