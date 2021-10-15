//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-10-11.
//

import Foundation

extension Laka.Textures {
    
    private var passableTerrain: [String] { [
        "avlhold0.def",
        "avlklp10.def",
        "avlklp20.def",
        "avxfw0.def",
        "avxfw1.def",
        "avxfw2.def",
        "avxfw3.def",
        "avxfw4.def",
        "avxfw5.def",
        "avxfw6.def",
        "avxfw7.def",
        "avlholg0.def",
        "avlholl0.def",
        "avlholr0.def",
        "avlhlds0.def",
        "avlhols0.def",
        "avlhlsn0.def",
        "avlholx0.def",
        "avxcrsd0.def",
        "avxcg1.def",
        "avxcg2.def",
        "avxcg3.def",
        "avxcg4.def",
        "avxcg5.def",
        "avxcg6.def",
        "avxcg7.def",
        "avxplns0.def",
        "avxmp1.def",
        "avxmp2.def",
        "avxmp3.def",
        "avxmp6.def",
        "avxmp4.def",
        "avxmp5.def",
        "avxmp7.def",
        "avxcf0.def",
        "avxcf1.def",
        "avxcf2.def",
        "avxcf3.def",
        "avxcf4.def",
        "avxcf5.def",
        "avxcf6.def",
        "avxcf7.def",
        "avxef0.def",
        "avxef1.def",
        "avxef2.def",
        "avxef3.def",
        "avxef4.def",
        "avxef5.def",
        "avxef6.def",
        "avxef7.def",
        "avxff0.def",
        "avxff1.def",
        "avxff2.def",
        "avxff3.def",
        "avxff4.def",
        "avxff5.def",
        "avxff6.def",
        "avxff7.def",
        "avxhg2.def",
        "avxhg1.def",
        "avxhg0.def",
        "avxhg3.def",
        "avxhg4.def",
        "avxhg5.def",
        "avxhg6.def",
        "avxhg7.def",
        "avxlp0.def",
        "avxlp3.def",
        "avxlp2.def",
        "avxlp1.def",
        "avxlp6.def",
        "avxlp5.def",
        "avxlp4.def",
        "avxlp7.def",
        "avxmc0.def",
        "avxmc1.def",
        "avxmc2.def",
        "avxmc3.def",
        "avxmc4.def",
        "avxmc5.def",
        "avxmc6.def",
        "avxmc7.def",
        "avxrk2.def",
        "avxrk1.def",
        "avxrk0.def",
        "avxrk5.def",
        "avxrk4.def",
        "avxrk3.def",
        "avxrk6.def",
        "avxrk7.def"
    ]
    }
    
    
    func exportPassableTerrain() throws {
        let passableTerrainFiles = passableTerrain.map { defFileName in
            DefImageExport(defFileName: defFileName, nameFromFrameAtIndexIndex: { _, _ in defFileName })
        }
        
        try generateTexture(
            name: "passable_terrain",
            list: passableTerrainFiles.map { .def($0) },
            maxImageCountPerDefFile: 1
        )
    }
}