//
//  ResourceLoader.swift
//  TokiToki
//
//  Created by wesho on 17/3/25.
//

import Foundation

enum ResourceError: Error {
    case fileNotFound
    case parseError(String)
}

class ResourceLoader {
    static func loadJSON<T: Decodable>(fromFile filename: String, fileExtension: String = "json") throws -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            throw ResourceError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let error {
            throw ResourceError.parseError(error.localizedDescription)
        }
    }
}
