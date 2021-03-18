//
//  Lunch.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 17.3.21..
//

import Foundation

struct Lunch {
    // MARK: - Helper structures
    struct LunchTeam {
        var firstEmployee: String
        var secondEmployee: String
    }
    // MARK: - Properties
    private var lunchTeams: [[LunchTeam]] = [] {
        didSet {
            shownLunchTeams = lunchTeams
        }
    }
    var shownLunchTeams: [[LunchTeam]] = []
    var employees: [Employee] = [] {
        didSet {
            getNewLunchSchedule()
        }
    }
    
    // MARK: - Methods
    mutating func getNewLunchSchedule() {
        var newLunchTeams: [[LunchTeam]] = []
        var newEmployees: [Employee] = employees
        
        guard newEmployees.count > 2 && newEmployees.count % 2 == 0 else {
            if newEmployees.count == 2 {
                let oneTeam = LunchTeam(firstEmployee: newEmployees[0].name,
                                        secondEmployee: newEmployees[1].name)
                lunchTeams = [[oneTeam]]
            }
            return
        }
        
        newEmployees.shuffle()
        let newCount: Int = newEmployees.count / 2
        var firstHalfArray = Array(newEmployees[0...newCount - 1])
        var secondHalfArray = Array(newEmployees[newCount...newEmployees.count - 1])
        
        for i in 0...newEmployees.count - 2 {
            var oneLunchDay: [LunchTeam] = []
            if i > 0 {
                let lastOfFirst = firstHalfArray.removeLast()
                let firstOfSecond = secondHalfArray.removeFirst()
                firstHalfArray.insert(firstOfSecond, at: 1)
                secondHalfArray.append(lastOfFirst)
            }
            for j in 0...newCount - 1 {
                let firstEmployee: String = firstHalfArray[j].name
                let secondEmployee: String = secondHalfArray[j].name
                let oneTeam = LunchTeam(firstEmployee: firstEmployee,
                                        secondEmployee: secondEmployee)
                oneLunchDay.append(oneTeam)
            }
            oneLunchDay.shuffle()
            newLunchTeams.append(oneLunchDay)
        }
        lunchTeams = newLunchTeams
    }
}
