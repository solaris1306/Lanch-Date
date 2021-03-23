//
//  LunchViewModel.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 21.3.21..
//

import Foundation
import Combine

enum LunchError: Error {
    case badURL
    case lunchDaysAreNil
    case lunchDaysCouldntBeRetreived
    case filterStringIsNotFound
    case oddNumberOfEmployees
    case notEnoughEmployees
    case selectedOldURLNotFound
}

extension LunchError {
    var description: String {
        switch self {
        case .badURL:
            return "Bad URL. Please check given URL and/or connectivity."
        case .lunchDaysAreNil:
            return "Fetched lunch days didn't retreived any values (return nil)"
        case .lunchDaysCouldntBeRetreived:
            return "Lunch days cound't be retreived at this moment. Please check your connectivity and given data."
        case .filterStringIsNotFound:
            return "Filtering for selected employee is not possible for given lunch days."
        case .oddNumberOfEmployees:
            return "There is odd number of employees."
        case .notEnoughEmployees:
            return "Not enough employees (<2) for calculation."
        case .selectedOldURLNotFound:
            return "File for selected URL is not found."
        }
    }
}

class LunchViewModel: ObservableObject {
    // MARK: - Public properties
    let lunchModel: LunchModel
    
    // MARK: - Published public properties
    @Published private (set) var shownLunchDays: Result<LunchDays?, Error> = .success(nil)
    @Published private (set) var oldLunchDays: Result<LunchDays?, Error> = .success(nil)
    @Published private (set) var oldLunches: [URL] = []
    @Published private (set) var oldLunchDaysURL: URL? = nil
    private (set) var previousOldURL: URL? = nil
    @Published private (set) var filterStrings: [String] = []
    @Published private (set) var scheduleDateLabelText: String? = nil
    @Published private (set) var newScheduleEnabled: Bool = true
    @Published private (set) var currentButtonEnabled: Bool = false
    @Published private (set) var loadResetButtonEnabled: Bool = false
    
    // MARK: - Private properties
    @Published private var filteredLunchDays: Result<LunchDays?, Error> = .success(nil) {
        willSet {
            var newFilters: [String] = []
            switch newValue {
            case let .success(lunchDays):
                if let safeLunchDays = lunchDays, !safeLunchDays.lunchDays.isEmpty , !safeLunchDays.employees.isEmpty {
                    newFilters.append(noneFilter)
                    for employee in safeLunchDays.employees {
                        newFilters.append(employee.name)
                    }
                }
            default:
                break
            }
            filterStrings = newFilters
        }
    }
    private var currentLunchDays: Result<LunchDays?, Error> = .success(nil)
    private var lastFetchedLunchDays: Result<LunchDays?, Error> = .success(nil)
    
    private var subscriptions = Set<AnyCancellable>()
    private let noneFilter: String = "None"
    private let dayNameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    // MARK: - Initialization
    required init(lunchModel: LunchModel = LunchModel()) {
        self.lunchModel = lunchModel
        setupSubscribers()
    }
}

// MARK: - Subscribers
private extension LunchViewModel {
    func setupSubscribers() {
        setupLunchDaysSubscribers()
        setupOldLunchesSubscribers()
        setupCurrentAndLoadResetButtonSubscribers()
    }
    
    func setupLunchDaysSubscribers() {
        lunchModel.$employeesUrlString
            .map { (urlString: String) -> AnyPublisher<[Employee], Error> in
                guard let url = URL(string: urlString) else {
                    return Fail<[Employee], Error>(error: LunchError.badURL)
                        .eraseToAnyPublisher()
                }
                return URLSession.shared.dataTaskPublisher(for: url)
                    .map(\.data)
                    .decode(type: [Employee].self, decoder: JSONDecoder())
                    .eraseToAnyPublisher()
            }
            .flatMap { $0 }
            .map { [weak self] (employees) -> Result<LunchDays?, Error> in
                guard let self = self else { return .success(nil) }
                return self.generateLunchDays(for: employees, startDate: self.lunchModel.startDate)
            }
            .replaceError(with: .failure(LunchError.lunchDaysCouldntBeRetreived))
            .sink(receiveValue: { [weak self] (result) in
                guard let self = self else { return }
                self.lastFetchedLunchDays = result
                self.filteredLunchDays = result
                switch self.currentLunchDays {
                case let .success(lunchDays):
                    if lunchDays == nil {
                        self.currentLunchDays = result
                    }
                default:
                    break
                }
                var loadResetButtonCurrentPart: Bool = true
                var loadResetButtonLastFetchedPart: Bool = true
                
                switch self.lastFetchedLunchDays {
                case let .success(newDays):
                    loadResetButtonLastFetchedPart = newDays != nil
                case .failure(_):
                    loadResetButtonLastFetchedPart = false
                }
                switch self.currentLunchDays {
                case let .success(newDays):
                    loadResetButtonCurrentPart = newDays != nil
                case .failure(_):
                    loadResetButtonCurrentPart = false
                }
                self.loadResetButtonEnabled = loadResetButtonCurrentPart && loadResetButtonLastFetchedPart
            })
            .store(in: &subscriptions)
        
        $filteredLunchDays
            .combineLatest(lunchModel.$filterString)
            .map { [weak self] (result, filterString) -> Result<LunchDays?, Error> in
                guard let self = self else { return .success(nil) }
                guard let safeFilterString = filterString, safeFilterString != self.noneFilter else { return result }
                guard self.filterStrings.contains(safeFilterString) else {
                    return .failure(LunchError.filterStringIsNotFound)
                }
                
                var newLunchDays: LunchDays? = nil
                switch result {
                case let .success(lunchDays):
                    if let safeLunchDays = lunchDays {
                        newLunchDays = safeLunchDays
                        var newDays: [LunchDay] = []
                        for day in safeLunchDays.lunchDays {
                            var newDay: LunchDay = day
                            newDay.lunchTeams = newDay.lunchTeams.filter({ $0.firstEmployee == safeFilterString || $0.secondEmployee == safeFilterString })
                            newDays.append(newDay)
                        }
                        newLunchDays?.lunchDays = newDays
                    }
                default:
                    break
                }
                return .success(newLunchDays)
            }
            .sink { [weak self] (result) in
                guard let self = self else { return }
                self.shownLunchDays = result
            }
            .store(in: &subscriptions)
        
        $filteredLunchDays
            .sink(receiveValue: { [weak self] (result) in
                guard let self = self else { return }
                
                var currentButtonEnabled: Bool = true
                var currentResult: LunchDays? = nil
                var filteredResults: LunchDays? = nil
                var oldResults: LunchDays? = nil
                var newScheduleEnabled: Bool = true
                
                switch result {
                case let .success(newDays):
                    filteredResults = newDays
                    newScheduleEnabled = filteredResults != nil
                case .failure(_):
                    newScheduleEnabled = false
                }
                
                switch self.currentLunchDays {
                case let .success(newDays):
                    currentResult = newDays
                    currentButtonEnabled = currentResult != nil
                case .failure(_):
                    currentButtonEnabled = false
                }
                
                if let safeCurrentResult = currentResult,
                   let safeFilteredResult = filteredResults,
                   safeFilteredResult.id == safeCurrentResult.id {
                    currentButtonEnabled = false
                }
                self.currentButtonEnabled = currentButtonEnabled
                
                switch self.oldLunchDays {
                case let .success(newDays):
                    oldResults = newDays
                default:
                    break
                }
                if let safeFilteredResult = filteredResults {
                    newScheduleEnabled = !safeFilteredResult.employees.isEmpty
                    if let safeOldResult = oldResults,
                       safeFilteredResult.id == safeOldResult.id {
                        newScheduleEnabled = false
                    }
                }
                self.newScheduleEnabled = newScheduleEnabled
                self.scheduleDateLabelText = newScheduleEnabled ? "Starting date: \(LunchesViewController.dateFormatter.string(from: self.lunchModel.startDate))" : nil
            })
            .store(in: &subscriptions)
    }
    
    func setupOldLunchesSubscribers() {
        lunchModel.$oldLunchesURLs
            .map { (url) -> [URL] in
                guard let safeUrls = url, !safeUrls.isEmpty else { return [] }
                if let safePreviousURL = self.previousOldURL,
                   !safeUrls.contains(where: { $0 == safePreviousURL }) {
                    self.previousOldURL = nil
                }
                return safeUrls
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.oldLunches, on: self)
            .store(in: &subscriptions)
        
        lunchModel.$selectedOldLunch
            .sink { [weak self] (url) in
                guard let self = self else { return }
                self.oldLunchDaysURL = url
                guard let safeUrl = url else {
                    self.previousOldURL = nil
                    return
                }
                guard let selectedURL = self.oldLunches.first(where: { $0 == safeUrl }) else {
                    self.oldLunchDays = .failure(LunchError.selectedOldURLNotFound)
                    return
                }
                do {
                    let jsonData = try Data(contentsOf: selectedURL)
                    let oldLunchDays = try JSONDecoder().decode(LunchDays.self, from: jsonData)
                    let result: Result<LunchDays?, Error> = .success(oldLunchDays)
                    self.oldLunchDays = result
                    self.filteredLunchDays = self.oldLunchDays
                    self.previousOldURL = safeUrl
                } catch let error {
                    self.oldLunchDays = .failure(error)
                }
            }
            .store(in: &subscriptions)
    }
    
    func setupCurrentAndLoadResetButtonSubscribers() {
        lunchModel.currentButtonPublisher
            .sink { [weak self] (_) in
                guard let self = self else { return }
                switch self.currentLunchDays {
                case let .success(currentLunchDays):
                    guard let safeCurrentDays = currentLunchDays else { return }
                    self.filteredLunchDays = .success(safeCurrentDays)
                case .failure(_):
                    break
                }
            }
            .store(in: &subscriptions)
        
        lunchModel.loadResetButtonPublisher
            .sink { [weak self] (_) in
                guard let self = self else { return }
                switch self.lastFetchedLunchDays {
                case let .success(lastFetchedDays):
                    guard let safeLastFetchedDays = lastFetchedDays else { return }
                    self.filteredLunchDays = .success(safeLastFetchedDays)
                case .failure(_):
                    break
                }
            }
            .store(in: &subscriptions)
    }
    
}

// MARK: - Helper methods
extension LunchViewModel {
    static func changeDateIfWeekend(date: Date) -> Date {
        var newDate = date
        if Calendar.current.isDateInWeekend(date) {
            var dateComponents = DateComponents()
            while Calendar.current.isDateInWeekend(newDate) {
                dateComponents.day = 1
                if let safeNewDate = Calendar.current.date(byAdding: dateComponents, to: newDate) {
                    newDate = safeNewDate
                } else {
                    break
                }
            }
        }
        return newDate
    }
    
    func generateLunchDays(for employees: [Employee], startDate: Date) -> Result<LunchDays?, Error> {
        var newLunchDays: [LunchDay] = []
        var newEmployees: [Employee] = employees
        
        let newStartDay: Date = LunchViewModel.changeDateIfWeekend(date: startDate)
        var futureDate: Date = startDate
        var endDate: Date = futureDate
        var dateComponents = DateComponents()
        
        guard newEmployees.count > 2 && newEmployees.count % 2 == 0 else {
            if newEmployees.count == 2 {
                let oneTeam = LunchTeam(firstEmployee: newEmployees[0].name,
                                        secondEmployee: newEmployees[1].name)
                let lunchDay = LunchDay(lunchTeams: [oneTeam],
                                        date: futureDate,
                                        dayName: self.dayNameDateFormatter.string(from: LunchViewModel.changeDateIfWeekend(date: futureDate)))
                endDate = futureDate
                let newDays = LunchDays(startDate: newStartDay,
                                        endDate: endDate,
                                        lunchDays: [lunchDay],employees: newEmployees)
                return .success(newDays)
            }
            endDate = futureDate
            if newEmployees.count < 2 {
                return .failure(LunchError.notEnoughEmployees)
            } else {
                return .failure(LunchError.oddNumberOfEmployees)
            }
        }
        
        newEmployees.shuffle()
        let newCount: Int = newEmployees.count / 2
        var firstHalfArray = Array(newEmployees[0...newCount - 1])
        var secondHalfArray = Array(newEmployees[newCount...newEmployees.count - 1])
        
        for i in 0...newEmployees.count - 2 {
            var oneLunchDayTeams: [LunchTeam] = []
            if i > 0 {
                let lastOfFirst = firstHalfArray.removeLast()
                let firstOfSecond = secondHalfArray.removeFirst()
                firstHalfArray.insert(firstOfSecond, at: 1)
                secondHalfArray.append(lastOfFirst)
            }
            for j in 0...newCount - 1 {
                let firstEmployee: String = firstHalfArray[j].name
                let secondEmployee: String = secondHalfArray[j].name
                let oneTeam = LunchTeam(firstEmployee: firstEmployee,
                                        secondEmployee: secondEmployee)
                oneLunchDayTeams.append(oneTeam)
            }
            oneLunchDayTeams.shuffle()
            
            if i > 0 {
                dateComponents.day = 1
            }
            futureDate = Calendar.current.date(byAdding: dateComponents, to: futureDate) ?? Date()
            futureDate = LunchViewModel.changeDateIfWeekend(date: futureDate)
            let oneLunchDay = LunchDay(lunchTeams: oneLunchDayTeams,
                                       date: futureDate,
                                       dayName: self.dayNameDateFormatter.string(from: futureDate))
            newLunchDays.append(oneLunchDay)
        }
        endDate = futureDate
        let newDays = LunchDays(startDate: newStartDay,
                                endDate: endDate,
                                lunchDays: newLunchDays,
                                employees: employees)
        return .success(newDays)
    }
}
