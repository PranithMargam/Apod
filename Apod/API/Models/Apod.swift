//
//  Apod.swift
//  Apod
//
//  Created by Pranith Margam on 08/04/21.
//

import Foundation

struct APOD: Codable {
    let date: String
    let url: String
    let title: String
    let explanation: String
    let hdurl: String
    static let lastSavedApodKey = "lastSavedAPOD"
    
    static func lastSavedApod() -> APOD? {
        if let lastSavedApodData = UserDefaults.standard.object(forKey: APOD.lastSavedApodKey) as? Data {
            let decoder = JSONDecoder()
            if let lastSavedApod = try? decoder.decode(APOD.self, from: lastSavedApodData) {
                return lastSavedApod
            }
        }
        return nil
    }
    
    static func savelastViewedAPOD(_ apod: APOD) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(apod) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: APOD.lastSavedApodKey)
        }
    }
}

