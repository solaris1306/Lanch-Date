//
//  LunchTeamCell.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 16.3.21..
//

import UIKit

class LunchTeamCell: UITableViewCell {
    // MARK: - Properties
    let firstEmployeeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        return label
    }()
    
    let secondEmployeeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        return label
    }()
    
    let centerSeparatorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.text = "-"
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    // MARK: - Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
}

// MARK: - Setup subviews
private extension LunchTeamCell {
    func setupSubviews() {
        addSubview(firstEmployeeNameLabel)
        addSubview(secondEmployeeNameLabel)
        addSubview(centerSeparatorLabel)
        addSubview(separatorView)
        setupSubviewsConstraints()
    }
    
    func setupSubviewsConstraints() {
        centerSeparatorLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        centerSeparatorLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        firstEmployeeNameLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 10.0).isActive = true
        firstEmployeeNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        firstEmployeeNameLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10.0).isActive = true
        firstEmployeeNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        firstEmployeeNameLabel.trailingAnchor.constraint(equalTo: centerSeparatorLabel.leadingAnchor).isActive = true
        
        secondEmployeeNameLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 10.0).isActive = true
        secondEmployeeNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        secondEmployeeNameLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10.0).isActive = true
        secondEmployeeNameLabel.leadingAnchor.constraint(equalTo: centerSeparatorLabel.trailingAnchor).isActive = true
        secondEmployeeNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        separatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
    }
}
