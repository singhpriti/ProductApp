//
//  Product.swift
//  ProductApp
//
//  Created by Preity Singh on 28/07/24.
//

import Foundation

struct Product: Identifiable, Codable, Equatable {
    let id = UUID()
    let image: String
    let price: Double
    let productName: String
    let productType: String
    let tax: Double
    
    enum CodingKeys: String, CodingKey {
        case image, price
        case productName = "product_name"
        case productType = "product_type"
        case tax
    }
}

