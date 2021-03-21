//
//  LunchViewModel.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 21.3.21..
//

import Foundation
import Combine

enum LunchError: Error {
    case badURL(description: String)
    case lunchDaysAreNil(description: String)
    case lunchDaysCouldntBeRetreived(description: String)
}

class LunchViewModel: ObservableObject {
    // MARK: - Public properties
    let lunchModel: LunchModel
    @Published private (set) var shownLunchDays: Result<LunchDays?, Error> = .success(nil)
    private (set) var oldLunches: [URL] = []
    
    // MARK: - Private properties
    private var currentLunchDays: Result<LunchDays?, Error> = .success(nil)
    private var oldLunchDays: Result<LunchDays?, Error> = .success(nil)
    private var futureLunchDays: Result<LunchDays?, Error> = .success(nil)
    private var filteredLunchDays: Result<LunchDays?, Error> = .success(nil)
    private var lastFetchedLunchDays: Result<LunchDays?, Error> = .success(nil)
    
    private var subscriptions = Set<AnyCancellable>()
    private let dayNameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    // MARK: - Initialization
    required init(lunchModel: LunchModel = LunchModel()) {
        self.lunchModel = lunchModel
    }
}

// MARK: - Subscribers
private extension LunchViewModel {
    func setupSubscribers() {
        lunchModel.$employeesUrlString
            .map { (urlString: String) -> AnyPublisher<[Employee], Error> in
                guard let url = URL(string: urlString) else {
                    return Fail<[Employee], Error>(error: LunchError.badURL(description: "Bad URL. Please check given URL and/or connectivity."))
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
                return .success(self.generateLunchDays(for: employees, startDate: self.lunchModel.startDate))
            }
            .replaceError(with: .failure(LunchError.lunchDaysCouldntBeRetreived(description: "Lunch days cound't be retreived at this moment. Please check your connectivity and given data.")))
            .sink(receiveValue: { [weak self] (result) in
                guard let self = self else { return }
                self.lastFetchedLunchDays = result
                self.shownLunchDays = result
                switch self.currentLunchDays {
                case let .success(lunchDays):
                    if lunchDays == nil {
                        self.currentLunchDays = result
                    }
                default:
                    break
                }
            })
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
    
    func generateLunchDays(for employees: [Employee], startDate: Date) -> LunchDays? {
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
                                        dayName: self.dayNameDateFormatter.string(from: Lunch.changeDateIfWeekend(date: futureDate)))
                endDate = futureDate
                return LunchDays(startDate: newStartDay,
                                 endDate: endDate,
                                 lunchDays: [lunchDay],
                                 employees: newEmployees)
            }
            endDate = futureDate
            return nil
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
            futureDate = Lunch.changeDateIfWeekend(date: futureDate)
            let oneLunchDay = LunchDay(lunchTeams: oneLunchDayTeams,
                                       date: futureDate,
                                       dayName: self.dayNameDateFormatter.string(from: futureDate))
            newLunchDays.append(oneLunchDay)
        }
        endDate = futureDate
        return LunchDays(startDate: newStartDay,
                         endDate: endDate,
                         lunchDays: newLunchDays,
                         employees: employees)
    }
}
