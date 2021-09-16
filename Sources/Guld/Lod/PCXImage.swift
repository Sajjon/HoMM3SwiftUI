//
//  File.swift
//  File
//
//  Created by Alexander Cyon on 2021-09-16.
//

import Foundation

public struct PCXImage: Hashable {
    public let width: Int
    public let height: Int
    public let contents: Contents
    
    public enum Contents: Hashable {
        case rawRGBPixelData(Data)
        case pixdelData(Data, encodedByPalette: Palette)
    }
}
