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
    private var resetButtonHeightConstraint = NSLayoutConstraint()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        return formatter
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.setTitle("FILTER", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(filterAction), for: .touchUpInside)
        return button
    }()
    
    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.setTitle("LOAD", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(loadOldLunchesAction), for: .touchUpInside)
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let filterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("RESET", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(filterResetAction), for: .touchUpInside)
        button.clipsToBounds = true
        button.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        return button
    }()
    
    private let filterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10.0
        stackView.layoutMargins = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 30.0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let tableView: ContentSizedTableView = {
        let tableView = ContentSizedTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.setTitle("SAVE", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(saveLunchAction), for: .touchUpInside)
        return button
    }()
    
    private let newScheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.setTitle("NEW SCHEDULE", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(getNewLunchSchedule), for: .touchUpInside)
        return button
    }()
    
    private let scheduleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        stackView.distribution = .fillEqually
        return stackView
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
    
    @objc func filterResetAction() {
        lunch.filterString = nil
    }
    
    @objc func loadOldLunchesAction() {
        print("Load old lunches")
    }
    
    @objc func saveLunchAction() {
        
    }
    
    @objc func getNewLunchSchedule() {
        
    }
}

// MARK: - Helper methods
private extension LunchesViewController {
    func setupSubviews() {
        setupFilterStackView()
        setupButtonStackView()
        setupScheduleStackView()
        
        view.addSubview(buttonStackView)
        view.addSubview(tableView)
        view.addSubview(filterStackView)
        view.addSubview(scheduleStackView)
        
        buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        filterStackView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor).isActive = true
        filterStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        filterStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.topAnchor.constraint(equalTo: filterStackView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        scheduleStackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20.0).isActive = true
        scheduleStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scheduleStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scheduleStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func setupFilterStackView() {
        resetButtonHeightConstraint = resetButton.heightAnchor.constraint(equalToConstant: 0.0)
        resetButtonHeightConstraint.isActive = true
        
        filterStackView.addArrangedSubview(filterLabel)
        filterStackView.addArrangedSubview(resetButton)
    }
    
    func setupButtonStackView() {
        filterButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        loadButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        buttonStackView.addArrangedSubview(filterButton)
        buttonStackView.addArrangedSubview(loadButton)
    }
    
    func setupScheduleStackView() {
        newScheduleButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        scheduleStackView.addArrangedSubview(newScheduleButton)
        scheduleStackView.addArrangedSubview(saveButton)
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
        
        lunch.$filterString
            .map { (filterString) -> String? in
                guard let safeString = filterString else { return nil }
                return "Filtered employee: \(safeString)"
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.filterLabel.text, on: self)
            .store(in: &subscriptions)
        
        lunch.$filterString
            .map { (filterString) -> CGFloat in
                guard filterString != nil else { return 0.0 }
                return 40.0
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.resetButtonHeightConstraint.constant, on: self)
            .store(in: &subscriptions)
    }
}
