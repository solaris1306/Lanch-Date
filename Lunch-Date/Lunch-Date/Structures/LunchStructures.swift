//
//  LunchStructures.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 21.3.21..
//

import Foundation

struct LunchTeam: Codable {
    var firstEmployee: String
    var secondEmployee: String
}

struct LunchDay: Codable {
    var lunchTeams: [LunchTeam]
    var date: Date
    var dayName: String
}

struct LunchDays: Codable, Identifiable {
    let id: UUID
    var startDate: Date
    var endDate: Date
    var lunchDays: [LunchDay]
    var employees: [Employee]
    
    // MARK: - Intialization
    init(id: UUID = UUID(),
                  startDate: Date = Date(),
                  endDate: Date = Date(),
                  lunchDays: [LunchDay] = [],
                  employees: [Employee] = []) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.lunchDays = lunchDays
        self.employees = employees
    }
}
