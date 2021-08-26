//
//  Map+Event.swift
//  HoMM3SwiftUI
//
//  Created by Alexander Cyon on 2021-08-19.
//

import Foundation
public extension Map {
    // TODO disambiguate between invisible events that might be triggered when walked on a certain tile (or also time based?) and visible event OBJECTs. One is parsed amongst objects in `parseObjects` the other is parsed in `parseEvents`. Should both really share the same struct?
    struct Event: Hashable {
        
        
        private let message: String?
        
        private let firstOccurence: UInt16?
        private let nextOccurence: UInt8?
        
        private let guards: CreatureStacks?
        private let bounty: Bounty?
        private let shouldBeRemovedAfterVisit: Bool
        private let availability: Availability
        
        public init(
            message: String?,
            
            firstOccurence: UInt16? = nil,
            nextOccurence: UInt8? = nil,
            
            guards: CreatureStacks? = nil,
            experiencePointsToBeGained: Int = 0,
            manaPointsToBeGainedOrDrained: Int = 0,
            moraleToBeGainedOrDrained: Int = 0,
            luckToBeGainedOrDrained: Int = 0,
            resourcesToBeGained: Resources,
            primarySkills: [Hero.PrimarySkill] = [],
            secondarySkills: [Hero.SecondarySkill] = [],
            artifactIDs: [Artifact.ID] = [],
            spellIDs: [Spell.ID] = [],
            creaturesGained: CreatureStacks? = nil,
            availableForPlayers: [PlayerColor] = [],
            canBeActivatedByComputer: Bool,
            shouldBeRemovedAfterVisit: Bool,
            canBeActivatedByHuman: Bool
        ) {
            self.message = message
            self.firstOccurence = firstOccurence
            self.nextOccurence = nextOccurence
            self.guards = guards
            self.bounty = .init(
                experiencePointsToBeGained: experiencePointsToBeGained,
                manaPointsToBeGainedOrDrained: manaPointsToBeGainedOrDrained,
                moraleToBeGainedOrDrained: moraleToBeGainedOrDrained,
                luckToBeGainedOrDrained: luckToBeGainedOrDrained,
                resourcesToBeGained: resourcesToBeGained,
                primarySkills: primarySkills,
                secondarySkills: secondarySkills,
                artifactIDs: artifactIDs,
                spellIDs: spellIDs,
                creaturesGained: creaturesGained
            )
            self.availability = .init(
                availableForPlayers: availableForPlayers,
                canBeActivatedByComputer: canBeActivatedByComputer,
                canBeActivatedByHuman: canBeActivatedByHuman
            )
            self.shouldBeRemovedAfterVisit = shouldBeRemovedAfterVisit
        }
    }
}

// MARK: Bounty
public extension Map.Event {
    struct Bounty: Hashable {
        private let experiencePointsToBeGained: Int?
        private let manaPointsToBeGainedOrDrained: Int?
        private let moraleToBeGainedOrDrained: Int?
        private let luckToBeGainedOrDrained: Int?
        private let resourcesToBeGained: Resources?
        private let primarySkills: [Hero.PrimarySkill]?
        private let secondarySkills: [Hero.SecondarySkill]?
        private let artifactIDs: [Artifact.ID]?
        private let spellIDs: [Spell.ID]?
        private let creaturesGained: CreatureStacks?
        
        public init?(
            experiencePointsToBeGained: Int,
            manaPointsToBeGainedOrDrained: Int,
            moraleToBeGainedOrDrained: Int,
            luckToBeGainedOrDrained: Int,
            resourcesToBeGained: Resources,
            primarySkills: [Hero.PrimarySkill],
            secondarySkills: [Hero.SecondarySkill],
            artifactIDs: [Artifact.ID],
            spellIDs: [Spell.ID],
            creaturesGained: CreatureStacks?
        ) {
            self.experiencePointsToBeGained = experiencePointsToBeGained == 0 ? nil : experiencePointsToBeGained
            self.manaPointsToBeGainedOrDrained = manaPointsToBeGainedOrDrained == 0 ? nil : manaPointsToBeGainedOrDrained
            self.moraleToBeGainedOrDrained = moraleToBeGainedOrDrained == 0 ? nil : moraleToBeGainedOrDrained
            self.luckToBeGainedOrDrained = luckToBeGainedOrDrained == 0 ? nil : luckToBeGainedOrDrained
            self.resourcesToBeGained = resourcesToBeGained.resources.count == 0 ? nil : resourcesToBeGained
            self.primarySkills = primarySkills.count == 0 ? nil : primarySkills
            self.secondarySkills = secondarySkills.count == 0 ? nil : secondarySkills
            self.artifactIDs = artifactIDs.count == 0 ? nil : artifactIDs
            self.spellIDs = spellIDs.count == 0 ? nil : spellIDs
            self.creaturesGained = creaturesGained
            if
                self.experiencePointsToBeGained == nil &&
                self.manaPointsToBeGainedOrDrained == nil &&
                self.moraleToBeGainedOrDrained == nil &&
                self.luckToBeGainedOrDrained == nil &&
                self.resourcesToBeGained == nil &&
                self.primarySkills == nil &&
                self.secondarySkills == nil &&
                self.artifactIDs == nil &&
                self.spellIDs == nil &&
                    self.creaturesGained == nil {
                return nil
            }
        }
    }
}

// MARK: Availability
public extension Map.Event {
    struct Availability: Hashable {
        private let availableForPlayers: [PlayerColor]
        private let canBeActivatedByComputer: Bool
        private let canBeActivatedByHuman: Bool
        
        public init(
            availableForPlayers: [PlayerColor],
            canBeActivatedByComputer: Bool,
            canBeActivatedByHuman: Bool
        ) {
            self.availableForPlayers = availableForPlayers
            self.canBeActivatedByComputer = canBeActivatedByComputer
            self.canBeActivatedByHuman = canBeActivatedByHuman
        }
    }
}