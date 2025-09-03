//
//  Model.swift
//  PropertyList APP
//
//  Created by Droisys on 26/08/25.
//

import Foundation

struct Property: Codable {
    let id: Int
    let title: String
    let detail: String
    let image: String
    let price: String
    let latitude: Double
    let longitude: Double
}

struct PropertyResponse: Codable {
    let properties: [Property]
}
