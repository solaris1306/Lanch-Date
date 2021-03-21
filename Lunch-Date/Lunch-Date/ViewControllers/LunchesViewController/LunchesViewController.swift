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
    let lunchView = LunchesView()
    private var subscriptions = Set<AnyCancellable>()
    private let employeesUrlString: String = "https://jsonplaceholder.typicode.com/users"
    private let noneFilter: String = "None"
    
    private static let grayColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
    static let buttonHeight: CGFloat = 40.0
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        lunchView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lunchView)
        lunchView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        lunchView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        lunchView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lunchView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        setupButtonActions()
        
        lunchView.tableView.register(LunchTeamCell.self, forCellReuseIdentifier: String(describing: LunchTeamCell.self))
        lunchView.tableView.dataSource = self
        lunchView.tableView.delegate = self
        
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

// MARK: - UIAdaptivePresentationControllerDelegate
extension LunchesViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let filterViewController = presentationController.presentedViewController as? FilterViewController {
            setLunchFilterString(from: filterViewController)
        }
        if let loadViewControler = presentationController.presentedViewController as? LoadViewController {
            setOldLunchURL(from: loadViewControler)
        }
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
    
    @objc func loadResetAction() {
        lunch.selectedOldLunch = nil
    }
    
    @objc func loadOldLunchesAction() {
        guard !lunch.oldLunches.isEmpty else { return }
        
        let loadViewController = LoadViewController()
        loadViewController.selectedOldLunch = lunch.selectedOldLunch
        loadViewController.oldLunches = lunch.oldLunches
        loadViewController.presentationController?.delegate = self
        loadViewController.dismissClosure = { [weak self] in
            guard let self = self else { return }
            self.setOldLunchURL(from: loadViewController)
        }
        self.present(loadViewController, animated: true, completion: nil)
    }
    
    @objc func saveLunchAction() {
        let fileName: String = "OldLunch_" + self.dateFormatter.string(from: self.lunch.startDate) + "-" + self.dateFormatter.string(from: self.lunch.endDate) + ".json"
        do {
            let jsonData = try JSONEncoder().encode(lunch)
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let pathWithFileName: URL = documentsDirectory.appendingPathComponent(fileName)
            do {
                try jsonData.write(to: pathWithFileName)
                print("File name: \(pathWithFileName)")
            } catch {
                print("JSON data couldn't be written to file.")
            }
        } catch {
            print("Data couldn't be encoded.")
        }
    }
    
    @objc func getNewLunchSchedule() {
        lunch.employeesUrlString = employeesUrlString
    }
    
    @objc func resetScheduleDateAction() {
        lunch.setStartDate(date: Date())
        lunchView.scheduleDateLabel.text = "Starting date: \(dateFormatter.string(from: lunch.startDate))"
    }
    
    @objc func setScheduleDateAction() {
        lunchView.datePickerView.date = Date()
        setupViewsForDatePicker()
    }
    
    @objc func datePickerSetAction() {
        setupViewsForDatePicker()
        lunch.setStartDate(date: lunchView.datePickerView.date)
        lunchView.scheduleDateLabel.text = "Starting date: \(dateFormatter.string(from: lunch.startDate))"
    }
    
    @objc func datePickerCancelAction() {
        setupViewsForDatePicker()
    }
    
    func setupButtonActions() {
        lunchView.filterButton.addTarget(self, action: #selector(filterAction), for: .touchUpInside)
        lunchView.loadButton.addTarget(self, action: #selector(loadOldLunchesAction), for: .touchUpInside)
        lunchView.resetButton.addTarget(self, action: #selector(filterResetAction), for: .touchUpInside)
        lunchView.loadResetButton.addTarget(self, action: #selector(loadResetAction), for: .touchUpInside)
        lunchView.saveButton.addTarget(self, action: #selector(saveLunchAction), for: .touchUpInside)
        lunchView.newScheduleButton.addTarget(self, action: #selector(getNewLunchSchedule), for: .touchUpInside)
        lunchView.scheduleDateResetButton.addTarget(self, action: #selector(resetScheduleDateAction), for: .touchUpInside)
        lunchView.scheduleDateSetButton.addTarget(self, action: #selector(setScheduleDateAction), for: .touchUpInside)
        lunchView.datePickerCancelButton.addTarget(self, action: #selector(datePickerCancelAction), for: .touchUpInside)
        lunchView.datePickerSetButton.addTarget(self, action: #selector(datePickerSetAction), for: .touchUpInside)
    }
}

// MARK: - Helper methods
private extension LunchesViewController {
    func setLunchFilterString(from filterViewController: FilterViewController) {
        guard filterViewController.selectedEmployeeName != self.noneFilter,
              let filterString = filterViewController.selectedEmployeeName else {
            self.lunch.filterString = nil
            return
        }
        self.lunch.filterString = filterString
    }
    
    func setOldLunchURL(from loadViewController: LoadViewController) {
        guard let safeOldFilterString = loadViewController.selectedOldLunch else {
            self.lunch.selectedOldLunch = nil
            return
        }
        self.lunch.selectedOldLunch = safeOldFilterString
    }
    
    func setupSubscribers() {
        lunch.$currentlyShownLunchInformations
            .sink(receiveValue: { _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.lunchView.tableView.reloadData()
                }
            })
            .store(in: &subscriptions)
        
        lunch.$employees
            .map { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.filterButton.isEnabled, on: self)
            .store(in: &subscriptions)
        
        lunch.$filterString
            .map { (filterString) -> String? in
                guard let safeString = filterString else { return nil }
                return "Filtered employee: \(safeString)"
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.filterLabel.text, on: self)
            .store(in: &subscriptions)
        
        lunch.$filterString
            .map { (filterString) -> CGFloat in
                guard filterString != nil else { return 0.0 }
                return 30.0
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.resetButtonHeightConstraint.constant, on: self)
            .store(in: &subscriptions)
        
        lunch.$oldLunches
            .map({ !$0.isEmpty })
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.loadButton.isEnabled, on: self)
            .store(in: &subscriptions)
        
        lunch.$selectedOldLunch
            .map { $0 == nil }
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.newScheduleButton.isEnabled, on: self)
            .store(in: &subscriptions)
        
        lunch.$selectedOldLunch
            .map { (oldUrl) -> CGFloat in
                guard oldUrl != nil else { return 0.0 }
                return 30.0
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.loadResetButtonHeightConstraint.constant, on: self)
            .store(in: &subscriptions)
        
        lunch.$selectedOldLunch
            .map { (oldUrl) -> String? in
                guard let safeUrl = oldUrl else { return nil }
                return "Loaded lunch: \(safeUrl.lastPathComponent)"
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.loadLabel.text, on: self)
            .store(in: &subscriptions)
        
        lunch.$selectedOldLunch
            .map { [weak self] (oldUrl) -> String? in
                guard let self = self, oldUrl == nil else { return nil }
                return "Starting date: \(self.dateFormatter.string(from: self.lunch.startDate))"
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.scheduleDateLabel.text, on: self)
            .store(in: &subscriptions)

        lunch.$selectedOldLunch
            .map { (oldUrl) -> CGFloat in
                guard oldUrl == nil else { return 0.0 }
                return 30.0
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.setScheduleDateButtonHeightConstraint.constant, on: self)
            .store(in: &subscriptions)

        lunch.$selectedOldLunch
            .map { (oldUrl) -> CGFloat in
                guard oldUrl == nil else { return 0.0 }
                return 30.0
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.resetScheduleDateButtonHeightConstraint.constant, on: self)
            .store(in: &subscriptions)
    }
    
    func setupViewsForDatePicker() {
        lunchView.newScheduleButton.isEnabled = !lunchView.newScheduleButton.isEnabled
        lunchView.loadButton.isEnabled = !lunchView.loadButton.isEnabled
        lunchView.datePickerStackView.isHidden = !lunchView.datePickerStackView.isHidden
        lunchView.loadStackView.isHidden = !lunchView.loadStackView.isHidden
        lunchView.scheduleDateStackView.isHidden = !lunchView.scheduleDateStackView.isHidden
    }
    
    func generateOldLunches() {
        for i in 1...12 {
            var monthString = ""
            if i < 10 {
                monthString = "0" + "\(i)-"
            } else {
                monthString = "\(i)-"
            }
            let startDateString = "2020-" + monthString + "01"
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: startDateString) ?? Date()
            lunch.setStartDate(date: date)
            dateFormatter.dateFormat = "dd-MM-yyyy"
            
            let newLunch: [Lunch.LunchDay] = lunch.generateLunchTeams(for: lunch.employees)
            lunch.changeLunches(with: newLunch)
            
            let fileName: String = "OldLunch_" + self.dateFormatter.string(from: self.lunch.startDate) + "-" + self.dateFormatter.string(from: self.lunch.endDate) + ".json"
            do {
                let jsonData = try JSONEncoder().encode(lunch)
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let pathWithFileName: URL = documentsDirectory.appendingPathComponent(fileName)
                do {
                    try jsonData.write(to: pathWithFileName)
                    print("File name: \(pathWithFileName)")
                } catch {
                    print("JSON data couldn't be written to file.")
                }
            } catch {
                print("Data couldn't be encoded.")
            }
        }
    }
}
