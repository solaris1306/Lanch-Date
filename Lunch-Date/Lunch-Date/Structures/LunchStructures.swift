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

struct LunchDays: Codable {
    var startDate: Date
    var endDate: Date
    var lunchDays: [LunchDay]
    var employees: [Employee]
    
    public static let emptyDays = LunchDays(startDate: Date(),
                                            endDate: Date(),
                                            lunchDays: [],
                                            employees: [])
}
