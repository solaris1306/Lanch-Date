//
//  FilterCell.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 19.3.21..
//

import UIKit

class FilterCell: UITableViewCell {
    // MARK: - Properties
    let filterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.textAlignment = .center
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
private extension FilterCell {
    func setupSubviews() {
        addSubview(filterLabel)
        addSubview(separatorView)
        setupSubviewsConstraints()
    }
    
    func setupSubviewsConstraints() {
        filterLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10.0).isActive = true
        filterLabel.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -10.0).isActive = true
        filterLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        filterLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        separatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
    }
}

