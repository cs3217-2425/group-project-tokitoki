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

        let customMessage = getCustomMessage(isWin: event.isWin)

        visualFX.play(isWin: event.isWin, autoNavigateAfter: 5, message: customMessage) {
            // Navigate back when timer completes
            viewController.navigationController?.popViewController(animated: true)
        }
    }

    private func getCustomMessage(isWin: Bool) -> String {
        if isWin {
            return "Congratulations! Your team has triumphed over the enemy. You received 100 gold and 50 XP."
        } else {
            return "Your team has been defeated. Better luck next time! You can retry this battle or train your team further."
        }
    }
}
