//
//  File.swift
//  File
//
//  Created by Alexander Cyon on 2021-09-17.
//

import Foundation
import Malm
import Util
import Combine

public enum LoadedAsset: Hashable, NamedAssetFile {
    case archive(LodFile)
    case sound(SNDFile)
    case video(VIDFile)
    
    public var fileName: String {
        switch self {
        case .archive(let lodFile):
            return lodFile.lodFileName
        case .sound(let sndFile):
            return sndFile.sndArchiveFileName
        case .video(let vidFie):
            return vidFie.videoArchiveFileName
        }
    }
}

public final class ArchiveLoader {
    public init() {}
}

public extension ArchiveLoader {
    
    typealias Error = LodParser.Error
    
    func loadArchive(assetFile: AssetFile) -> AnyPublisher<LoadedAsset, Error> {
        return Future { promise in
            DispatchQueue(label: "LoadArchive", qos: .background).async {
                do {
                    switch assetFile.kind {
                    case .sound:
                        let sndArchiveParser = SNDArchiveParser()
                        let sndFile = try sndArchiveParser.parse(assetFile: assetFile)
                        let loadedAsset: LoadedAsset = .sound(sndFile)
                        promise(Result.success(loadedAsset))
                    case .archive:
                        let lodParser = LodParser()
                        let lodFile = try lodParser.parse(assetFile: assetFile)
                        let loadedAsset: LoadedAsset = .archive(lodFile)
                        promise(Result.success(loadedAsset))
                    case .video:
                        let vidParser = VIDArchiveParser()
                        let vidArchiveFile = try vidParser.parse(assetFile: assetFile)
                        let loadedAsset: LoadedAsset = .video(vidArchiveFile)
                        promise(Result.success(loadedAsset))
                    }
                } catch let error as Error {
                    promise(Result.failure(error))
                } catch { uncaught(error: error, expectedType: Error.self) }
            }
        }.eraseToAnyPublisher()
    }
}