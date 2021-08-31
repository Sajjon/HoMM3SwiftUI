//
//  Hero+CustomHero.swift
//  HoMM3SwiftUI
//
//  Created by Alexander Cyon on 2021-08-18.
//

import Foundation

public extension Map.AdditionalInformation {
    struct CustomHero: Hashable {
        let heroClass: Hero.Class
        let portraitID: Hero.ID?
        let name: String
        let availableForPlayers: [PlayerColor]
    }
    
    struct CustomHeroes: Hashable {
        public let customHeroes: [CustomHero]
    }
}