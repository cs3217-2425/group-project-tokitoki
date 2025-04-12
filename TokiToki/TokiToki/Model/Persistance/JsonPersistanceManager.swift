//
//  JsonPersistanceManager.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 10/4/25.
//

import Foundation

class JsonPersistenceManager {
    
    // File names
    internal let playersFileName = "players"
    internal let playerTokisFileName = "player_tokis"
    internal let playerEquipmentsFileName = "player_equipments"
    internal let skillsFileName = "Skills"
    internal var skillTemplates: [String: SkillData] = [:]
    internal var skillsFactory: SkillsFactory = SkillsFactory()
    
    // JSON Encoder/Decoder
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .secondsSince1970
        
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        // Load skill templates
        loadSkillTemplates()
    }
    
    func loadSkillTemplates() {
        do {
            let skillsData: SkillsData = try ResourceLoader.loadJSON(fromFile: "Skills")
            
            for skillData in skillsData.skills {
                skillTemplates[skillData.name] = skillData
            }
        } catch {
            print("Error loading Skill templates: \(error)")
        }
    }
    
    func getSkillTemplate(name: String) -> SkillData? {
        skillTemplates[name]
    }
    
    // MARK: - Directory and File Handling
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getFileURL(filename: String) -> URL {
        getDocumentsDirectory().appendingPathComponent(filename).appendingPathExtension("json")
    }
    
    internal func fileExists(filename: String) -> Bool {
        FileManager.default.fileExists(atPath: getFileURL(filename: filename).path)
    }
    
    // MARK: - Generic Read/Write Methods
    
    internal func saveToJson<T: Encodable>(_ object: T, filename: String) -> Bool {
        do {
            let data = try encoder.encode(object)
            try data.write(to: getFileURL(filename: filename))
            print("[JsonPersistenceManager] Successfully saved \(filename).json")
            return true
        } catch {
            print("Error saving \(filename).json: \(error)")
            return false
        }
    }
    
    internal func loadFromJson<T: Decodable>(filename: String) -> T? {
        let fileURL = getFileURL(filename: filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Try loading from Bundle if it doesn’t exist in Documents
            guard let bundleURL = Bundle.main.url(forResource: filename, withExtension: "json") else {
                print("File \(filename).json not found in bundle")
                return nil
            }
            return loadDataFromURL(url: bundleURL)
        }
        
        return loadDataFromURL(url: fileURL)
    }
    
    func loadDataFromURL<T: Decodable>(url: URL) -> T? {
        do {
            let data = try Data(contentsOf: url)
            let object = try decoder.decode(T.self, from: data)
            print("[JsonPersistenceManager] Successfully loaded \(url.lastPathComponent)")
            return object
        } catch {
            print("Error loading \(url): \(error)")
            return nil
        }
    }
    
    func deleteJson(filename: String) -> Bool {
        let fileURL = getFileURL(filename: filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return true // File doesn't exist => "successful" deletion
        }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Successfully deleted \(filename).json")
            return true
        } catch {
            print("Error deleting \(filename).json: \(error)")
            return false
        }
    }
    
    // MARK: - Initialization
    
    func initializeIfNeeded() {
        if !fileExists(filename: playersFileName) {
            let emptyPlayers: [PlayerCodable] = []
            _ = saveToJson(emptyPlayers, filename: playersFileName)
        }
        
        if !fileExists(filename: playerTokisFileName) {
            let emptyTokis: [TokiCodable] = []
            _ = saveToJson(emptyTokis, filename: playerTokisFileName)
        }
        
        if !fileExists(filename: playerEquipmentsFileName) {
            // Start empty
            let emptyEquipment: [PlayerEquipmentEntry] = []
            _ = saveToJson(emptyEquipment, filename: playerEquipmentsFileName)
        }
    }
}

