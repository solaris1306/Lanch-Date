//
//  Lunch.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 17.3.21..
//

import Foundation
import Combine

class Lunch: ObservableObject {
    // MARK: - Helper structures
    struct LunchTeam {
        var firstEmployee: String
        var secondEmployee: String
    }
    
    struct LunchDay {
        var lunchTeams: [LunchTeam]
        var date: Date
        var dayName: String
    }
    
    // MARK: - Properties
    // MARK: - Published properties
    @Published var employeesUrlString: String = ""
    @Published var employees: [Employee] = []
    @Published var currentlyShownLunchInformations: [LunchDay] = []
    @Published var filterString: String? = nil
    @Published var showActivityIndicatorView = false
    
    // MARK: - Private properties
    private var lunchDays: [LunchDay] = []
    private let dayNameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initialization
    required init() {
        setupSubscribers()
    }
}

// MARK: - Subscription methods
private extension Lunch {
    func createLunchesPublisher() -> AnyPublisher<[LunchDay], Never> {
        return $employees
                .map { [weak self] (employees) -> [LunchDay] in
                    guard let self = self else { return [] }
                    var newLunchTeams: [LunchDay] = []
                    var newEmployees: [Employee] = employees
                    
                    var futureDate: Date = Date()
                    var dateComponents = DateComponents()
                    
                    guard newEmployees.count > 2 && newEmployees.count % 2 == 0 else {
                        if newEmployees.count == 2 {
                            let oneTeam = LunchTeam(firstEmployee: newEmployees[0].name,
                                                    secondEmployee: newEmployees[1].name)
                            let lunchDay = LunchDay(lunchTeams: [oneTeam],
                                                    date: futureDate,
                                                    dayName: self.dayNameDateFormatter.string(from: self.changeDateIfWeekend(date: futureDate)))
                            return [lunchDay]
                        }
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
                    return newLunchTeams
                }
                .eraseToAnyPublisher()
    }
    
    func setupSubscribers() {
        setupEmployeesSubscribers()
        setupLunchSubscribers()
        setupAlertIndicatorSubsriber()
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
            .map({ _ in nil })
            .receive(on: DispatchQueue.main)
            .assign(to: \.filterString, on: self)
            .store(in: &subscriptions)
    }
    
    func setupLunchSubscribers() {
        let lunchesPublisher = createLunchesPublisher()
        
        lunchesPublisher
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
}

// MARK: - Helper methods

private extension Lunch {
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
}
