//
//  Map+VictoryLossConditions.swift
//  HoMM3SwiftUI
//
//  Created by Alexander Cyon on 2021-08-16.
//

import Foundation

public extension Map {
    struct VictoryLossConditions: Equatable {
        public let victoryConditions: [VictoryCondition]
        public let lossConditions: [LossCondition]
    }
}
