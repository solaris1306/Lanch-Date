//
//  Lunch.swift
//  Lunch-Date
//
//  Created by Aleksandar Adzic on 17.3.21..
//

import Foundation
import Combine

struct Lunch {
    // MARK: - Helper structures
    struct LunchTeam {
        var firstEmployee: String
        var secondEmployee: String
    }
    
    struct LunchDay {
        var lunchTeams: [LunchTeam]
        var date: String
    }
    
    // MARK: - Properties
    private var lunchDays: [LunchDay] = []
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:YYYY"
        return formatter
    }()
    
    private static let employeesUrlString: String = "https://jsonplaceholder.typicode.com/users"
    
    var shownLunchDays: [LunchDay] = []
    var employees: [Employee] = []
    
    let currentEmployeesUrlStringValuePublisher = CurrentValueSubject<String, Never>(employeesUrlString)
    var employeePublisher: AnyPublisher<[Employee], Never>  {
        currentEmployeesUrlStringValuePublisher
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
    }
    
    // MARK: - Methods
    mutating func getNewLunchSchedule() {
        var newLunchTeams: [LunchDay] = []
        var newEmployees: [Employee] = employees
        
        let currentDate: Date = Date()
        var dateComponents = DateComponents()
        
        guard newEmployees.count > 2 && newEmployees.count % 2 == 0 else {
            if newEmployees.count == 2 {
                let oneTeam = LunchTeam(firstEmployee: newEmployees[0].name,
                                        secondEmployee: newEmployees[1].name)
                let lunchDay = LunchDay(lunchTeams: [oneTeam],
                                        date: dateFormatter.string(from: currentDate))
                lunchDays = [lunchDay]
            }
            return
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
            
            dateComponents.day = i
            let futureDate = Calendar.current.date(byAdding: dateComponents, to: currentDate) ?? Date()
            let oneLunchDay = LunchDay(lunchTeams: oneLunchDayTeams,
                                       date: dateFormatter.string(from: futureDate))
            newLunchTeams.append(oneLunchDay)
        }
        lunchDays = newLunchTeams
    }
}
