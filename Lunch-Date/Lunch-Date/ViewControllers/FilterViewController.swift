//
//  FilterViewController.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 19.3.21..
//

import UIKit

class FilterViewController: UIViewController {
    // MARK: - Properties
    var employeeNames: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var selectedEmployeeName: String? = nil
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
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderWidth = 5.0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return button
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard cell is FilterCell,
              employeeNames.indices.contains(indexPath.row),
              employeeNames[indexPath.row] == selectedEmployeeName
        else {
            return
        }
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
}

// MARK: - Button actions
private extension FilterViewController {
    @objc func closeAction() {
        dismiss(animated: true, completion: nil)
        guard let safeClosure = dismissClosure else { return }
        safeClosure()
    }
}

// MARK: - Helper methods
private extension FilterViewController {
    func setupSubviews() {
        view.addSubview(tableView)
        view.addSubview(closeButton)
        view.addSubview(fillerView)
        
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10.0).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        fillerView.topAnchor.constraint(equalTo: closeButton.bottomAnchor).isActive = true
        fillerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        fillerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        fillerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
