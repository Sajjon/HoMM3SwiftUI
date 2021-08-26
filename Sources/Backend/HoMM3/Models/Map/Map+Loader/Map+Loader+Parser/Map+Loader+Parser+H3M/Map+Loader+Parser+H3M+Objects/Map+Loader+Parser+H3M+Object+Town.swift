//
//  Map+Loader+Parser+H3M+Object+Town.swift
//  HoMM3SwiftUI
//
//  Created by Alexander Cyon on 2021-08-22.
//

import Foundation

public extension CaseIterable {
    static func random() -> Self {
        allCases.randomElement()!
    }
}


public extension Map {
    struct Town: Hashable, Identifiable, CustomDebugStringConvertible {
        public enum ID: Hashable {
            
            /// Parsed from h3m map file
            /// Only present in version later than ROE
            case fromMapFile(UInt32)
            
            /// In case of ROE this gets generated by this code. Used to link together Map.Town.Event with their town.
            case generated(UUID)
        }
        
        public let id: ID
        public let faction: Faction
        public let owner: PlayerColor
        public let name: String?
        public let garrison: CreatureStacks?
        public let formation: Army.Formation
        public let buildings: Map.Town.Buildings
        
        public struct Spells: Hashable {
            public let obligatory: [Spell.ID]
            public let possible: [Spell.ID]
        }
        public let spells: Spells
        
        public let events: [Map.Town.Event]
        public let alignment: Alignment?
    }
}

public extension Map.Town {
    
    var debugDescription: String {
        let nameOrEmpty = name.map({ "name: \($0) "}) ?? ""
        return """
        \(faction) town
        owner: \(owner)
        \(nameOrEmpty)
        """
    }
    
    struct Buildings: Hashable {
        public let built: [Building]
        public let forbidden: [Building]
    }
}
public extension Map.Town.Buildings {
    enum Building: UInt8, Hashable, CaseIterable, CustomDebugStringConvertible {
        case mageguildLevel1 = 0,
        mageguildLevel2,
        mageguildLevel3,
        mageguildLevel4,
        mageguildLevel5,
        
        tavern,
        shiphard,
        
        fort,
        citadel,
        castle,
        
        villageHall,
        townHall,
        cityHall,
        capital,
        
        marketplace,
        resourceSilo,
        blacksmith
        
        
        /// Castle: Lighthouse
        /// Rampart: Mystic pind
        /// Tower: Artifact Merchant
        /// Inferno: N/A
        /// Necropolis: Veil of darkness
        /// Dungeon: Artifact Merchant
        /// Stornghold: Escape tunnel
        /// Fortress: Cage of warlords
        /// Conflux: Artifact Merchant
        case buildingId17
        
        /// Horde buildings for upgraded creatures
        ///
        /// Castle: Grifins
        /// Rampart: Dwarfes
        /// Tower: Stone Gargoyles
        /// Inferno: IMps
        /// Necropolis: Skeletons
        /// Dungeon: Troglodytes
        /// Stornghold: Goblins
        /// Fortress: Gnolls
        /// Conflux: Pixies
        case buildingId18
        
        /// Horde buildings for upgraded creatures
        ///
        /// Castle: Royale Griffins
        /// Rampart: Battle Dwarfes
        /// Tower: Obsidian Gargoyles
        /// Inferno: Familars
        /// Necropolis: Skeleton Warrios
        /// Dungeon: Infernal Troglodytes
        /// Stornghold:Hobgoblins
        /// Fortress: Gnoll MArauders
        /// Conflux: Sprites
        case buildingId19
        
        case shipAtTheShipyard = 20

        /// Castle: Stables
        /// Rampart: Fountain of Fortune
        /// Tower: Lookout Tower
        /// Inferno: Brimstone Clouds
        /// Necropolis: Necromancy Amplifier
        /// Dungeon: Mana Vortex
        /// Stornghold: Freelancer's Guild
        /// Fortress: Glyphs Of Fear
        /// Conflux: Magic University
        case buildingId21
        
        /// Castle: Brotherhood of Sword
        /// Rampart: Dwarfen Treasure
        /// Tower: Library
        /// Inferno: Castle Gates
        /// Necropolis: Skeleton Transformer
        /// Dungeon: Portal Of Summoning
        /// Stornghold: Ballista Yard
        /// Fortress: Blood Obelisk
        /// Conflux: N/A
        case buildingId22
        
        /// Tower: Wall Of Knowledge
        /// Inferno: Order of fire
        /// Dungeon: Academy Of Battle Scholars
        /// Stornghold: Hall Of Valhalla
        /// Castle, Rampart, Necropolis, Fortress, Conflux: N/A
        case buildingId23
        
        /// Horde Buildings For Non-Upgraded Creatures:
        /// Rampart: Dendroid Guards
        /// Inferno: Hell Hounds
        /// REST: N/A
        case buildingId24
        
        /// Horde Buildings For Upgraded Creatures:
        /// Rampart: Dendroid Soldiers,
        /// Inferno: Cerberi
        /// REST: N/A
        case buildingId25
        
        case grail = 26,
        
        housesNearCityHall,
        housesNearMunicipal,
        housesNearCapitol,
        
        dwelling1,
        dwelling2,
        dwelling3,
        dwelling4,
        dwelling5,
        dwelling6,
        dwelling7,
        upgradedDwelling1,
        upgradedDwelling2,
        upgradedDwelling3,
        upgradedDwelling4,
        upgradedDwelling5,
        upgradedDwelling6,
        upgradedDwelling7
        
    }
}

public extension Map.Town.Buildings.Building {
    var debugDescription: String {
        switch self {
        case .mageguildLevel1: return "Mage Guild level 1"
           case .mageguildLevel2: return "Mage Guild level 2"
           case .mageguildLevel3: return "Mage Guild level 3"
           case .mageguildLevel4: return "Mage Guild level 4"
           case .mageguildLevel5: return "Mage Guild level 5"
        
        case .tavern: return "Tavern"
        case .shiphard: return "Shipyard"
        
        case .fort: return "Fort"
        case .citadel: return "Citadel"
             case .castle: return "Castle"
        
        case .villageHall: return "Villagehall"
        case .townHall: return "Townhall"
        case .cityHall: return "Cityhall"
        case .capital: return "aApital"
        
        case .marketplace: return "Marketplace"
        case .resourceSilo: return "Resource Silo"
        case .blacksmith: return "Blacksmith"
        
        
        /// Castle: Lighthouse
        /// Rampart: Mystic pind
        /// Tower: Artifact Merchant
        /// Inferno: N/A
        /// Necropolis: Veil of darkness
        /// Dungeon: Artifact Merchant
        /// Stornghold: Escape tunnel
        /// Fortress: Cage of warlords
        /// Conflux: Artifact Merchant
        case .buildingId17: return """
                    Castle: Lighthouse
                    Rampart: Mystic pind
                    Tower: Artifact Merchant
                    Inferno: N/A
                    Necropolis: Veil of darkness
                    Dungeon: Artifact Merchant
                    Stornghold: Escape tunnel
                    Fortress: Cage of warlords
                    Conflux: Artifact Merchant
            """
        
        /// Horde buildings for upgraded creatures
        ///
        /// Castle: Grifins
        /// Rampart: Dwarfes
        /// Tower: Stone Gargoyles
        /// Inferno: IMps
        /// Necropolis: Skeletons
        /// Dungeon: Troglodytes
        /// Stornghold: Goblins
        /// Fortress: Gnolls
        /// Conflux: Pixies
        case .buildingId18: return """
                    Horde buildings for upgraded creatures
                    Castle: Grifins
                    Rampart: Dwarfes
                    Tower: Stone Gargoyles
                    Inferno: IMps
                    Necropolis: Skeletons
                    Dungeon: Troglodytes
                    Stornghold: Goblins
                    Fortress: Gnolls
                    Conflux: Pixies
            """
        
        /// Horde buildings for upgraded creatures
        ///
        /// Castle: Royale Griffins
        /// Rampart: Battle Dwarfes
        /// Tower: Obsidian Gargoyles
        /// Inferno: Familars
        /// Necropolis: Skeleton Warrios
        /// Dungeon: Infernal Troglodytes
        /// Stornghold:Hobgoblins
        /// Fortress: Gnoll MArauders
        /// Conflux: Sprites
        case .buildingId19: return """
                    Horde buildings for upgraded creatures
                    Castle: Royale Griffins
                    Rampart: Battle Dwarfes
                    Tower: Obsidian Gargoyles
                    Inferno: Familars
                    Necropolis: Skeleton Warrios
                    Dungeon: Infernal Troglodytes
                    Stornghold:Hobgoblins
                    Fortress: Gnoll MArauders
                    Conflux: Sprites
            """
        
        case .shipAtTheShipyard: return "Ship (at the shipyard)"

        /// Castle: Stables
        /// Rampart: Fountain of Fortune
        /// Tower: Lookout Tower
        /// Inferno: Brimstone Clouds
        /// Necropolis: Necromancy Amplifier
        /// Dungeon: Mana Vortex
        /// Stornghold: Freelancer's Guild
        /// Fortress: Glyphs Of Fear
        /// Conflux: Magic University
        case .buildingId21: return """
                    Castle: Stables
                    Rampart: Fountain of Fortune
                    Tower: Lookout Tower
                    Inferno: Brimstone Clouds
                    Necropolis: Necromancy Amplifier
                    Dungeon: Mana Vortex
                    Stornghold: Freelancer's Guild
                    Fortress: Glyphs Of Fear
                    Conflux: Magic University
            """
        
        /// Castle: Brotherhood of Sword
        /// Rampart: Dwarfen Treasure
        /// Tower: Library
        /// Inferno: Castle Gates
        /// Necropolis: Skeleton Transformer
        /// Dungeon: Portal Of Summoning
        /// Stornghold: Ballista Yard
        /// Fortress: Blood Obelisk
        /// Conflux: N/A
        case .buildingId22: return """
                    Castle: Brotherhood of Sword
                    Rampart: Dwarfen Treasure
                    Tower: Library
                    Inferno: Castle Gates
                    Necropolis: Skeleton Transformer
                    Dungeon: Portal Of Summoning
                    Stornghold: Ballista Yard
                    Fortress: Blood Obelisk
                    Conflux: N/A
            """
        
        /// Tower: Wall Of Knowledge
        /// Inferno: Order of fire
        /// Dungeon: Academy Of Battle Scholars
        /// Stornghold: Hall Of Valhalla
        /// Castle, Rampart, Necropolis, Fortress, Conflux: N/A
        case .buildingId23: return """
                    Tower: Wall Of Knowledge
                    Inferno: Order of fire
                    Dungeon: Academy Of Battle Scholars
                    Stornghold: Hall Of Valhalla
                    Castle, Rampart, Necropolis, Fortress, Conflux: N/A
            """
        
        /// Horde Buildings For Non-Upgraded Creatures:
        /// Rampart: Dendroid Guards
        /// Inferno: Hell Hounds
        /// REST: N/A
        case .buildingId24: return """
                    Horde Buildings For Non-Upgraded Creatures:
                    Rampart: Dendroid Guards
                    Inferno: Hell Hounds
                    REST: N/A
            """
        
        /// Horde Buildings For Upgraded Creatures:
        /// Rampart: Dendroid Soldiers,
        /// Inferno: Cerberi
        /// REST: N/A
        case .buildingId25: return """
                    Horde Buildings For Upgraded Creatures:
                    Rampart: Dendroid Soldiers,
                    Inferno: Cerberi
                    REST: N/A
            """
        
        case .grail: return "Grail"
        
        case .housesNearCityHall: return "Houses near city hall"
        case .housesNearMunicipal: return "Houses near municipal"
        case .housesNearCapitol: return "Houses near capitol"
        
        case .dwelling1: return "Dwelling level 1"
        case .dwelling2: return "Dwelling level 2"
        case .dwelling3: return "Dwelling level 3"
        case .dwelling4: return "Dwelling level 4"
        case .dwelling5: return "Dwelling level 5"
        case .dwelling6: return "Dwelling level 6"
        case .dwelling7: return "Dwelling level 7"
        case .upgradedDwelling1: return "Upgraded dwelling level 1"
        case .upgradedDwelling2: return "Upgraded dwelling level 2"
        case .upgradedDwelling3: return "Upgraded dwelling level 3"
        case .upgradedDwelling4: return "Upgraded dwelling level 4"
        case .upgradedDwelling5: return "Upgraded dwelling level 5"
        case .upgradedDwelling6: return "Upgraded dwelling level 6"
        case .upgradedDwelling7: return "Upgraded dwelling level 7"
        }
    }
}

public extension RandomNumberGenerator {
    mutating func randomBool() -> Bool {
        Int.random(in: 0...1, using: &self) == 0
    }
}

public extension Map.Town.Buildings.Building {

    static func `default`(
        includeFort: Bool = false,
        randomNumberGenerator: RandomNumberGenerator? = nil
    ) -> [Self]  {
        var prng = randomNumberGenerator ?? SystemRandomNumberGenerator()
        let maybeFort: Self? = includeFort ? .fort : nil
        let maybeDwelling2: Self? = prng.randomBool() ? .dwelling2 : nil
        
        return [
            maybeFort,
            .villageHall,
            .tavern,
            .dwelling1,
            maybeDwelling2
        ].compactMap({ $0 })
    }
    
}


// MARK: Parse Town
internal extension Map.Loader.Parser.H3M {
    
    
    
    func parseRandomTown(format: Map.Format, allowedSpellsOnMap: [Spell.ID]) throws -> Map.Town {
        try parseTown(format: format, faction: .random(), allowedSpellsOnMap: allowedSpellsOnMap)
    }
    
    func parseTown(format: Map.Format, faction: Faction, allowedSpellsOnMap: [Spell.ID]) throws -> Map.Town {
        let townID: Map.Town.ID = try format > .restorationOfErathia ? .fromMapFile(reader.readUInt32()) : .generated(UUID())
        
        let owner = try PlayerColor(integer: reader.readUInt8())
        print("🏰 town: owner='\(owner)'")
        let hasName = try reader.readBool()
        print("🏰 town: hasName='\(hasName)'")
        let name: String? = try hasName ? reader.readString(maxByteCount: 32) : nil
        print("🏰 town: name='\(name)'")
        
        let hasGarrison = try reader.readBool()
        print("🏰 town: hasGarrison='\(hasGarrison)'")
        let garrison: CreatureStacks? = try hasGarrison ? parseCreatureStacks(format: format, count: 7) : nil
        let formation: Army.Formation = try .init(integer: reader.readUInt8())
        let hasCustomBuildings = try reader.readBool()
        print("🏰 town: hasCustomBuildings='\(hasCustomBuildings)'")
        let buildings: Map.Town.Buildings = try hasCustomBuildings ? parseTownWithCustomBuildings() : parseSimpleTown()
        
        
        let obligatorySpells = try format >= .armageddonsBlade ? parseSpellIDs() : []
        var offsetSaved = reader.offset
        let possibleSpells = try parseSpellIDs(includeIfBitSet: false).filter({ allowedSpellsOnMap.contains($0) })
        assert(reader.offset == offsetSaved + 9)
        
        // TODO add spells from mods.
        
        // Read castle events
        let eventCount = try reader.readUInt32()
        assert(eventCount <= 8192, "Cannot be more than 8192 town events... something is wrong. got: \(eventCount)")
        print("🏰 town: eventCount='\(eventCount)'")
        let events: [Map.Town.Event] = try eventCount.nTimes {
            let name = try reader.readString()
            let message = try reader.readString()
            let resources = try parseResources()
            let players = try parseAvailableForPlayers()
            let canBeActivatedByHuman = try format > .armageddonsBlade ? reader.readBool() : true
            let canBeActivatedByComputer = try reader.readBool()
            let firstOccurence = try reader.readUInt16()
            let nextOccurence = try reader.readUInt8()
            
            try reader.skip(byteCount: 17)
            
            // New buildings
            let buildings = try parseBuildings()
            let creatureStacks = try Creature.ID.of(faction: faction, .nonUpgradedOnly).map { creatureID in
                try CreatureStack(creatureID: creatureID, quantity: .init(reader.readUInt16()))
            }
            try reader.skip(byteCount: 4)
            
            let townEvent = Map.Event(
                message: message,
                firstOccurence: firstOccurence,
                nextOccurence: nextOccurence,
                resourcesToBeGained: resources,
                creaturesGained: .init(creatureStacks: creatureStacks),
                availableForPlayers: players,
                canBeActivatedByComputer: canBeActivatedByComputer,
                shouldBeRemovedAfterVisit: false, // is this correct?
                canBeActivatedByHuman: canBeActivatedByHuman
            )
            
            return Map.Town.Event(
                townID: townID,
                name: name,
                event: townEvent,
                buildings: buildings
            )
        }
        
        var alignment: Alignment?
        if format > .armageddonsBlade {
            alignment = try .init(integer: reader.readUInt8())
        }
        try reader.skip(byteCount: 3)
        
        return Map.Town(
            id: townID,
            faction: faction,
            owner: owner,
            name: name,
            garrison: garrison,
            formation: formation,
            buildings: buildings,
            spells: .init(
                obligatory: obligatorySpells,
                possible: possibleSpells
            ),
            events: events,
            alignment: alignment
        )
    }
}

public enum Alignment: UInt8, Hashable, CaseIterable {
    case good, evil, neutral
}

public extension Map.Town {
    struct Event: Hashable {
        public let townID: Map.Town.ID
        public let name: String
        public let event: Map.Event
        public let buildings: [Buildings.Building]
    }
}

// MARK: Private
private extension Map.Loader.Parser.H3M {
    
    func parseBuildings() throws -> [Map.Town.Buildings.Building] {
        try reader.readBitArray(byteCount: 6).prefix(Map.Town.Buildings.Building.allCases.count).enumerated().compactMap { (buildingID, isBuilt) in
           guard isBuilt else { return nil }
            return try Map.Town.Buildings.Building(integer: buildingID)
       }
    }
    
    func parseTownWithCustomBuildings() throws -> Map.Town.Buildings {
        let built = try parseBuildings()
        let forbidden = try parseBuildings()
        return .init(built: built, forbidden: forbidden)
    }
    
    func parseSimpleTown() throws -> Map.Town.Buildings {
        let hasFort = try reader.readBool()
        print("🏰 town: simpletown hasFort?='\(hasFort)'")
        let built = Map.Town.Buildings.Building.default(includeFort: hasFort)
        return .init(built: built, forbidden: [])
    }
}
