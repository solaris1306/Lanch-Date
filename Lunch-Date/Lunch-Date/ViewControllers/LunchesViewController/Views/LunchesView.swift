//
//  LunchesView.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 21.3.21..
//

import UIKit

class LunchesView: UIView {
    // MARK: - Public properties
    var resetButtonHeightConstraint = NSLayoutConstraint()
    var loadResetButtonHeightConstraint = NSLayoutConstraint()
    var resetScheduleDateButtonHeightConstraint = NSLayoutConstraint()
    var setScheduleDateButtonHeightConstraint = NSLayoutConstraint()
    
    // MARK: - Subviews
    let filterButton: UIButton = {
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
        return button
    }()
    
    let loadButton: UIButton = {
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
        return button
    }()
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let filterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("RESET", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.clipsToBounds = true
        button.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        return button
    }()
    
    let filterStackView: UIStackView = {
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
    
    let tableView: ContentSizedTableView = {
        let tableView = ContentSizedTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.setContentCompressionResistancePriority(UILayoutPriority(250), for: .vertical)
        return tableView
    }()
    
    let fillerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.setContentCompressionResistancePriority(UILayoutPriority(260), for: .vertical)
        return view
    }()
    
    let loadLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let loadResetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("RESET", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.clipsToBounds = true
        button.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        return button
    }()
    
    let loadStackView: UIStackView = {
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
    
    let saveButton: UIButton = {
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
        return button
    }()
    
    let newScheduleButton: UIButton = {
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
        return button
    }()
    
    let scheduleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let scheduleDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let scheduleDateResetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("RESET", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.clipsToBounds = true
        button.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        button.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        button.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        return button
    }()
    
    let scheduleDateSetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("SET", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.clipsToBounds = true
        button.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        button.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        button.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        return button
    }()
    
    let scheduleDateButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .white
        stackView.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        return stackView
    }()
    
    let scheduleDateStackView: UIStackView = {
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
    
    let datePickerSetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("SET", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.clipsToBounds = true
        return button
    }()
    
    let datePickerFillerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: 30.0).isActive = true
        return view
    }()
    
    let datePickerCancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("CANCEL", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.clipsToBounds = true
        return button
    }()
    
    let datePickerButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let datePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.contentMode = .center
        picker.datePickerMode = .date
        picker.minimumDate = Date()
        return picker
    }()
    
    let datePickerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.backgroundColor = .white
        stackView.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        return stackView
    }()
    
    let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.97)
        return view
    }()
    
    let loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "LOADING..."
        label.font = .boldSystemFont(ofSize: 20.0)
        label.contentMode = .center
        return label
    }()
    
    let activityView = UIActivityIndicatorView(style: .large)
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
}

// MARK: - Setup subviews
private extension LunchesView {
    func setupSubviews() {
        setupFilterStackView()
        setupButtonStackView()
        setupLoadStackView()
        setupScheduleDateStackView()
        setupDatePickerStackView()
        setupScheduleStackView()
        
        addSubview(buttonStackView)
        addSubview(tableView)
        addSubview(filterStackView)
        addSubview(fillerView)
        addSubview(loadStackView)
        addSubview(scheduleDateStackView)
        addSubview(datePickerStackView)
        addSubview(scheduleStackView)
        
        buttonStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        filterStackView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor).isActive = true
        filterStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        filterStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        tableView.topAnchor.constraint(equalTo: filterStackView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        fillerView.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        fillerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        fillerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        fillerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0).isActive = true
        
        datePickerStackView.topAnchor.constraint(equalTo: fillerView.bottomAnchor).isActive = true
        datePickerStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        datePickerStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        datePickerStackView.bottomAnchor.constraint(equalTo: scheduleStackView.topAnchor).isActive = true
        
        loadStackView.topAnchor.constraint(equalTo: fillerView.bottomAnchor).isActive = true
        loadStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        loadStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        scheduleDateStackView.topAnchor.constraint(equalTo: loadStackView.bottomAnchor).isActive = true
        scheduleDateStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scheduleDateStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        scheduleStackView.topAnchor.constraint(equalTo: scheduleDateStackView.bottomAnchor, constant: 10.0).isActive = true
        scheduleStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scheduleStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        scheduleStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        backgroundView.addSubview(loadingLabel)
        loadingLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        loadingLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -50.0).isActive = true
        
        addSubview(backgroundView)
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundView.isHidden = true
        
        activityView.center = center
        addSubview(activityView)
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
