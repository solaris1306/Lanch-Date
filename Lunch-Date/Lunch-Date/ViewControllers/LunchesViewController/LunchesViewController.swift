//
//  LunchesViewController.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 19.3.21..
//

import UIKit
import Combine

enum LunchViewControllerErrors: Error {
    case numberOfRowsInSectionError
    case lunchTeamCellDequeuError
    case cellForRowAtError
}

extension LunchViewControllerErrors {
    var description: String {
        switch self {
        case .numberOfRowsInSectionError:
            return "Number of sections is out of indices fo lunch days array."
        case .lunchTeamCellDequeuError:
            return "LunchTeamCell couldn't be dequeued by UITableView."
        case .cellForRowAtError:
            return "Lunch days or lunch teams indices out of range."
        }
    }
}

class LunchesViewController: UIViewController {
    // MARK: - Static properties
    public static let employeesUrlString: String = "https://jsonplaceholder.typicode.com/users"
    // MARK: - Private properties
    private var lunchViewModel: LunchViewModel
    private var lunchModel: LunchModel
    let lunchView = LunchesView()
    private var subscriptions = Set<AnyCancellable>()
    private var lunchDays: LunchDays = LunchDays() {
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
    init(lunchModel: LunchModel, lunchViewModel: LunchViewModel) {
        self.lunchModel = lunchModel
        self.lunchViewModel = lunchViewModel
        super.init(nibName: nil, bundle: nil)
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
            handleErorr(error: LunchViewControllerErrors.numberOfRowsInSectionError)
            return 0
        }
        return lunchDays.lunchDays[section].lunchTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LunchTeamCell.self), for: indexPath) as? LunchTeamCell else {
            handleErorr(error: LunchViewControllerErrors.lunchTeamCellDequeuError)
            return UITableViewCell()
        }
        guard lunchDays.lunchDays.indices.contains(indexPath.section), lunchDays.lunchDays[indexPath.section].lunchTeams.indices.contains(indexPath.row) else {
            handleErorr(error: LunchViewControllerErrors.cellForRowAtError)
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
        guard !lunchViewModel.filterStrings.isEmpty else { return }
        
        let filterViewController = FilterViewController()
        filterViewController.selectedEmployeeName = lunchModel.filterString
        filterViewController.employeeNames = lunchViewModel.filterStrings
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
        lunchModel.employeesUrlString = LunchesViewController.employeesUrlString
    }
    
    @objc func currentScheduleDateAction() {
        lunchModel.startDate = Date()
        lunchView.scheduleDateLabel.text = "Starting date: \(LunchesViewController.dateFormatter.string(from: lunchModel.startDate))"
        lunchModel.currentButtonPublisher.send(())
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
        lunchView.scheduleDateCurrentButton.addTarget(self, action: #selector(currentScheduleDateAction), for: .touchUpInside)
        lunchView.scheduleDateSetButton.addTarget(self, action: #selector(setScheduleDateAction), for: .touchUpInside)
        lunchView.datePickerCancelButton.addTarget(self, action: #selector(datePickerCancelAction), for: .touchUpInside)
        lunchView.datePickerSetButton.addTarget(self, action: #selector(datePickerSetAction), for: .touchUpInside)
    }
}

// MARK: - Error handling
private extension LunchesViewController {
    func handleErorr(error: Error) {
        var message = "Message"
        var dismissClosure: (() -> ())? = nil
        if let lunchError = error as? LunchError {
            message = lunchError.description
            switch lunchError {
            case .filterStringIsNotFound:
                dismissClosure = {
                    self.lunchModel.filterString = nil
                }
            case .selectedOldURLNotFound:
                dismissClosure = {
                    self.lunchModel.selectedOldLunch = nil
                }
            default:
                break
            }
        } else if let lunchControllerError = error as? LunchViewControllerErrors {
            message = lunchControllerError.description
        } else {
            message = error.localizedDescription
        }
        
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            self?.present(alertController, animated: true, completion: dismissClosure)
        }
    }
}

// MARK: - Configure subscribers
private extension LunchesViewController {
    func setupSubscribers() {
        lunchViewModel.$shownLunchDays
            .sink { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case let .success(newLunchDays):
                    let goodDays = newLunchDays ?? LunchDays()
                    DispatchQueue.main.async {
                        self.lunchDays = goodDays
                    }
                case let .failure(error):
                    DispatchQueue.main.async {
                        self.lunchDays = LunchDays()
                    }
                    self.handleErorr(error: error)
                }
            }
            .store(in: &subscriptions)
        
        lunchViewModel.$filterStrings
            .map { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.filterButton.isEnabled, on: self)
            .store(in: &subscriptions)
        
        lunchModel.$filterString
            .sink { [weak self] (filterString) in
                guard let self = self else { return }
                guard let safeFilterString = filterString else {
                    self.lunchView.filterLabel.text = nil
                    self.lunchView.resetButtonHeightConstraint.constant = 0.0
                    return
                }
                self.lunchView.filterLabel.text = "Filtered employee: \(safeFilterString)"
                self.lunchView.resetButtonHeightConstraint.constant = 30.0
            }
            .store(in: &subscriptions)
        
        lunchViewModel.$oldLunches
            .map({ !$0.isEmpty })
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.loadButton.isEnabled, on: self)
            .store(in: &subscriptions)
        
        lunchModel.$selectedOldLunch
            .sink { [weak self] (url) in
                guard let self = self else { return }
                guard let safeURL = url else {
                    self.lunchView.newScheduleButton.isEnabled = true
                    self.lunchView.loadLabel.text = nil
                    self.lunchView.loadResetButtonHeightConstraint.constant = 0.0
                    self.lunchView.setScheduleDateButtonHeightConstraint.constant = 30.0
                    self.lunchView.resetScheduleDateButtonHeightConstraint.constant = 30.0
                    return
                }
                self.lunchView.newScheduleButton.isEnabled = true
                self.lunchView.loadLabel.text = "Loaded lunch: \(safeURL.lastPathComponent)"
                self.lunchView.setScheduleDateButtonHeightConstraint.constant = 0.0
                self.lunchView.resetScheduleDateButtonHeightConstraint.constant = 0.0
                self.lunchView.loadResetButtonHeightConstraint.constant = 30.0
            }
            .store(in: &subscriptions)
        
        lunchViewModel.$currentButtonEnabledPublisher
            .sink { [weak self] (enabled) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    guard self.lunchView.scheduleDateCurrentButton.isEnabled != enabled else { return }
                    self.lunchView.scheduleDateCurrentButton.isEnabled = enabled
                }
            }
            .store(in: &subscriptions)
        
        lunchViewModel.$oldLunchDays
            .sink { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    break
                case let .failure(error):
                    self.handleErorr(error: error)
                }
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Helper methods
private extension LunchesViewController {
    func setLunchFilterString(from filterViewController: FilterViewController) {
        guard let filterString = filterViewController.selectedEmployeeName else {
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
            
            let newLunchDays: Result<LunchDays?, Error> = lunchViewModel.generateLunchDays(for: lunchDays.employees, startDate: date)
            
            switch newLunchDays {
            case let .success(lunchDays):
                guard let safeLunchDays = lunchDays else {
                    self.handleErorr(error: LunchError.lunchDaysAreNil)
                    return
                }
                
                let fileName: String = "OldLunch_" + LunchesViewController.dateFormatter.string(from: safeLunchDays.startDate) + "-" + LunchesViewController.dateFormatter.string(from: safeLunchDays.endDate) + ".json"
                do {
                    let jsonData = try JSONEncoder().encode(safeLunchDays)
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                    let pathWithFileName: URL = documentsDirectory.appendingPathComponent(fileName)
                    do {
                        try jsonData.write(to: pathWithFileName)
                        print("File name: \(pathWithFileName)")
                    } catch let error {
                        self.handleErorr(error: error)
                    }
                } catch let error {
                    self.handleErorr(error: error)
                }
                
            case let .failure(error):
                self.handleErorr(error: error)
            }
        }
    }
}
