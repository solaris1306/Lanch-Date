//
//  LunchesViewController.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 19.3.21..
//

import UIKit
import Combine

enum LunchViewControllerErrors: Error {
    case numberOfRowsInSectionError(description: String)
    case lunchTeamCellDequeuError(description: String)
    case cellForRowAtError(description: String)
}

class LunchesViewController: UIViewController {
    // MARK: - Private properties
    private let lunchViewModel: LunchViewModel
    private let lunchModel: LunchModel
    let lunchView = LunchesView()
    private var subscriptions = Set<AnyCancellable>()
    private let employeesUrlString: String = "https://jsonplaceholder.typicode.com/users"
    private let noneFilter: String = "None"
    private var lunchDays: LunchDays = LunchDays.emptyDays {
        didSet {
            self.lunchView.tableView.reloadData()
        }
    }
    
    private static let grayColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
    static let buttonHeight: CGFloat = 40.0
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        return formatter
    }()
    
    // MARK: - Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.lunchModel = LunchModel(employeesUrlString: self.employeesUrlString,
                                     filterString: nil,
                                     selectedOldLunch: nil,
                                     startDate: Date(),
                                     oldLunchesURLs: Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil))
        self.lunchViewModel = LunchViewModel(lunchModel: self.lunchModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        setupSubscribers()
    }
    
}

// MARK: - UITableViewDataSource
extension LunchesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return lunchDays.lunchDays.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard lunchDays.lunchDays.indices.contains(section) else {
            handleErorr(error: LunchViewControllerErrors.numberOfRowsInSectionError(description: "Number of sections is out of indices fo lunch days array."))
            return 0
        }
        return lunchDays.lunchDays[section].lunchTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LunchTeamCell.self), for: indexPath) as? LunchTeamCell else {
            handleErorr(error: LunchViewControllerErrors.lunchTeamCellDequeuError(description: "LunchTeamCell couldn't be dequeued by UITableView."))
            return UITableViewCell()
        }
        guard lunchDays.lunchDays.indices.contains(indexPath.section), lunchDays.lunchDays[indexPath.section].lunchTeams.indices.contains(indexPath.row) else {
            handleErorr(error: LunchViewControllerErrors.cellForRowAtError(description: "Lunch days or lunch teams indices out of range."))
            return cell
        }
        let oneTeam: LunchTeam = lunchDays.lunchDays[indexPath.section].lunchTeams[indexPath.row]
        cell.teamLabel.text = oneTeam.firstEmployee + " - " + oneTeam.secondEmployee
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard lunchDays.lunchDays.indices.contains(section) else {
            return nil
        }
        let lunchDay: LunchDay = lunchDays.lunchDays[section]
        return  lunchDay.dayName + "  " + LunchesViewController.dateFormatter.string(from: lunchDay.date)
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
        guard !lunchDays.employees.isEmpty else { return }
        
        var empoyeeNames: [String] = [noneFilter]
        for empoyee in lunchDays.employees {
            empoyeeNames.append(empoyee.name)
        }
        
        let filterViewController = FilterViewController()
        filterViewController.selectedEmployeeName = lunchModel.filterString
        filterViewController.employeeNames = empoyeeNames
        filterViewController.presentationController?.delegate = self
        filterViewController.dismissClosure = { [weak self] in
            guard let self = self else { return }
            self.setLunchFilterString(from: filterViewController)
        }
        self.present(filterViewController, animated: true, completion: nil)
    }
    
    @objc func filterResetAction() {
        lunchModel.filterString = nil
    }
    
    @objc func loadResetAction() {
        lunchModel.selectedOldLunch = nil
    }
    
    @objc func loadOldLunchesAction() {
        guard !lunchViewModel.oldLunches.isEmpty else { return }
        
        let loadViewController = LoadViewController()
        loadViewController.selectedOldLunch = lunchModel.selectedOldLunch
        loadViewController.oldLunches = lunchViewModel.oldLunches
        loadViewController.presentationController?.delegate = self
        loadViewController.dismissClosure = { [weak self] in
            guard let self = self else { return }
            self.setOldLunchURL(from: loadViewController)
        }
        self.present(loadViewController, animated: true, completion: nil)
    }
    
    @objc func saveLunchAction() {
        let fileName: String = "OldLunch_" + LunchesViewController.dateFormatter.string(from: lunchDays.startDate) + "-" + LunchesViewController.dateFormatter.string(from: lunchDays.endDate) + ".json"
        do {
            let jsonData = try JSONEncoder().encode(lunchDays)
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
        lunchModel.employeesUrlString = employeesUrlString
    }
    
    @objc func resetScheduleDateAction() {
        lunchModel.startDate = Date()
        lunchView.scheduleDateLabel.text = "Starting date: \(LunchesViewController.dateFormatter.string(from: lunchModel.startDate))"
    }
    
    @objc func setScheduleDateAction() {
        lunchView.datePickerView.date = Date()
        setupViewsForDatePicker()
    }
    
    @objc func datePickerSetAction() {
        setupViewsForDatePicker()
        lunchModel.startDate = lunchView.datePickerView.date
        lunchView.scheduleDateLabel.text = "Starting date: \(LunchesViewController.dateFormatter.string(from: lunchModel.startDate))"
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

// MARK: - Error handling
private extension LunchesViewController {
    func handleErorr(error: Error) {
        print("\(error) has been handled.")
    }
}

// MARK: - Helper methods
private extension LunchesViewController {
    func setLunchFilterString(from filterViewController: FilterViewController) {
        guard filterViewController.selectedEmployeeName != self.noneFilter,
              let filterString = filterViewController.selectedEmployeeName else {
            self.lunchModel.filterString = nil
            return
        }
        self.lunchModel.filterString = filterString
    }
    
    func setOldLunchURL(from loadViewController: LoadViewController) {
        guard let safeOldFilterString = loadViewController.selectedOldLunch else {
            self.lunchModel.selectedOldLunch = nil
            return
        }
        self.lunchModel.selectedOldLunch = safeOldFilterString
    }
    
    func setupSubscribers() {
        lunchViewModel.$shownLunchDays
            .sink { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case let .success(newLunchDays):
                    let goodDays = newLunchDays ?? LunchDays.emptyDays
                    DispatchQueue.main.async {
                        self.lunchDays = goodDays
                    }
                case let .failure(error):
                    self.handleErorr(error: error)
                }
            }
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
            
            LunchesViewController.dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = LunchesViewController.dateFormatter.date(from: startDateString) ?? Date()
            LunchesViewController.dateFormatter.dateFormat = "dd-MM-yyyy"
            
            let newLunchDays: LunchDays = lunchViewModel.generateLunchDays(for: lunchDays.employees, startDate: date) ?? LunchDays.emptyDays
            
            let fileName: String = "OldLunch_" + LunchesViewController.dateFormatter.string(from: newLunchDays.startDate) + "-" + LunchesViewController.dateFormatter.string(from: newLunchDays.endDate) + ".json"
            do {
                let jsonData = try JSONEncoder().encode(newLunchDays)
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
