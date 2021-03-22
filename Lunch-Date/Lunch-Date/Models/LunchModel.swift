//
//  LunchModel.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 21.3.21..
//

import Foundation
import Combine

class LunchModel: ObservableObject {
    // MARK: - Published properties
    @Published var employeesUrlString: String
    @Published var filterString: String?
    @Published var selectedOldLunch: URL?
    @Published var startDate: Date
    @Published var oldLunchesURLs: [URL]? = nil
    var currentButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Initialization
    required init(employeesUrlString: String = "",
                  filterString: String? = nil,
                  selectedOldLunch: URL? = nil,
                  startDate: Date = Date(),
                  oldLunchesURLs: [URL]? = nil) {
        self.employeesUrlString = employeesUrlString
        self.filterString = filterString
        self.selectedOldLunch = selectedOldLunch
        self.startDate = startDate
        self.oldLunchesURLs = oldLunchesURLs
    }
}
