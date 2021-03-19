//
//  ViewController.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 16.3.21..
//

import UIKit
import Combine

class ViewController: UIViewController {
    // MARK: - Private properties
    private var lunch = Lunch()
    private var subscriptions = Set<AnyCancellable>()
    private let employeesUrlString: String = "https://jsonplaceholder.typicode.com/users"
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(LunchTeamCell.self, forCellReuseIdentifier: String(describing: LunchTeamCell.self))
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        lunch.employeesUrlString = employeesUrlString
        
        lunch.$currentlyShownLunchInformations
            .sink(receiveValue: { _ in
                DispatchQueue.main.async { [weak self] in
                    if let self = self {
                        self.tableView.reloadData()
                    }
                }
            })
            .store(in: &subscriptions)
    }
    
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return lunch.currentlyShownLunchInformations.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lunch.currentlyShownLunchInformations[section].lunchTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LunchTeamCell.self), for: indexPath) as? LunchTeamCell else {
            return UITableViewCell()
        }
        let oneTeam: Lunch.LunchTeam = lunch.currentlyShownLunchInformations[indexPath.section].lunchTeams[indexPath.row]
        cell.teamLabel.text = oneTeam.firstEmployee + " - " + oneTeam.secondEmployee
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let lunchDay: Lunch.LunchDay = lunch.currentlyShownLunchInformations[section]
        return  lunchDay.dayName + "  " + dateFormatter.string(from: lunchDay.date)
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
}
