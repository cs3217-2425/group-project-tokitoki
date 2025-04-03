//
//  SkillVisualFX.swift
//  TokiToki
//
//  Created by wesho on 1/4/25.
//

import Foundation

// Base protocol for skill visual effects
protocol SkillVisualFX {
    func play(completion: @escaping () -> Void)
}
