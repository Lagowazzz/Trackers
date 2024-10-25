
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
            return NSLocalizedString("monday.title", comment: "")
        case .tuesday:
            return NSLocalizedString("tuesday.title", comment: "")
        case .wednesday:
            return NSLocalizedString("wednesday.title", comment: "")
        case .thursday:
            return NSLocalizedString("thursday.title", comment: "")
        case .friday:
            return NSLocalizedString("friday.title", comment: "")
        case .saturday:
            return NSLocalizedString("saturday.title", comment: "")
        case .sunday:
            return NSLocalizedString("sunday.title", comment: "")
        }
    }
    
    var abb: String {
        switch self {
        case .monday:
            return NSLocalizedString("mon.title", comment: "")
        case .tuesday:
            return NSLocalizedString("tue.title", comment: "")
        case .wednesday:
            return NSLocalizedString("wed.title", comment: "")
        case .thursday:
            return NSLocalizedString("thu.title", comment: "")
        case .friday:
            return NSLocalizedString("fri.title", comment: "")
        case .saturday:
            return NSLocalizedString("sat.title", comment: "")
        case .sunday:
            return NSLocalizedString("sun.title", comment: "")
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
