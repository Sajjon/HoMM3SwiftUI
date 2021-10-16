//
//  Map+Tile.swift
//  HoMM3SwiftUI
//
//  Created by Alexander Cyon on 2021-08-19.
//

import Foundation
import Util

public extension Map {
    struct Tile: Hashable, CustomDebugStringConvertible, Codable {

        public var position: Position { _position! }
        
        @NotCoded
        internal private(set) var _position: Position!
        
        internal func withPosition(_ position: Position) -> Self {
            var copy = self
            copy._position = position
            return copy
        }
        
        public let ground: Ground 
        
        public let river: River?
        public let road: Road?
        
        /// Whether tile is coastal (allows disembarking if land or block movement if water)
        @SkipEncodingIfFalse
        public private(set) var isCoastal: Bool
        
        /// If water tile, then we might have greater speed with our boats thanks to favourable winds.
        @SkipEncodingIfFalse
        public private(set) var hasFavourableWindEffect: Bool
        
        public init(
            position: Position,
            ground: Ground,
            river: River? = nil,
            road: Road? = nil,
            isCoastal: Bool,
            hasFavourableWindEffect: Bool
        ) {
            self._position = position
            self.ground = ground
            self.river = river
            self.road = road
            self.isCoastal = isCoastal
            self.hasFavourableWindEffect = hasFavourableWindEffect
        }
    }
}

public extension Map.Tile {
    var debugDescription: String {
        let optionalStrings: [String?] = [
            "position: \(position)",
            "ground: \(ground)",
            river.map { "river: \($0)" },
            road.map { "road: \($0)" },
            "isCoastal: \(isCoastal)",
            "hasFavourableWind: \(hasFavourableWindEffect)"
        ]
        
        return optionalStrings.filterNils().joined(separator: "\n")
   
    }
}
