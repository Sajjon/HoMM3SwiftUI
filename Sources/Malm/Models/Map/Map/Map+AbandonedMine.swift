//
//  File.swift
//  File
//
//  Created by Alexander Cyon on 2021-09-14.
//

import Foundation
import Util

public extension Map {
    
    struct AbandonedMine: Hashable, CustomDebugStringConvertible {
        public let potentialResources: Set<Resource.Kind>
        
        public init(potentialResources: [Resource.Kind]) {
            self.potentialResources = Set(potentialResources)
        }
        
        public var debugDescription: String {
            "potentialResources: \(potentialResources)"
        }
    }
}