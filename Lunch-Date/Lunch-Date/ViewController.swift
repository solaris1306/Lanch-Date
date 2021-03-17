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
}

class Employee: Equatable {
    // MARK: - Public properties
    let name: String
    var unavailableLunchPartners: Set<String> = []
    
    // MARK: - Initialization
    init(name: String) {
        self.name = name
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
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
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
            var freeTeamMemberNames: Set<String> = Set(Employees.employeesNames)
            for employee in allEmployees {
                employee.unavailableLunchPartners = [employee.name]
            }
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
                    secondTeamMember?.unavailableLunchPartners.insert(firstTeamMember.name)
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
        cell.teamLabel.text = oneTeam.firstEmployee!.name + " - " + oneTeam.secondEmployee!.name
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "DAY \(section + 1)"
    }
}
