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
    private let noneFilter: String = "None"
    private var resetButtonHeightConstraint = NSLayoutConstraint()
    private var loadResetButtonHeightConstraint = NSLayoutConstraint()
    private var resetScheduleDateButtonHeightConstraint = NSLayoutConstraint()
    private var setScheduleDateButtonHeightConstraint = NSLayoutConstraint()
    
    private static let grayColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
    static let buttonHeight: CGFloat = 40.0
    
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
        button.layer.cornerRadius = LunchesViewController.buttonHeight / 2
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
        button.layer.cornerRadius = LunchesViewController.buttonHeight / 2
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
        tableView.setContentCompressionResistancePriority(UILayoutPriority(250), for: .vertical)
        return tableView
    }()
    
    private let fillerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.setContentCompressionResistancePriority(UILayoutPriority(260), for: .vertical)
        return view
    }()
    
    private let loadLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let loadResetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("RESET", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(loadResetAction), for: .touchUpInside)
        button.clipsToBounds = true
        button.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        return button
    }()
    
    private let loadStackView: UIStackView = {
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
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = LunchesViewController.buttonHeight / 2
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
        button.layer.cornerRadius = LunchesViewController.buttonHeight / 2
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
    
    private let scheduleDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let scheduleDateResetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("RESET", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(resetScheduleDateAction), for: .touchUpInside)
        button.clipsToBounds = true
        button.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        button.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        button.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        return button
    }()
    
    private let scheduleDateSetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("SET", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(setScheduleDateAction), for: .touchUpInside)
        button.clipsToBounds = true
        button.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        button.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        button.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        return button
    }()
    
    private let scheduleDateButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .white
        stackView.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        return stackView
    }()
    
    private let scheduleDateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.layoutMargins = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 30.0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let datePickerSetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("CANCEL", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(datePickerCancelAction), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    private let datePickerFillerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: 30.0).isActive = true
        return view
    }()
    
    private let datePickerCancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("SET", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(datePickerSetAction), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    private let datePickerButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let datePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.contentMode = .center
        picker.datePickerMode = .date
        picker.minimumDate = Date()
        return picker
    }()
    
    private let datePickerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.backgroundColor = .white
        stackView.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
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
        scheduleDateLabel.text = "Starting date: \(dateFormatter.string(from: lunch.startDate))"
    }
    
    @objc func setScheduleDateAction() {
        datePickerView.date = Date()
        setupViewsForDatePicker()
    }
    
    @objc func datePickerSetAction() {
        setupViewsForDatePicker()
        lunch.setStartDate(date: datePickerView.date)
        scheduleDateLabel.text = "Starting date: \(dateFormatter.string(from: lunch.startDate))"
    }
    
    @objc func datePickerCancelAction() {
        setupViewsForDatePicker()
    }
}

// MARK: - Setup subviews
private extension LunchesViewController {
    func setupSubviews() {
        setupFilterStackView()
        setupButtonStackView()
        setupLoadStackView()
        setupScheduleDateStackView()
        setupDatePickerStackView()
        setupScheduleStackView()
        
        view.addSubview(buttonStackView)
        view.addSubview(tableView)
        view.addSubview(filterStackView)
        view.addSubview(fillerView)
        view.addSubview(loadStackView)
        view.addSubview(scheduleDateStackView)
        view.addSubview(datePickerStackView)
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
        
        fillerView.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        fillerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        fillerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        fillerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0).isActive = true
        
        datePickerStackView.topAnchor.constraint(equalTo: fillerView.bottomAnchor).isActive = true
        datePickerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        datePickerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        datePickerStackView.bottomAnchor.constraint(equalTo: scheduleStackView.topAnchor).isActive = true
        
        loadStackView.topAnchor.constraint(equalTo: fillerView.bottomAnchor).isActive = true
        loadStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loadStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        scheduleDateStackView.topAnchor.constraint(equalTo: loadStackView.bottomAnchor).isActive = true
        scheduleDateStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scheduleDateStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        scheduleStackView.topAnchor.constraint(equalTo: scheduleDateStackView.bottomAnchor, constant: 10.0).isActive = true
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
        filterButton.heightAnchor.constraint(equalToConstant: LunchesViewController.buttonHeight).isActive = true
        loadButton.heightAnchor.constraint(equalToConstant: LunchesViewController.buttonHeight).isActive = true
        buttonStackView.addArrangedSubview(filterButton)
        buttonStackView.addArrangedSubview(loadButton)
    }
    
    func setupLoadStackView() {
        loadResetButtonHeightConstraint = loadResetButton.heightAnchor.constraint(equalToConstant: 0.0)
        loadResetButtonHeightConstraint.isActive = true
        
        loadStackView.addArrangedSubview(loadLabel)
        loadStackView.addArrangedSubview(loadResetButton)
    }
    
    func setupScheduleStackView() {
        newScheduleButton.heightAnchor.constraint(equalToConstant: LunchesViewController.buttonHeight).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: LunchesViewController.buttonHeight).isActive = true
        
        scheduleStackView.addArrangedSubview(newScheduleButton)
        scheduleStackView.addArrangedSubview(saveButton)
    }
    
    func setupScheduleDateStackView() {
        resetScheduleDateButtonHeightConstraint = scheduleDateResetButton.heightAnchor.constraint(equalToConstant: 0.0)
        setScheduleDateButtonHeightConstraint = scheduleDateSetButton.heightAnchor.constraint(equalToConstant: 0.0)
        resetScheduleDateButtonHeightConstraint.isActive = true
        setScheduleDateButtonHeightConstraint.isActive = true
        
        scheduleDateButtonStackView.addArrangedSubview(scheduleDateResetButton)
        scheduleDateButtonStackView.addArrangedSubview(scheduleDateSetButton)
        
        scheduleDateStackView.addArrangedSubview(scheduleDateLabel)
        scheduleDateStackView.addArrangedSubview(scheduleDateButtonStackView)
    }
    
    func setupDatePickerStackView() {
        datePickerButtonStackView.addArrangedSubview(datePickerCancelButton)
        datePickerButtonStackView.addArrangedSubview(datePickerFillerView)
        datePickerButtonStackView.addArrangedSubview(datePickerSetButton)
        
        datePickerStackView.addArrangedSubview(datePickerButtonStackView)
        datePickerStackView.addArrangedSubview(datePickerView)
        
        datePickerStackView.isHidden = true
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
                return 30.0
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.resetButtonHeightConstraint.constant, on: self)
            .store(in: &subscriptions)
        
        lunch.$oldLunches
            .map({ !$0.isEmpty })
            .receive(on: DispatchQueue.main)
            .assign(to: \.loadButton.isEnabled, on: self)
            .store(in: &subscriptions)
        
        lunch.$selectedOldLunch
            .map { $0 == nil }
            .receive(on: DispatchQueue.main)
            .assign(to: \.newScheduleButton.isEnabled, on: self)
            .store(in: &subscriptions)
        
        lunch.$selectedOldLunch
            .map { (oldUrl) -> CGFloat in
                guard oldUrl != nil else { return 0.0 }
                return 30.0
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.loadResetButtonHeightConstraint.constant, on: self)
            .store(in: &subscriptions)
        
        lunch.$selectedOldLunch
            .map { (oldUrl) -> String? in
                guard let safeUrl = oldUrl else { return nil }
                return "Loaded lunch: \(safeUrl.lastPathComponent)"
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.loadLabel.text, on: self)
            .store(in: &subscriptions)
        
        lunch.$selectedOldLunch
            .map { [weak self] (oldUrl) -> String? in
                guard let self = self, oldUrl == nil else { return nil }
                return "Starting date: \(self.dateFormatter.string(from: self.lunch.startDate))"
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.scheduleDateLabel.text, on: self)
            .store(in: &subscriptions)

        lunch.$selectedOldLunch
            .map { (oldUrl) -> CGFloat in
                guard oldUrl == nil else { return 0.0 }
                return 30.0
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.setScheduleDateButtonHeightConstraint.constant, on: self)
            .store(in: &subscriptions)

        lunch.$selectedOldLunch
            .map { (oldUrl) -> CGFloat in
                guard oldUrl == nil else { return 0.0 }
                return 30.0
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.resetScheduleDateButtonHeightConstraint.constant, on: self)
            .store(in: &subscriptions)
    }
    
    func setupViewsForDatePicker() {
        newScheduleButton.isEnabled = !newScheduleButton.isEnabled
        loadButton.isEnabled = !loadButton.isEnabled
        datePickerStackView.isHidden = !datePickerStackView.isHidden
        loadStackView.isHidden = !loadStackView.isHidden
        scheduleDateStackView.isHidden = !scheduleDateStackView.isHidden
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
