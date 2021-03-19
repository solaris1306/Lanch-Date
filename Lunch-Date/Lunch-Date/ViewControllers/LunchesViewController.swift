//
//  LunchesViewController.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 19.3.21..
//

import UIKit
import Combine

class LunchesViewController: UIViewController {
    // MARK: - Private properties
    private var lunch = Lunch()
    private var subscriptions = Set<AnyCancellable>()
    private let employeesUrlString: String = "https://jsonplaceholder.typicode.com/users"
    private static let grayColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
    private let noneFilter: String = "None"
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        return formatter
    }()
    
    private let tableView: ContentSizedTableView = {
        let tableView = ContentSizedTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitle("Filter", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(filterAction), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView.register(LunchTeamCell.self, forCellReuseIdentifier: String(describing: LunchTeamCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
        setupSubviews()
        lunch.employeesUrlString = employeesUrlString
        setupSubscribers()
    }
    
}

// MARK: - UITableViewDataSource
extension LunchesViewController: UITableViewDataSource {
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
extension LunchesViewController: UITableViewDelegate {
    
}

// MARK: - Presentati
extension LunchesViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard let filterViewController = presentationController.presentedViewController as? FilterViewController else { return }
        setLunchFilterString(from: filterViewController)
    }
}

// MARK: - Button actions
private extension LunchesViewController {
    @objc func filterAction() {
        guard !lunch.employees.isEmpty else { return }
        
        var empoyeeNames: [String] = [noneFilter]
        for empoyee in lunch.employees {
            empoyeeNames.append(empoyee.name)
        }
        
        let filterViewController = FilterViewController()
        filterViewController.selectedEmployeeName = lunch.filterString
        filterViewController.employeeNames = empoyeeNames
        filterViewController.presentationController?.delegate = self
        filterViewController.dismissClosure = { [weak self] in
            guard let self = self else { return }
            self.setLunchFilterString(from: filterViewController)
        }
        self.present(filterViewController, animated: true, completion: nil)
    }
}

// MARK: - Helper methods
private extension LunchesViewController {
    func setupSubviews() {
        view.addSubview(filterButton)
        view.addSubview(tableView)
        
        filterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        filterButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        tableView.topAnchor.constraint(equalTo: filterButton.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func setLunchFilterString(from filterViewController: FilterViewController) {
        guard filterViewController.selectedEmployeeName != self.noneFilter,
              let filterString = filterViewController.selectedEmployeeName else {
            self.lunch.filterString = nil
            return
        }
        self.lunch.filterString = filterString
    }
    
    func setupSubscribers() {
        lunch.$currentlyShownLunchInformations
            .sink(receiveValue: { _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.tableView.reloadData()
                }
            })
            .store(in: &subscriptions)
        
        lunch.$employees
            .map { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .assign(to: \.filterButton.isEnabled, on: self)
            .store(in: &subscriptions)
    }
}
