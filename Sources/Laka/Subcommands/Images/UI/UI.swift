//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-10-06.
//

import Foundation
import ArgumentParser
import Guld
import Malm
import Util

extension Laka {
    
    /// A command to extract all images used to render UI of original game,
    /// which includes game menus, and all in game menus, except for in town
    /// UI.
    struct UI: ParsableCommand, TextureGenerating {
        
        static var configuration = CommandConfiguration(
            abstract: "Extract images used to render UI of original game."
        )
        
        @OptionGroup var parentOptions: Options
    }
}

// MARK: Computed props
extension Laka.UI {
    
    var verbose: Bool { parentOptions.printDebugInformation }

    
    var inDataURL: URL {
        .init(fileURLWithPath: parentOptions.outputPath).appendingPathComponent("Raw")
    }
    
    var outImagesURL: URL {
        .init(fileURLWithPath: parentOptions.outputPath)
            .appendingPathComponent("Converted")
            .appendingPathComponent("UI")
    }
}



// MARK: Run
extension Laka.UI {
    
    mutating func run() throws {
        print(
            """
            
            🔮
            About to extract all images used to render UI of original game, from entries exported by the `Laka LOD` command.
            Located at: \(inDataURL.path)
            To folder: \(outImagesURL.path)
            This will take about 9 seconds on a fast machine (Macbook Pro 2019 - Intel CPU)
            ☕️
            
            """
        )
        
        try exportArmyIcons()
        try exportArmyIconsSmall()
        try exportArtifacts()
        try exportFlags()
        try exportHallBuildings()
        try exportPrimarySkill()
        try exportSecondarySkill()
        try exportSpells()
        try exportSpellScrolls()
        try exportSpellTabs()
        try exportMagicSchools()
        try exportResource()
        try exportDialogBorder()
        try exportArmyBackgrounds()
        try exportMageGuild()
        try exportSpellBookBackground()
        try exportSpellBookCornerRight()
        try exportSpellBookCornerLeft()
        try exportHeroStatsSummaryBackground()
        try exportDialogBoxBackground()
        try exportDialogBoxBackgroundSmall()
        try exportCreatureStatsSummaryBackground()
        try exportLogo()
        try exportFormatArmageddonsBlade()
        try exportFormatRestorationOfErathia()
        try exportFormatShadowOfDeath()
        try exportHeroButton()
        try exportUndergroundButton()
        try exportCancelButton()
        try exportOKButton()
        try exportMainMenuLoadGameButton()
        try exportSizeSmallButton()
        try exportSizeMediumButton()
        try exportSizeLargeButton()
        try exportSizeExtraLargeButton()
    }
    
    func exportArtifacts() throws {
        try generateTexture(
            atlasName: "artifacts",
            defFileName: "artifact.def"
        ) { frame, frameIndex in
            let namePrefix = "artifact_icon"
            if let artifactID = try? Artifact.ID(integer: frameIndex) {
                return [namePrefix, String(describing: artifactID)].joined(separator: "_")
            } else {
                /// Special case artifacts
                return [namePrefix, frame.fileName.lowercased()].joined(separator: "_")
            }
        }
    }
    
    func exportFlags() throws {
        try generateTexture(
            atlasName: "flags",
            defFileName: "crest58.def"
        )
    }
    
    func exportPrimarySkill() throws {
        try generateTexture(
            atlasName: "primary_skill",
            defFileName: "pskill.def"
        )
    }
    
    func exportSecondarySkill() throws {
        try generateTexture(
            atlasName: "secondary_skill",
            defFileName: "secskill.def"
        ) { frame, frameIndex in
            let namePrefix = "secondary_skill"
            let offset = 1
            let iconsPerSkill = Hero.SecondarySkill.Level.allCases.count
            guard frameIndex >= offset*iconsPerSkill else { return nil } // ignore empty
            let value = frameIndex - offset*iconsPerSkill
            let valueQaR = value.quotientAndRemainder(dividingBy: iconsPerSkill)
            let skillKindRaw = valueQaR.quotient
            let skillLeveKindRaw = valueQaR.remainder
            let skillKind = try Hero.SecondarySkill.Kind(integer: skillKindRaw)
            let skillLevel = try Hero.SecondarySkill.Level(integer: skillLeveKindRaw + 1)
            return [
                namePrefix,
                String(describing: skillKind),
                String(describing: skillLevel),
            ].joined(separator: "_")
        }
    }
    
    func exportSpells() throws {
        try generateTexture(
            atlasName: "spells",
            defFileName: "spells.def"
        ) { frame, frameIndex in
            let namePrefix = "spell_icon"
            let spellID = try Spell.ID(integer: frameIndex)
            return [namePrefix, String(describing: spellID)].joined(separator: "_")
        }
    }
    
    func exportSpellScrolls() throws {
        try generateTexture(
            atlasName: "spell_scrolls",
            defFileName: "spellscr.def"
        )  { frame, frameIndex in
            let namePrefix = "spell_icon"
            do {
                let spellID = try Spell.ID(integer: frameIndex)
                return [namePrefix, String(describing: spellID)].joined(separator: "_")
            } catch {
                guard frame.fileName.lowercased() == "sm99all.pcx" else {
                    incorrectImplementation(reason: "Have covered all spell scrolls")
                }
                let humanReadable = "every_spell_in_the_game"
                return [namePrefix, humanReadable].joined(separator: "_")
            }
        }
    }
    
    func exportSpellTabs() throws {
        try generateTexture(
            atlasName: "spell_tabs",
            defFileName: "speltab.def"
        )
    }
    
    func exportMagicSchools() throws {
        try generateTexture(
            atlasName: "magic_schools",
            defFileName: "schools.def"
        )
    }
    
    func exportResource() throws {
        try generateTexture(
            atlasName: "resource_icons",
            defFileName: "resource.def"
        )
    }
    
    func exportDialogBorder() throws {
        try generateTexture(
            atlasName: "dialog_border_image",
            defFileName: "dialgbox.def"
        )
    }
    
    func exportMageGuild() throws {
        try generateTexture(
            imageName: "mage_guild.png",
            pcxImageName: "tpmage.pcx"
        )
    }
    
    func exportSpellBookBackground() throws {
        try generateTexture(
            imageName: "spellbook_background.png",
            pcxImageName: "spelback.pcx"
        )
    }

    func exportSpellBookCornerRight() throws {
        try generateTexture(
            imageName: "spellbook_corner_right.png",
            pcxImageName: "speltrnr.pcx"
        )
    }
    
    func exportSpellBookCornerLeft() throws {
        try generateTexture(
            imageName: "spellbook_corner_left.png",
            pcxImageName: "speltrnl.pcx"
        )
    }
    
    func exportHeroStatsSummaryBackground() throws {
        try generateTexture(
            imageName: "hero_stats_summary_background.png",
            pcxImageName: "heroqvbk.pcx"
        )
    }
    
    func exportDialogBoxBackgroundSmall() throws {
        try generateTexture(
            imageName: "dialog_box_background_small.png",
            pcxImageName: "dibox128.pcx"
        )
    }
    
    func exportDialogBoxBackground() throws {
        try generateTexture(
            imageName: "dialog_box_background.png",
            pcxImageName: "diboxbck.pcx"
        )
    }
    
    func exportCreatureStatsSummaryBackground() throws {
        try generateTexture(
            imageName: "creature_stats_summary_background.png",
            pcxImageName: "crstkpu.pcx"
        )
    }
    
    func exportLogo() throws {
        try generateTexture(
            imageName: "logo.png",
            pcxImageName: "puzzlogo.pcx",
            usePaletteReplacementMap: false
        )
    }
    
    func exportFormatArmageddonsBlade() throws {
        try exportButton(
            name: "main_menu_campaign_armageddons_blade",
            defFileName: "cssarm.def"
        )
    }
    
    func exportButton(
        name buttonName: String,
        defFileName: String,
        maxImageCountPerDefFile: Int? = nil
    ) throws {
        let button = "button"
        let atlasName = [
            buttonName,
            button
        ].joined(separator: "_")
        
        try generateTexture(
            atlasName: atlasName,
            defFileName: defFileName,
            skipImagesWithSameNameAndData: true,
            maxImageCountPerDefFile: maxImageCountPerDefFile
        ) { frame, frameIndex in
            let frameName = String(frame.fileName.lowercased().split(separator: ".").first!)
            let normal = frameName.hasSuffix("n")
            let disabled = frameName.hasSuffix("d")
            let selected = frameName.hasSuffix("s")
            let highlighted = frameName.hasSuffix("h")
            
            let buttonStateName: String
            if normal {
                buttonStateName = "normal"
            } else if disabled {
                buttonStateName = "disabled"
            } else  if selected {
                buttonStateName = "selected"
            } else  if highlighted {
                buttonStateName = "highlighted"
            } else {
                incorrectImplementation(reason: "Non supported button state, frame name: '\(frame.fileName)'")
            }
            
            return [
                buttonName,
               button,
                buttonStateName
            ].joined(separator: "_")
        }
    }
    
    
    func exportFormatRestorationOfErathia() throws {
        try exportButton(
            name: "main_menu_campaign_restoration_of_erathia",
            defFileName: "cssroe.def"
        )
    }
    
    func exportFormatShadowOfDeath() throws {
        try exportButton(
            name: "main_menu_campaign_shadow_of_death",
            defFileName: "csssod.def"
        )
    }
    
    func exportHeroButton() throws {
        try exportButton(
            name: "hero",
            defFileName: "iam000.def"
        )
    }
    
    func exportUndergroundButton() throws {
        try exportButton(
            name: "underground",
            defFileName: "ranundr.def"
        )
    }
    
    func exportCancelButton() throws {
        try exportButton(
            name: "cancel",
            defFileName: "icancel.def"
        )
    }
    
    func exportOKButton() throws {
        try exportButton(
            name: "ok",
            defFileName: "iokay.def"
        )
    }
    
    func exportMainMenuLoadGameButton() throws {
        try exportButton(
            name: "main_menu_load_game",
            defFileName: "mmenulg.def"
        )
    }
    
    func exportSizeLargeButton() throws {
        try exportButton(
            name: "size_large",
            defFileName: "ransizl.def"
        )
    }
    
    
    func exportSizeMediumButton() throws {
        try exportButton(
            name: "size_medium",
            defFileName: "ransizm.def"
        )
    }
    
    func exportSizeSmallButton() throws {
        try exportButton(
            name: "size_small",
            defFileName: "ransizs.def"
        )
    }
    
    func exportSizeExtraLargeButton() throws {
        try exportButton(
            name: "size_extra_large",
            defFileName: "ransizx.def"
        )
    }
}

