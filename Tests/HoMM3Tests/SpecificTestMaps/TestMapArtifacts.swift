//
//  TestMapArtifacts.swift
//  Tests
//
//  Created by Alexander Cyon on 2021-09-01.
//

import XCTest
import Foundation
@testable import HoMM3SwiftUI

/// Map from: https://github.com/srg-kostyrko/homm3-parser/blob/master/__tests__/maps/artifacts.h3m

/// MIT License
///
/// Copyright (c) 2018 Sergey Kostyrko
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///
/// Map from: https://github.com/srg-kostyrko/homm3-parser/blob/master/__tests__/maps/artifacts.h3m

final class ArtifactsMapTest: BaseMapTest {
    
    func testLoad() throws {
        let inspector = Map.Loader.Parser.Inspector(
            basicInfoInspector: .init(
                onParseFormat: { XCTAssertEqual($0, .shadowOfDeath) },
                onParseName: { XCTAssertEqual($0, "") },
                onParseDescription: { XCTAssertEqual($0, "") },
                onParseDifficulty: { XCTAssertEqual($0, .normal) },
                onParseSize: { XCTAssertEqual($0, .small) },
                onFinishedParsingBasicInfo: { XCTAssertFalse($0.hasTwoLevels) }
            ),
            onParseObject: { object in
                if object.position == .at(15, y: 17) {
                    XCTAssertEqual(object.kind, .grail(.init(radius: 5)))
                } else {
                    
                    func assertArtifact(
                        id artifactID: Artifact.ID,
                        msg message: String? = nil,
                        stacks maybeStacks: [(CreatureStacks.Slot, CreatureStack)]? = nil,
                        line: UInt = #line
                    ) {
                        guard case let .artifact(guardedArtifact) = object.kind else {
                            XCTFail("Expected artifact, but got: \(object.kind)")
                            return
                        }
                        XCTAssertEqual(guardedArtifact.message, message, line: line)
                        if let stacks = maybeStacks {
                            let expectedCreatureStacks = CreatureStacks(stacksAtSlots: stacks)
                            XCTAssertEqual(guardedArtifact.guards, expectedCreatureStacks, line: line)
                        } else {
                            XCTAssertNil(guardedArtifact.guards, line: line)
                        }

                        let artifact = guardedArtifact.artifact
                        guard case let .specific(artifactID) = artifact.kind else {
                            XCTFail("Expected specific artifact id, but got: \(artifact.kind)")
                            return
                        }
                        XCTAssertEqual(artifactID, artifactID, line: line)
                    }
                    
                    func assertRandomArtifact(
                        `class` randomArtifactClass: Artifact.Class?,
                        msg message: String? = nil,
                        stacks maybeStacks: [(CreatureStacks.Slot, CreatureStack)]? = nil,
                        line: UInt = #line
                    ) {
                        guard case let .artifact(guardedArtifact) = object.kind else {
                            XCTFail("Expected artifact, but got: \(object.kind)")
                            return
                        }
                        XCTAssertEqual(guardedArtifact.message, message, line: line)
                        if let stacks = maybeStacks {
                            let expectedCreatureStacks = CreatureStacks(stacksAtSlots: stacks)
                            XCTAssertEqual(guardedArtifact.guards, expectedCreatureStacks, line: line)
                        } else {
                            XCTAssertNil(guardedArtifact.guards, line: line)
                        }

                        let artifact = guardedArtifact.artifact
                        guard case let .random(maybeRandomArtifactClass) = artifact.kind else {
                            XCTFail("Expected random artifact, but got: \(artifact.kind)")
                            return
                        }
                        XCTAssertEqual(randomArtifactClass, maybeRandomArtifactClass, line: line)
                    }
                    

                    
                    switch object.position {
                    case .at(1, y: 0):
                        XCTAssertSpellScroll(object) { spellScroll in
                            XCTAssertEqual(spellScroll, .init(id: .slow, message: "spell scroll slow"))
                        }
                    case .at(3, y: 0):
                        XCTAssertSpellScroll(object) { spellScroll in
                            XCTAssertEqual(
                                spellScroll,
                                .init(
                                    id: .visions,
                                    message: "spellscrol guardians",
                                    guardians: .init(creatureStackAtSlot: [
                                        .one: .init(creatureID: .griffin, quantity: 1),
                                        .six: .init(creatureID: .swordsman, quantity: 1)
                                    ])
                                )
                            )
                        }
                    case .at(1, y: 1):
                        assertArtifact(id: .centaurAxe, msg: "centaurus axe")
                    case .at(1, y: 2):
                        assertArtifact(id: .shieldOfTheDwarvenLords, msg: "shield dwarven lords")
                    case .at(1, y: 3):
                        assertArtifact(id: .helmOfTheAlabasterUnicorn, msg: "helm unicorn")
                    case .at(1, y: 4):
                        assertArtifact(id: .breastplateOfPetrifiedWood, msg: "breastplate of pertified wood")
                    case .at(1, y: 5):
                        assertArtifact(id: .sandalsOfTheSaint, msg: "sandals saint")
                    case .at(1, y: 6):
                        assertArtifact(id: .celestialNecklaceOfBliss, msg: "necklace bliss")
                    case .at(1, y: 7):
                        assertArtifact(id: .quietEyeOfTheDragon, msg: "eye dragon")
                    case .at(1, y: 12):
                        assertArtifact(id: .cloakOfTheUndeadKing, msg: "cloak undead king")
                    case .at(1, y: 14):
                        XCTAssertEqual(object.attributes.objectID, .randomArtifact)
                        assertRandomArtifact(class: .any, msg: "random", stacks: [
                            (CreatureStacks.Slot.one, .init(creatureID: .archer, quantity: 1)),
                            (CreatureStacks.Slot.seven, .init(creatureID: .archer, quantity: 1))
                        ])
                    default: break
                    }
                }
            }
        )
        try load(inspector: inspector)
    }
}

private extension ArtifactsMapTest {
    func load(inspector: Map.Loader.Parser.Inspector) throws {
        try loadMap(named: "artifacts", inspector: inspector)
    }
}

func XCTAssertSpellScroll(_ object: Map.Object, assert: (Map.SpellScroll) -> Void) {
    guard case let .spellScroll(spellScroll) = object.kind else {
        XCTFail("Expected spellScroll, but got: \(object.kind)")
        return
    }
    assert(spellScroll)
}

func XCTAssertArtifact(_ object: Map.Object, assert: (Map.GuardedArtifact) -> Void) {
    guard case let .artifact(artifact) = object.kind else {
        XCTFail("Expected artifact, but got: \(object.kind)")
        return
    }
    assert(artifact)
}
