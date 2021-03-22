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
            lunchView.saveButton.isEnabled = !lunchDays.lunchDays.isEmpty
            lunchView.tableView.reloadData()
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
            handleError(error: LunchViewControllerErrors.numberOfRowsInSectionError)
            return 0
        }
        return lunchDays.lunchDays[section].lunchTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LunchTeamCell.self), for: indexPath) as? LunchTeamCell else {
            handleError(error: LunchViewControllerErrors.lunchTeamCellDequeuError)
            return UITableViewCell()
        }
        guard lunchDays.lunchDays.indices.contains(indexPath.section), lunchDays.lunchDays[indexPath.section].lunchTeams.indices.contains(indexPath.row) else {
            handleError(error: LunchViewControllerErrors.cellForRowAtError)
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
        filterIsDisabled()
    }
    
    @objc func loadResetAction() {
        lunchModel.selectedOldLunch = nil
        currentScheduleDateAction()
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
        saveShownLunchDays()
    }
    
    @objc func getNewLunchSchedule() {
        lunchModel.employeesUrlString = LunchesViewController.employeesUrlString
    }
    
    @objc func currentScheduleDateAction() {
        lunchModel.startDate = Date()
        lunchModel.currentButtonPublisher.send(())
    }
    
    @objc func setScheduleDateAction() {
        lunchView.datePickerView.date = Date()
        setupViewsForDatePicker()
    }
    
    @objc func datePickerSetAction() {
        setupViewsForDatePicker()
        lunchModel.startDate = lunchView.datePickerView.date
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
    func handleError(error: Error) {
        var message = "Error message"
        if let lunchError = error as? LunchError {
            message = lunchError.description
        } else if let lunchControllerError = error as? LunchViewControllerErrors {
            message = lunchControllerError.description
        } else {
            message = error.localizedDescription
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
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
                    if newLunchDays == nil && self.lunchModel.filterString != nil {
                        self.filterIsDisabled()
                    }
                    let goodDays = newLunchDays ?? LunchDays()
                    DispatchQueue.main.async {
                        if let safeFilterString = self.lunchModel.filterString {
                            self.filterIsEnabled(filterString: safeFilterString)
                        }
                        self.lunchDays = goodDays
                    }
                case let .failure(error):
                    if self.lunchModel.filterString != nil {
                        self.filterIsDisabled()
                    }
                    DispatchQueue.main.async {
                        self.lunchDays = LunchDays()
                    }
                    self.handleError(error: error)
                }
            }
            .store(in: &subscriptions)
        
        lunchViewModel.$filterStrings
            .map({ !$0.isEmpty })
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.filterButton.isEnabled, on: self)
            .store(in: &subscriptions)
        
        lunchViewModel.$oldLunches
            .map({ !$0.isEmpty })
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.loadButton.isEnabled, on: self)
            .store(in: &subscriptions)
        
        lunchViewModel.$currentButtonEnabledPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.scheduleDateCurrentButton.isEnabled, on: self)
            .store(in: &subscriptions)
        
        lunchViewModel.$oldLunchDays
            .sink { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    break
                case let .failure(error):
                    self.oldUrlIsDeselected()
                    self.handleError(error: error)
                }
            }
            .store(in: &subscriptions)
        
        lunchViewModel.$oldLunchDaysURL
            .sink { [weak self] (url) in
                guard let self = self else { return }
                guard let safeUrl = url else {
                    self.oldUrlIsDeselected()
                    return
                }
                self.oldUrlIsSelected(url: safeUrl)
            }
            .store(in: &subscriptions)
        
        lunchViewModel.$newScheduleEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.newScheduleButton.isEnabled, on: self)
            .store(in: &subscriptions)
        
        lunchViewModel.$newScheduleEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.scheduleDateSetButton.isEnabled, on: self)
            .store(in: &subscriptions)
        
        lunchViewModel.$scheduleDateLabelText
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchView.scheduleDateLabel.text, on: self)
            .store(in: &subscriptions)
    }
}

// MARK: - Helper methods
private extension LunchesViewController {
    func setLunchFilterString(from filterViewController: FilterViewController) {
        guard let filterString = filterViewController.selectedEmployeeName else {
            lunchModel.filterString = nil
            return
        }
        lunchModel.filterString = filterString
    }
    
    func setOldLunchURL(from loadViewController: LoadViewController) {
        guard let safeOldFilterString = loadViewController.selectedOldLunch else {
            lunchModel.selectedOldLunch = nil
            return
        }
        lunchModel.selectedOldLunch = safeOldFilterString
    }
    
    func setupViewsForDatePicker() {
        lunchView.newScheduleButton.isEnabled = !lunchView.newScheduleButton.isEnabled
        lunchView.loadButton.isEnabled = !lunchView.loadButton.isEnabled
        lunchView.datePickerStackView.isHidden = !lunchView.datePickerStackView.isHidden
        lunchView.loadStackView.isHidden = !lunchView.loadStackView.isHidden
        lunchView.scheduleDateStackView.isHidden = !lunchView.scheduleDateStackView.isHidden
    }
    
    func oldUrlIsSelected(url: URL?) {
        if let safeURL = url {
            lunchView.loadLabel.text = safeURL.lastPathComponent
        }
        lunchView.setScheduleDateButtonHeightConstraint.constant = 0.0
        lunchView.resetScheduleDateButtonHeightConstraint.constant = 0.0
        lunchView.loadResetButtonHeightConstraint.constant = 30.0
    }
    
    func oldUrlIsDeselected() {
        lunchView.loadLabel.text = nil
        lunchView.loadResetButtonHeightConstraint.constant = 0.0
        lunchView.setScheduleDateButtonHeightConstraint.constant = 30.0
        lunchView.resetScheduleDateButtonHeightConstraint.constant = 30.0
    }
    
    func filterIsEnabled(filterString: String) {
        lunchView.filterLabel.text = "Filtered employee: \(filterString)"
        lunchView.resetButtonHeightConstraint.constant = 30.0
    }
    
    func filterIsDisabled() {
        lunchModel.filterString = nil
        lunchView.filterLabel.text = nil
        lunchView.resetButtonHeightConstraint.constant = 0.0
    }
    
    func saveShownLunchDays() {
        let fileName: String = "OldLunch_" + LunchesViewController.dateFormatter.string(from: lunchDays.startDate) + "-" + LunchesViewController.dateFormatter.string(from: lunchDays.endDate) + ".json"
        do {
            let jsonData = try JSONEncoder().encode(lunchDays)
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let pathWithFileName: URL = documentsDirectory.appendingPathComponent(fileName)
            do {
                try jsonData.write(to: pathWithFileName)
                print("File name: \(pathWithFileName)")
            } catch let error {
                self.handleError(error: error)
            }
        } catch {
            self.handleError(error: error)
        }
    }
    
    func generateOldLunches() {
        for i in 1...12 {
            var monthString = ""
            if i < 10 {
                monthString = "0" + "\(i)-"
            } else {
                monthString = "\(i)-"
            }
            let startDateString = "2019-" + monthString + "01"
            
            LunchesViewController.dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = LunchesViewController.dateFormatter.date(from: startDateString) ?? Date()
            LunchesViewController.dateFormatter.dateFormat = "dd-MM-yyyy"
            
            let newLunchDays: Result<LunchDays?, Error> = lunchViewModel.generateLunchDays(for: lunchDays.employees, startDate: date)
            
            switch newLunchDays {
            case let .success(lunchDays):
                guard let safeLunchDays = lunchDays else {
                    self.handleError(error: LunchError.lunchDaysAreNil)
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
                        self.handleError(error: error)
                    }
                } catch let error {
                    self.handleError(error: error)
                }
                
            case let .failure(error):
                self.handleError(error: error)
            }
        }
    }
}
