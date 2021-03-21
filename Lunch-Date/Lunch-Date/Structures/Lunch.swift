//
//  Lunch.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 17.3.21..
//

import Foundation
import Combine

class Lunch: ObservableObject, Codable {
    // MARK: - Coding keys
    enum CodingKeys: String, CodingKey {
        case lunchDays
        case startDate
        case endDate
        case employees
    }
    
    // MARK: - Helper structures
    struct LunchTeam: Codable {
        var firstEmployee: String
        var secondEmployee: String
    }
    
    struct LunchDay: Codable {
        var lunchTeams: [LunchTeam]
        var date: Date
        var dayName: String
    }
    
    // MARK: - Properties
    // MARK: - Published properties
    @Published var employeesUrlString: String = ""
    @Published var employees: [Employee] = [] {
        didSet {
            print("\(employees.count)")
        }
    }
    @Published var currentlyShownLunchInformations: [LunchDay] = []
    @Published var filterString: String? = nil
    @Published var showActivityIndicatorView = false
    @Published var oldLunches: [URL] = []
    @Published var selectedOldLunch: URL? = nil
    
    // MARK: - Private properties
    private let dayNameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    private var subscriptions = Set<AnyCancellable>()
    
    private (set) var startDate: Date = Date()
    private (set) var endDate: Date = Date()
    @Published private (set) var lunchDays: [LunchDay] = []
    
    @Published private var oldLunchesURLs: [URL]? = nil
    
    // MARK: - Initialization
    required init() {
        setupSubscribers()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lunchDays = try container.decode([LunchDay].self, forKey: .lunchDays)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
        self.employees = try container.decode([Employee].self, forKey: .employees)
        setupSubscribers()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lunchDays, forKey: .lunchDays)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(employees, forKey: .employees)
    }
}

// MARK: - Subscription methods
private extension Lunch {
    func setupSubscribers() {
        setupEmployeesSubscribers()
        setupLunchSubscribers()
        setupAlertIndicatorSubsriber()
        setupOldLunchesSubscribers()
    }
    
    func setupEmployeesSubscribers() {
        $employeesUrlString
            .map { (urlString) -> AnyPublisher<[Employee], Never> in
                let url = URL(string: urlString)
                let publisher: AnyPublisher<[Employee], Error>
                if let safeUrl = url {
                    publisher = URLSession.shared.dataTaskPublisher(for: safeUrl)
                        .map(\.data)
                        .decode(type: [Employee].self, decoder: JSONDecoder())
                        .eraseToAnyPublisher()
                } else {
                    publisher = Fail<[Employee], Error>(error: URLError(.badURL))
                            .eraseToAnyPublisher()
                }
                return publisher
                    .replaceEmpty(with: Employee.placeholderEmployees)
                    .replaceError(with: Employee.placeholderEmployees)
                    .eraseToAnyPublisher()
            }
            .flatMap({ $0 })
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: \.employees, on: self)
            .store(in: &subscriptions)
        
        $employees
            .map({ [weak self] (employees) -> String? in
                guard let self = self else { return nil }
                for employee in employees {
                    if employee.name == self.filterString {
                        return employee.name
                    }
                }
                return nil
            })
            .receive(on: DispatchQueue.main)
            .assign(to: \.filterString, on: self)
            .store(in: &subscriptions)
    }
    
    func setupLunchSubscribers() {
        let lunchesPublisher = $employees
            .map { [weak self] (employees) -> [LunchDay] in
                guard let self = self else { return [] }
                return self.generateLunchTeams(for: employees)
            }
            .eraseToAnyPublisher()
        
        $employees
            .sink { (employees) in
                print(employees)
            }
            .store(in: &subscriptions)
        
        lunchesPublisher
            .map({ [weak self] (lunchDays) -> [LunchDay]? in
                guard let self = self else { return nil }
                if self.selectedOldLunch != nil { return nil }
                return lunchDays
            })
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .assign(to: \.lunchDays, on: self)
            .store(in: &subscriptions)
        
        lunchesPublisher.combineLatest($filterString) { (lunchDays, filterString) -> [LunchDay] in
            guard let safeFilterString = filterString else { return lunchDays }
            return lunchDays.map { (lunchDay) -> LunchDay in
                let newTeams: [LunchTeam] = lunchDay.lunchTeams.filter({ $0.firstEmployee == safeFilterString || $0.secondEmployee == safeFilterString })
                return LunchDay(lunchTeams: newTeams,
                                date: lunchDay.date,
                                dayName: self.dayNameDateFormatter.string(from: lunchDay.date))
            }
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \.currentlyShownLunchInformations, on: self)
        .store(in: &subscriptions)
    }
    
    func setupAlertIndicatorSubsriber() {
        let firstPublisher: AnyPublisher<Bool, Never> = $employeesUrlString.map({ _ in true }).eraseToAnyPublisher()
        let secondPublisher: AnyPublisher<Bool, Never> = $employees.map({ _ in false }).eraseToAnyPublisher()
        let thirdPublisher: AnyPublisher<Bool, Never> = $filterString.map({ _ in true }).eraseToAnyPublisher()
        let fourthPublisher: AnyPublisher<Bool, Never> = $currentlyShownLunchInformations.map({ _ in false }).eraseToAnyPublisher()
        let mergedPublisher: AnyPublisher<Bool, Never> = firstPublisher.merge(with: secondPublisher, thirdPublisher, fourthPublisher).eraseToAnyPublisher()
        mergedPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.showActivityIndicatorView, on: self)
            .store(in: &subscriptions)
    }
    
    func setupOldLunchesSubscribers() {
        oldLunchesURLs = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil)
        
        $oldLunchesURLs
            .map { (url) -> [URL] in
                guard let safeUrls = url, !safeUrls.isEmpty else { return [] }
                return safeUrls
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.oldLunches, on: self)
            .store(in: &subscriptions)
        
        $oldLunches
            .map({ _ in nil })
            .receive(on: DispatchQueue.main)
            .assign(to: \.selectedOldLunch, on: self)
            .store(in: &subscriptions)
        
        $selectedOldLunch
            .map { [weak self] (url) -> URL? in
                guard let self = self,  let safeURL = url, let selectedURL = self.oldLunchesURLs?.first(where: { $0 == safeURL }) else { return nil }
                return selectedURL
            }
            .compactMap({$0})
            .sink { [weak self] (url) in
                guard let self = self else { return }
                do {
                    let jsonData = try Data(contentsOf: url)
                    let newLunch = try JSONDecoder().decode(Lunch.self, from: jsonData)
                    self.startDate = newLunch.startDate
                    self.endDate = newLunch.endDate
                    self.employees = newLunch.employees
                    self.lunchDays = newLunch.lunchDays
                } catch {
                    print("There was an error decoding JSON file.")
                }
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Public methods
extension Lunch {
    func changeLunches(with lunches: [LunchDay]) {
        lunchDays = lunches
    }
    
    func setStartDate(date: Date) {
        startDate = changeDateIfWeekend(date: date)
    }
}

// MARK: - Helper methods
extension Lunch {
    func changeDateIfWeekend(date: Date) -> Date {
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
    
    func generateLunchTeams(for employees: [Employee]) -> [LunchDay] {
        var newLunchTeams: [LunchDay] = []
        var newEmployees: [Employee] = employees
        
        var futureDate: Date = self.startDate
        var dateComponents = DateComponents()
        
        guard newEmployees.count > 2 && newEmployees.count % 2 == 0 else {
            if newEmployees.count == 2 {
                let oneTeam = LunchTeam(firstEmployee: newEmployees[0].name,
                                        secondEmployee: newEmployees[1].name)
                let lunchDay = LunchDay(lunchTeams: [oneTeam],
                                        date: futureDate,
                                        dayName: self.dayNameDateFormatter.string(from: self.changeDateIfWeekend(date: futureDate)))
                self.endDate = futureDate
                return [lunchDay]
            }
            self.endDate = futureDate
            return []
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
            futureDate = self.changeDateIfWeekend(date: futureDate)
            let oneLunchDay = LunchDay(lunchTeams: oneLunchDayTeams,
                                       date: futureDate,
                                       dayName: self.dayNameDateFormatter.string(from: futureDate))
            newLunchTeams.append(oneLunchDay)
        }
        self.endDate = futureDate
        return newLunchTeams
    }
}
