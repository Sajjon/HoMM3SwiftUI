//
//  File.swift
//  File
//
//  Created by Alexander Cyon on 2021-09-17.
//

import Foundation
import Malm
import Util
import H3M
import Combine

public final class AssetLoader {
    public let config: Config
    private let fileManager: FileManager
    public init(config: Config, fileManager: FileManager = .default) {
        self.config = config
        self.fileManager = fileManager
    }
}

// MARK: Error
public extension AssetLoader {
    enum Error: Swift.Error {
        case noAssetExistsAtPath(String)
        case failedToLoadAssetAtPath(String)
        case failedToLoadMap(id: Map.ID, error: Swift.Error)
        case failedToLoadBasicInfoOfMap(id: Map.ID, error: Swift.Error)
    }
}

// MARK: Load
public extension AssetLoader {
    func load(archive: Archive) throws -> ArchiveFile {
        let data = try loadContentsOfDataFile(name: archive.fileName)
        return ArchiveFile(kind: archive, data: data)
    }
    
    // TODO: Make private/internal, archives should not be leaked to clients.
    func loadArchives() -> AnyPublisher<[ArchiveFile], AssetLoader.Error> {
        Future { promise in
            DispatchQueue(label: "LoadArchives", qos: .background).async { [self] in
                do {
                    let assetFiles = try config.gamesFilesDirectories.allArchives.map(load(archive:))
                    promise(.success(assetFiles))
                } catch let error as AssetLoader.Error {
                    promise(.failure(error))
                } catch { uncaught(error: error, expectedType: AssetLoader.Error.self) }
            }
        }.eraseToAnyPublisher()
    }
    
    func loadMap(id mapID: Map.ID, inspector: Map.Loader.Parser.Inspector? = nil) -> AnyPublisher<Map, AssetLoader.Error> {
        Deferred {
            Future { promise in
                DispatchQueue(label: "Parse Map", qos: .background).async {
                    do {
                        print("✨ Loading map...")
                        let start = CFAbsoluteTimeGetCurrent()
                        let map = try Map.load(mapID, inspector: inspector)
                        let diff = CFAbsoluteTimeGetCurrent() - start
                        print(String(format: "✨✅ Successfully loaded map '%@', took %.1f seconds", map.basicInformation.name, diff))
                        promise(.success(map))
                    } catch {
                        promise(.failure(AssetLoader.Error.failedToLoadMap(id: mapID, error: error)))
                    }
                }
            }.eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    
    func loadBasicInfoForMap(id mapID: Map.ID, inspector: Map.Loader.Parser.Inspector.BasicInfoInspector? = nil) -> AnyPublisher<Map.BasicInformation, AssetLoader.Error> {
        Future { promise in
            DispatchQueue(label: "Parse Basic Info of Map", qos: .background).async {
                do {
                    print("✨ Loading basic info for map...")
                    let start = CFAbsoluteTimeGetCurrent()
                    let mapBasicInfo = try Map.loadBasicInform(mapID, inspector: inspector)
                    let diff = CFAbsoluteTimeGetCurrent() - start
                    print(String(format: "✨✅ Successfully loaded basic info for map '%@', took %.1f seconds", mapBasicInfo.name, diff))
                    promise(.success(mapBasicInfo))
                } catch {
                    promise(.failure(AssetLoader.Error.failedToLoadBasicInfoOfMap(id: mapID, error: error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func loadMapIDs() -> AnyPublisher<[Map.ID], AssetLoader.Error> {
        Future { promise in
            DispatchQueue(label: "LoadMapIDs", qos: .background).async { [self] in
                do {
                    let path = config.gamesFilesDirectories.maps
                    let mapDirectoryContents = try fileManager.contentsOfDirectory(atPath: path)
                    let urlToMaps = URL(fileURLWithPath: path)
                    let mapIDs: [Map.ID] = mapDirectoryContents.map {
                        let mapPath = urlToMaps.appendingPathComponent($0)
                        return Map.ID.init(absolutePath: mapPath.path)
                    }
                    promise(.success(mapIDs))
                } catch let error as AssetLoader.Error {
                    promise(.failure(error))
                } catch { uncaught(error: error, expectedType: AssetLoader.Error.self) }
            }
        }.eraseToAnyPublisher()
    }
    
    func loadBasicInfoForAllMaps() -> AnyPublisher<[Map.BasicInformation], AssetLoader.Error> {
        return loadMapIDs().flatMap { (ids: [Map.ID]) -> AnyPublisher<[Map.BasicInformation], AssetLoader.Error> in
            let publishers: [AnyPublisher<Map.BasicInformation, AssetLoader.Error>] = ids.map { [self] (id: Map.ID) -> AnyPublisher<Map.BasicInformation, AssetLoader.Error>  in
                let basicInfoPublisher: AnyPublisher<Map.BasicInformation, AssetLoader.Error> = loadBasicInfoForMap(id: id)
                return basicInfoPublisher
            }
            
            return Publishers.MergeMany(publishers).collect().eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}

// MARK: Private
private extension AssetLoader {
    
    func loadContentsOfFileAt(path: String) throws -> Data {
        guard fileManager.fileExists(atPath: path) else {
            throw Error.noAssetExistsAtPath(path)
        }
        guard let data = fileManager.contents(atPath: path) else {
            throw Error.failedToLoadAssetAtPath(path)
        }
        return data
    }
    
    /// `dataFile` as in an archive in the DATA directory
    func loadContentsOfDataFile(name dataFile: String) throws -> Data {
        let path = config.gamesFilesDirectories.data.appending(dataFile)
        return try loadContentsOfFileAt(path: path)
    }
}
