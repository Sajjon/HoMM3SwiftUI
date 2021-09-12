//
//  Map+Loader+Parser+H3M.swift
//  HoMM3SwiftUI
//
//  Created by Alexander Cyon on 2021-08-16.
//

import Foundation
import Malm
import Util

// MARK: H3M Parser
public extension Map.Loader.Parser {
    final class H3M {
        internal let readMap: Map.Loader.ReadMap
        internal let reader: DataReader
        internal let fileSizeCompressed: Int?
        public init(readMap: Map.Loader.ReadMap, fileSizeCompressed: Int? = nil) {
            self.readMap = readMap
            self.reader = DataReader(data: readMap.data)
            self.fileSizeCompressed = fileSizeCompressed
        }
    }
}

internal typealias H3M = Map.Loader.Parser.H3M

// MARK: Parse Map
extension H3M {
    func parse(inspector: Map.Loader.Parser.Inspector? = nil) throws -> Map {
        
        let checksum = CRC32.checksum(readMap.data)
        
        let basicInfo = try parseBasicInfo(inspector: inspector?.basicInfoInspector)
       
        let format = basicInfo.format
        let size = basicInfo.size
        
        let playersInfo = try parseInformationAboutPlayers(inspector: inspector?.playersInfoInspector, format: format)
        
        let additionalInfo = try parseAdditionalInfo(inspector: inspector?.additionalInformationInspector, format: format, playersInfo: playersInfo)

        let world = try parseTerrain(
            hasUnderworld: basicInfo.hasTwoLevels,
            size: size
        )
        assert(world.above.tiles.count == size.tileCount)
        inspector?.didParseWorld(world)
        
        let attributesOfObjects = try parseAttributesOfObjects()
        assert(attributesOfObjects.attributes.count < (world.above.tiles.count + (world.belowGround?.tiles.count ?? 0)))
        inspector?.didParseAttributesOfObjects(attributesOfObjects)
        
     
        let detailsAboutObjects = try parseDetailsAboutObjects(
            inspector: inspector,
            format: format,
            playersInfo: playersInfo,
            additionalMapInformation: additionalInfo,
            attributesOfObjects: attributesOfObjects
        )
        inspector?.didParseAllObjects(detailsAboutObjects)
        
        let globalEvents = try parseTimedEvents(format: format, availablePlayers: playersInfo.availablePlayers)
        inspector?.didParseEvents(globalEvents)
        
        return .init(
            checksum: checksum,
            basicInformation: basicInfo,
            playersInfo: playersInfo,
            additionalInformation: additionalInfo,
            world: world,
            attributesOfObjects: attributesOfObjects,
            detailsAboutObjects: detailsAboutObjects,
            globalEvents: globalEvents
        )
    }
}

internal extension H3M {


    func parseAllowedPlayers(availablePlayers: [Player]) throws -> [Player] {
        let players: [Player] = try parseBitmaskOfEnum()
        return players.filter { availablePlayers.contains($0) }
    }
    
    
    func parseHeroClass() throws -> Hero.Class? {
        let heroClassRaw = try reader.readUInt8()
        guard heroClassRaw != 0xff else { return nil }
        return try Hero.Class(integer: heroClassRaw)
    }
    
}
    
public typealias Bitmask = BitArray

// MARK: Parse "Attributes
private extension H3M {
    
    /// Parse object atributes
    /// Here are properties of all objects on the map including castles and heroes
    /// (but not land itself, roads and rivers) and Events, both placed on the map
    /// and global events (these are set in Map Specifications)
    func parseAttributesOfObjects() throws -> Map.AttributesOfObjects {
        let attributesCount = try reader.readUInt32()
        let attributes: [Map.Object.Attributes] = try (0..<attributesCount).compactMap { _ in
            /// aka "Sprite name"
            let animationFileName = try reader.readString()
            
            /// Which squares (of this object) are passable, counted from the bottom right corner
            /// (bit 1: passable, bit 0: impassable
            let passabilityBitmask = try reader.readBitArray(byteCount: Map.Object.Attributes.Pathfinding.rowCount)
            
            /// Active/visitable squares (overlaid on impassable squares)
            /// (bit 1: active, bit 0: passive
            let visitabilityBitmask = try reader.readBitArray(byteCount: Map.Object.Attributes.Pathfinding.rowCount)
            
            func allowedRelativePositions(bitmask: Bitmask) -> Set<Map.Object.Attributes.Pathfinding.RelativePosition> {
                precondition(bitmask.count == Map.Object.Attributes.Pathfinding.rowCount * Map.Object.Attributes.Pathfinding.columnCount)
                var index = 0
                var set = Set<Map.Object.Attributes.Pathfinding.RelativePosition>()
                for row in 0..<Map.Object.Attributes.Pathfinding.rowCount {
                    for column in 0..<Map.Object.Attributes.Pathfinding.columnCount {
                        defer { index += 1 }
                        let relativePosition: Map.Object.Attributes.Pathfinding.RelativePosition = .init(column: .init(column), row: .init(row))
                        let allowed = bitmask[index]
                        if allowed {
                            set.insert(relativePosition)
                        }
                    }
                }
                return set
            }
            
            
            let pathfinding = Map.Object.Attributes.Pathfinding(
                visitability: .init(relativePositionsOfVisitableTiles: allowedRelativePositions(bitmask: visitabilityBitmask)),
                passability: .init(relativePositionsOfPassableTiles: allowedRelativePositions(bitmask: passabilityBitmask))
            )
      
            func parseLandscapes() throws -> [Map.Tile.Terrain.Kind] {
                /// Alternative rawValue than `Map.Tile.Terrain.Kind` for some strange reason.
                enum TerrainKindEncoded: UInt8, CaseIterable {
                    case water, lava, subterranean, rock, swamp, snow, grass, sand, dirt
                    var toTerrain: Map.Tile.Terrain.Kind {
                        switch self {
                        case .water: return .water
                        case .lava: return .lava
                        case .subterranean: return .subterranean
                        case .rock: return .rock
                        case .swamp: return .swamp
                        case .snow: return .snow
                        case .grass: return .grass
                        case .sand: return .sand
                        case .dirt: return .dirt
                        }
                    }
                }
                return try parseBitmask(as: TerrainKindEncoded.self).map { $0.toTerrain }
            }
            
            /// what kinds of landscape it can be put on
            let supportedLandscapes = try parseLandscapes()
            
            /// What landscape group the object will be in the editor
            let mapEditorLandscapeGroup = try parseLandscapes()
            
            let objectIDRaw = try reader.readUInt32()
            
            let objectID = try Map.Object.ID(
                id: objectIDRaw,
                subId: reader.readUInt32()
            )

            /// used by editor
            let objectGroupRaw = try reader.readUInt8()
            let group: Map.Object.Attributes.Group? = .init(rawValue: objectGroupRaw)
            
            let inUnderworld = try reader.readBool()
            
            /// Unknown
            let unknownBytes = try reader.read(byteCount: 16)
    
            guard unknownBytes.allSatisfy({ $0 == 0x00 }) else {
                fatalError("If we hit this fatalError we can probably remove this check. I THINK I've identified behaviour that these 16 unknown bytes are always 16 zeroes. This might not be the case for some custom maps. I've added this assertion as a kind of 'offset check', meaning that it is helpful that we expect these 16 bytes to all be zero as an indicator that we are reading the correct values before at the expected offset in the maps byte blob.")
            }
            
            let attributes = Map.Object.Attributes(
                animationFileName: animationFileName,
                supportedLandscapes: supportedLandscapes,
                mapEditorLandscapeGroup: mapEditorLandscapeGroup,
                objectID: objectID,
                group: group,
                pathfinding: pathfinding,
                inUnderworld: inUnderworld
            )
            return attributes
        }
        
        
   
        return .init(attributes: attributes)
    }
}

private extension Map.Object.Attributes {
    static let invisibleHardcodedIntoEveryMapAttribute_RandomMonster: Self = .init(
        animationFileName: "AVWmrnd0.def",
        supportedLandscapes: [.water, .lava, .subterranean, .rock, .swamp, .snow, .grass, .sand],
        mapEditorLandscapeGroup: [.sand],
        objectID: .randomMonster,
        group: .monsters,
        pathfinding: Pathfinding(
            visitability: [(0, 5)],
            passability: [
                (0, 0), (0, 1), (1, 0), (2, 0), (3, 0), (0, 2), (0, 3), (0, 4), (4, 0), (5, 0), (6, 0), (7, 0), (1, 1), (1, 2), (2, 1), (2, 2), (3, 1), (4, 1), (5, 1), (6, 1), (3, 2), (4, 2), (1, 3), (7, 1), (2, 3), (3, 3), (4, 3), (5, 2), (6, 2), (7, 2), (5, 3), (1, 4), (6, 3), (7, 3), (1, 5), (2, 4), (2, 5), (3, 4), (4, 4), (5, 4), (3, 5), (4, 5), (5, 5), (6, 4), (6, 5), (7, 4), (7, 5)
            ]
        ),
        inUnderworld: false)
    
    static let invisibleHardcodedIntoEveryMapAttribute_Hole: Self = .init(
        animationFileName: "AVLholg0.def",
        supportedLandscapes: [.snow],
        mapEditorLandscapeGroup: [.snow],
        objectID: .hole,
        group: nil,
        pathfinding: Pathfinding(
            visitability: [],
            passability: [
                (0, 2), (7, 4), (0, 5), (2, 5), (0, 1), (7, 1), (6, 5), (7, 2), (5, 1), (4, 5), (4, 0), (4, 1), (6, 1), (5, 0), (1, 0), (2, 4), (6, 2), (5, 2), (0, 3), (2, 0), (3, 1), (0, 0), (3, 3), (4, 3), (1, 2), (2, 3), (0, 4), (3, 0), (1, 4), (6, 4), (4, 2), (3, 2), (1, 3), (6, 3), (4, 4), (3, 5), (1, 5), (1, 1), (5, 5), (2, 1), (7, 5), (7, 0), (6, 0), (5, 3), (3, 4), (5, 4), (7, 3), (2, 2)
            ]
        ),
        inUnderworld: true)
}


// MARK: Parse Events
internal extension H3M {
    
    func parseTimedEvent(
        format: Map.Format,
        availablePlayers: [Player]
    ) throws -> Map.TimedEvent {
        let name = try reader.readString(maxByteCount: 8192) // arbitrarily chosen
        let message = try reader.readString(maxByteCount: 29861) // Cyon: found to be max in Map Editor
        let resources = try parseResources()
        let affectedPlayers = try parseAllowedPlayers(availablePlayers: availablePlayers)
        let appliesToHumanPlayers = try format >= .shadowOfDeath ? reader.readBool() : true
        let appliesToComputerPlayers = try reader.readBool()
        let firstOccurence = try reader.readUInt16()
        let subsequentOccurenceRaw = try reader.readUInt8()
        let subsequentOccurence: Map.TimedEvent.Occurrences.Subsequent? = try subsequentOccurenceRaw == Map.TimedEvent.Occurrences.Subsequent.neverRawValue ? .never : Map.TimedEvent.Occurrences.Subsequent(integer: subsequentOccurenceRaw)

        try reader.skip(byteCount: 17)
        return .init(
            name: name,
            message: message,
            firstOccurence: firstOccurence,
            subsequentOccurence: subsequentOccurence,
            affectedPlayers: affectedPlayers,
            appliesToHumanPlayers: appliesToHumanPlayers,
            appliesToComputerPlayers: appliesToComputerPlayers,
            resources: resources
        )
    }
}

internal extension H3M {
    func parseTimedEvents(
        format: Map.Format,
        availablePlayers: [Player]
    ) throws -> Map.TimedEvents {
        let eventCount = try reader.readUInt32()
        let events: [Map.TimedEvent] = try eventCount.nTimes {
            try parseTimedEvent(format: format, availablePlayers: availablePlayers)
        }
        
        return .init(values: events.sorted(by: \.occurrences.first))
    }
    
}
