//
//  Order.swift
//  CupcakeCorner
//
//  Created by hn on 2025/10/23.
//

import Foundation

struct Order : Codable, Equatable {
    var type = 0
    var quantity = 3
    var specialRequestEnabled = false
    var extraFrosting = false
    var addSprinkles = false
    var name = ""
    var streetAddress = ""
    var city = ""
    var zip = ""
    
    init(cornerState: CupcakeCornerFeature.State, addressState: AddressFeature.State) {
        type = cornerState.type
        quantity = cornerState.quantity
        specialRequestEnabled = cornerState.specialRequestEnabled
        extraFrosting = cornerState.extraFrosting
        addSprinkles = cornerState.addSprinkles
        name = addressState.name
        streetAddress = addressState.streetAddress
        city = addressState.city
        zip = addressState.zip
    }
}
