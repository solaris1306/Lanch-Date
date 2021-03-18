//
//  Employee.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 18.3.21..
//

import Foundation

struct Employee: Codable, Identifiable {
    // MARK: - Properties
    let id: Int
    let name: String
    
    public static let placeholderEmployees: [Employee] = [
        Employee(id: 1, name: "Ivana"),
        Employee(id: 2, name: "Tim"),
        Employee(id: 3, name: "Jasmin"),
        Employee(id: 4, name: "Nicol"),
        Employee(id: 5, name: "Mark"),
        Employee(id: 6, name: "Max"),
        Employee(id: 7, name: "Jan"),
        Employee(id: 8, name: "Valerie"),
        Employee(id: 9, name: "Nina"),
        Employee(id: 10, name: "Felix")
    ]
}
