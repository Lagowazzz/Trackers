
import Foundation

struct WeekTable {
    let value: WeekDay
    let isActive: Bool
}

enum WeekDay: Int, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var value: String {
        switch self {
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        case .sunday:
            return "Воскресение"
        }
    }
    
    var abb: String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }
    
    static func weekDay(fromWeekDays weekDays: [WeekDay]) -> Int16 {
        var weekDay: Int16 = 0
        for day in weekDays {
            weekDay |= 1 << day.rawValue
        }
        return weekDay
    }

    static func weekDays(fromWeekDay value: Int16) -> [WeekDay] {
        return WeekDay.allCases.filter { value & (1 << $0.rawValue) != 0 }
    }
}
