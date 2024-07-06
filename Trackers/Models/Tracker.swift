import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let timeTable: [WeekDay]
    let isIrregular: Bool
    let isPinned: Bool
}
