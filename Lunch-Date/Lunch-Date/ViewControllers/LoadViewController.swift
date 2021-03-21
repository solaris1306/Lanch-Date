//
//  LoadViewController.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 20.3.21..
//

import UIKit

class LoadViewController: UIViewController {
    // MARK: - Properties
    var oldLunches: [URL] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var selectedOldLunch: URL? = nil
    var dismissClosure: (() -> ())? = nil
    
    // MARK: - Private properties
    private let tableView: ContentSizedTableView = {
        let tableView = ContentSizedTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = LunchesViewController.buttonHeight / 2
        button.setTitle("CANCEL", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(loadOldLuncheAction), for: .touchUpInside)
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
    
    private let fillerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView.register(FilterCell.self, forCellReuseIdentifier: String(describing: FilterCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
        setupSubviews()
    }
}

// MARK: - UITableViewDataSource
extension LoadViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oldLunches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FilterCell.self), for: indexPath) as? FilterCell else {
            return UITableViewCell()
        }
        cell.filterLabel.text = oldLunches[indexPath.row].lastPathComponent
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select old lunch to load:"
    }
}

// MARK: - UITableViewDelegate
extension LoadViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard oldLunches.indices.contains(indexPath.row) else {
            selectedOldLunch = nil
            return
        }
        selectedOldLunch = oldLunches[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard cell is FilterCell,
              oldLunches.indices.contains(indexPath.row),
              oldLunches[indexPath.row] == selectedOldLunch
        else {
            return
        }
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
}

// MARK: - Button actions
private extension LoadViewController {
    @objc func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func loadOldLuncheAction() {
        dismiss(animated: true, completion: nil)
        guard let safeClosure = dismissClosure else { return }
        safeClosure()
    }
}

// MARK: - Helper methods
private extension LoadViewController {
    func setupSubviews() {
        setupStackView()
        
        view.addSubview(tableView)
        view.addSubview(buttonStackView)
        view.addSubview(fillerView)
        
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        buttonStackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10.0).isActive = true
        buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        fillerView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor).isActive = true
        fillerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        fillerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        fillerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setupStackView() {
        cancelButton.heightAnchor.constraint(equalToConstant: LunchesViewController.buttonHeight).isActive = true
        loadButton.heightAnchor.constraint(equalToConstant: LunchesViewController.buttonHeight).isActive = true
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(loadButton)
    }
}
