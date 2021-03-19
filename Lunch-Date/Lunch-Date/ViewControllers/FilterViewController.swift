//
//  FilterViewController.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 19.3.21..
//

import UIKit

class FilterViewController: UIViewController {
    // MARK: - Properties
    var employeeNames: [String] = []
    var selectedEmployeeName: String? = nil
    
    // MARK: - Private properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FilterCell.self, forCellReuseIdentifier: String(describing: FilterCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
}

// MARK: - UITableViewDataSource
extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeeNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FilterCell.self), for: indexPath) as? FilterCell else {
            return UITableViewCell()
        }
        cell.filterLabel.text = employeeNames[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select employee for filtering:"
    }
}

// MARK: - UITableViewDelegate
extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard employeeNames.indices.contains(indexPath.row) else {
            selectedEmployeeName = nil
            return
        }
        selectedEmployeeName = employeeNames[indexPath.row]
    }
}
