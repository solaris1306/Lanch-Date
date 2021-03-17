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
    var employeeNames: [String] = [] {
        didSet {
            getNewLunchSchedule()
        }
    }
    
    // MARK: - Methods
    mutating func getNewLunchSchedule() {
        var newLunchTeams: [[LunchTeam]] = []
        var newEmployeeNames: [String] = employeeNames
        
        guard newEmployeeNames.count > 2 && newEmployeeNames.count % 2 == 0 else {
            if newEmployeeNames.count == 2 {
                let oneTeam = LunchTeam(firstEmployee: newEmployeeNames[0],
                                        secondEmployee: newEmployeeNames[1])
                lunchTeams = [[oneTeam]]
            }
            return
        }
        
        newEmployeeNames.shuffle()
        let newCount: Int = newEmployeeNames.count / 2
        var firstHalfArray = Array(newEmployeeNames[0...newCount - 1])
        var secondHalfArray = Array(newEmployeeNames[newCount...newEmployeeNames.count - 1])
        
        for i in 0...newEmployeeNames.count - 2 {
            var oneLunchDay: [LunchTeam] = []
            if i > 0 {
                let lastOfFirst = firstHalfArray.removeLast()
                let firstOfSecond = secondHalfArray.removeFirst()
                firstHalfArray.insert(firstOfSecond, at: 1)
                secondHalfArray.append(lastOfFirst)
            }
            for j in 0...newCount - 1 {
                let firstEmployee: String = firstHalfArray[j]
                let secondEmployee: String = secondHalfArray[j]
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
