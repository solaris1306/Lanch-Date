//
//  ViewController.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 16.3.21..
//

import UIKit

struct LunchTeam {
    var firstEmployee: Employee?
    var secondEmployee: Employee?
}

struct Lunch {
    var lunchTeams: [[LunchTeam]] = []
}

enum TableCellNames: String {
    case lunchTeamCell = "lunchTeamCell"
}

class Employees {
    public static let employeesNames: [String] = ["Ivana", "Tim", "Jasmin", "Nicol", "Mark", "Max", "Jan", "Maria", "Fin", "Jessica"]
//    public static let employeesNames: [String] = ["Ivana", "Tim", "Jasmin", "Nicol"]
}

class Employee: Equatable {
    // MARK: - Public properties
    let name: String
    var availableLunchPartners: [Employee] = []
//    var unavailableLunchPartners: [Employee] = []
    
    // MARK: - Initialization
    init(name: String) {
        self.name = name
    }
    
    // MARK: - Methods
    func setNewAvailableLunchPartners(lunchPartners: [Employee]) {
        var newLunchPartners = lunchPartners
        newLunchPartners.removeAll(where: { $0 == self })
        availableLunchPartners = newLunchPartners
    }
    
    // MARK: - Equatable
    static func == (lhs: Employee, rhs: Employee) -> Bool {
        return lhs.name == rhs.name
    }
}

class ViewController: UIViewController {
    // MARK: - Private properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        return tableView
    }()
    private var allEmployees: [Employee] = [] {
        didSet {
            lunch = getNewLunchSchedule()
        }
    }
    
    private var lunch: Lunch = Lunch() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(LunchTeamCell.self, forCellReuseIdentifier: TableCellNames.lunchTeamCell.rawValue)
        
        allEmployees = getAllEmployees()
    }
    
}

// MARK: - Private methods

private extension ViewController {
    func getAllEmployees() -> [Employee] {
        var allEmployees: [Employee] = []
        
        for employeeName in Employees.employeesNames {
            let newEmployee = Employee(name: employeeName)
            allEmployees.append(newEmployee)
        }
        for employee in allEmployees {
            employee.setNewAvailableLunchPartners(lunchPartners: allEmployees)
        }
        
        return allEmployees
    }
    
    func getNewLunchSchedule() -> Lunch {
        var lunch = Lunch()
        guard allEmployees.count > 2 && allEmployees.count % 2 == 0 else {
            if allEmployees.count == 2 {
                let oneTeam = LunchTeam(firstEmployee: allEmployees[0],
                                        secondEmployee: allEmployees[1])
                lunch.lunchTeams = [[oneTeam]]
            }
            return lunch
        }
        for _ in 0...allEmployees.count - 2 {
            var oneLunchDay: [LunchTeam] = []
            var freeTeamMembers: [Employee] = allEmployees
//            var busyTeamMembers: [Employee] = []
            while freeTeamMembers.count > 0 {
                if freeTeamMembers.count == 2 {
                    let firstTeamMember = freeTeamMembers[0]
                    let secondTeamMember = freeTeamMembers[1]
                    var currentCount = freeTeamMembers.count
                    freeTeamMembers.removeAll(where: { $0 == firstTeamMember })
                    var newCount = freeTeamMembers.count
                    if currentCount == newCount {
                        print("\(firstTeamMember.name) is not removed.")
                    }
                    currentCount = freeTeamMembers.count
                    freeTeamMembers.removeAll(where: { $0 == secondTeamMember })
                    newCount = freeTeamMembers.count
                    if currentCount == newCount {
                        print("\(secondTeamMember.name) is not removed.")
                    }
                    firstTeamMember.availableLunchPartners.removeAll(where: { $0 == secondTeamMember })
                    secondTeamMember.availableLunchPartners.removeAll(where: { $0 == firstTeamMember })
                    let oneTeam = LunchTeam(firstEmployee: firstTeamMember,
                                            secondEmployee: secondTeamMember)
                    oneLunchDay.append(oneTeam)
                } else {
                    let firstTeamMemberIndex = Int.random(in: 0..<freeTeamMembers.count)
                    let firstTeamMember = freeTeamMembers[firstTeamMemberIndex]
                    let secondTeamMemberIndex = firstTeamMember.availableLunchPartners.count > 1 ? Int.random(in: 0..<firstTeamMember.availableLunchPartners.count) : 0
                    let secondTeamMember = firstTeamMember.availableLunchPartners[secondTeamMemberIndex]
                    var currentCount = freeTeamMembers.count
                    freeTeamMembers.removeAll(where: { $0 == firstTeamMember })
                    var newCount = freeTeamMembers.count
                    if currentCount == newCount {
                        print("\(firstTeamMember.name) is not removed.")
                    }
                    currentCount = freeTeamMembers.count
                    freeTeamMembers.removeAll(where: { $0 == secondTeamMember })
                    newCount = freeTeamMembers.count
                    if currentCount == newCount {
                        print("\(secondTeamMember.name) is not removed.")
                    }
                    firstTeamMember.availableLunchPartners.removeAll(where: { $0 == secondTeamMember })
                    secondTeamMember.availableLunchPartners.removeAll(where: { $0 == firstTeamMember })
                    let oneTeam = LunchTeam(firstEmployee: firstTeamMember,
                                            secondEmployee: secondTeamMember)
                    oneLunchDay.append(oneTeam)
                }
            }
            lunch.lunchTeams.append(oneLunchDay)
        }
        return lunch
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return lunch.lunchTeams.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lunch.lunchTeams[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableCellNames.lunchTeamCell.rawValue, for: indexPath) as? LunchTeamCell else {
            return UITableViewCell()
        }
        let oneTeam: LunchTeam = lunch.lunchTeams[indexPath.section][indexPath.row]
        cell.firstEmployeeNameLabel.text = oneTeam.firstEmployee?.name
        cell.secondEmployeeNameLabel.text = oneTeam.secondEmployee?.name
        return cell
    }
}
