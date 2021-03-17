//
//  Employee.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 17.3.21..
//

import Foundation

class Employee: Equatable {
    // MARK: - Public properties
    let name: String
    var unavailableLunchPartners: Set<String> = []
    
    // MARK: - Initialization
    init(name: String) {
        self.name = name
        self.unavailableLunchPartners.insert(name)
    }
    
    // MARK: - Equatable
    static func == (lhs: Employee, rhs: Employee) -> Bool {
        return lhs.name == rhs.name
    }
}
