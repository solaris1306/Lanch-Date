//
//  Lunch.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 17.3.21..
//

import Foundation

struct Lunch {
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
    
    var shownTeamsChangedClosure: (() -> ())?
    
    struct LunchTeam {
        var firstEmployee: Employee
        var secondEmployee: Employee
    }
    
    // MARK: - Methods
    mutating func getNewLunchSchedule() {
        lunchTeams = []
        var allEmployees: [Employee] = []
        
        for employeeName in employeeNames {
            let newEmployee = Employee(name: employeeName)
            allEmployees.append(newEmployee)
        }
        
        guard allEmployees.count > 2 && allEmployees.count % 2 == 0 else {
            if allEmployees.count == 2 {
                let oneTeam = LunchTeam(firstEmployee: allEmployees[0],
                                        secondEmployee: allEmployees[1])
                lunchTeams = [[oneTeam]]
            }
            return
        }
        
        for _ in 0...allEmployees.count - 2 {
            var oneLunchDay: [LunchTeam] = []
            var freeTeamMembers: [Employee] = allEmployees
            var freeTeamMemberNames: Set<String> = Set(employeeNames)
            while freeTeamMembers.count > 0 {
                if freeTeamMembers.count == 2 {
                    let firstTeamMember = freeTeamMembers[0]
                    let secondTeamMember = freeTeamMembers[1]
                    freeTeamMembers.removeAll(where: { $0 == firstTeamMember })
                    freeTeamMembers.removeAll(where: { $0 == secondTeamMember })
                    freeTeamMemberNames.remove(firstTeamMember.name)
                    freeTeamMemberNames.remove(secondTeamMember.name)
                    firstTeamMember.unavailableLunchPartners.insert(secondTeamMember.name)
                    secondTeamMember.unavailableLunchPartners.insert(firstTeamMember.name)
                    let oneTeam = LunchTeam(firstEmployee: firstTeamMember,
                                            secondEmployee: secondTeamMember)
                    oneLunchDay.append(oneTeam)
                } else {
                    let firstTeamMemberIndex = Int.random(in: 0..<freeTeamMembers.count)
                    let firstTeamMember = freeTeamMembers[firstTeamMemberIndex]
                    let availableNames: [String] = freeTeamMemberNames.subtracting(firstTeamMember.unavailableLunchPartners).map { $0 }
                    let secondTeamMemberName = availableNames.count > 1 ? Int.random(in: 0..<availableNames.count) : 0
                    let secondTeamMember = freeTeamMembers.first(where: { $0.name == availableNames[secondTeamMemberName] })
                    freeTeamMembers.removeAll(where: { $0 == firstTeamMember })
                    freeTeamMembers.removeAll(where: { $0 == secondTeamMember })
                    freeTeamMemberNames.remove(firstTeamMember.name)
                    freeTeamMemberNames.remove(secondTeamMember!.name)
                    firstTeamMember.unavailableLunchPartners.insert(secondTeamMember!.name)
                    secondTeamMember!.unavailableLunchPartners.insert(firstTeamMember.name)
                    let oneTeam = LunchTeam(firstEmployee: firstTeamMember,
                                                  secondEmployee: secondTeamMember!)
                    oneLunchDay.append(oneTeam)
                }
            }
            lunchTeams.append(oneLunchDay)
        }
    }
}
