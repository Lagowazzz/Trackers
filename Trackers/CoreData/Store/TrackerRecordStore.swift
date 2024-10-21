import CoreData
import UIKit

protocol TrackerRecordStoreProtocol {
    func addRecord(with id: UUID, by date: Date) throws
    func recordsFetch(for tracker: Tracker) throws -> [TrackerRecord]
    func deleteRecord(with id: UUID, by date: Date) throws
}

final class TrackerRecordStore: NSObject, TrackerRecordStoreProtocol {
    
    private let context: NSManagedObjectContext
    private let schedule: [WeekDay] = [
        .monday,
        .tuesday,
        .wednesday,
        .thursday,
        .friday,
        .saturday,
        .sunday
    ]
    
    convenience override init() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            self.init(context: context)
        } else {
            fatalError("Unable to get AppDelegate or persistentContainer")
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func getNumberOfCompletedTrackers() -> Int {
        return fetchSortedRecords().count
    }
    
    func getStats() -> [Int]? {
        let recordsDict = fetchSortedRecords()
        let dates = recordsDict.compactMap { $0["date"] as? Date }
        let perfectDays = countPerfectDays(in: dates)
        let bestPeriod = calculateStreak(from: dates)
        let average = getNumberOfCompletedTrackers() / recordsDict.count
        
        return [perfectDays, average, bestPeriod]
    }
    
    private func fetchRecords(_ tracker: Tracker) throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(
            format: "%K = %@",
            #keyPath(TrackerRecordCoreData.trackerID), tracker.id as CVarArg
        )
        let objects = try context.fetch(request)
        let records = objects.compactMap { object -> TrackerRecord? in
            guard let date = object.date, let id = object.trackerID else { return nil }
            return TrackerRecord(id: id, date: date)
        }
        return records
    }
    
    private func fetchTrackerCoreData(for idTracker: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(
            format: "%K = %@",
            #keyPath(TrackerCoreData.idTracker), idTracker as CVarArg
        )
        return try context.fetch(request).first
    }
    
    private func fetchTrackerRecordCoreData(for idTracker: UUID, and date: Date) throws -> TrackerRecordCoreData? {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(
            format: "%K = %@ AND %K = %@",
            #keyPath(TrackerRecordCoreData.tracker.idTracker), idTracker as CVarArg,
            #keyPath(TrackerRecordCoreData.date), date as CVarArg
        )
        return try context.fetch(request).first
    }
    
    private func saveContext() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
    
    private func createNewRecord(id: UUID, date: Date) throws {
        guard let trackerCoreData = try fetchTrackerCoreData(for: id) else {
            throw NSError(domain: "TrackerRecordStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch tracker"])
        }
        
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.trackerID = id
        trackerRecordCoreData.date = date
        trackerRecordCoreData.tracker = trackerCoreData
        
        try saveContext()
    }
    
    private func removeRecord(idTracker: UUID, date: Date) throws {
        guard let trackerRecordCoreData = try fetchTrackerRecordCoreData(for: idTracker, and: date) else {
            throw NSError(domain: "TrackerRecordStore", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch tracker record"])
        }
        context.delete(trackerRecordCoreData)
        try saveContext()
    }
    
    func recordsFetch(for tracker: Tracker) throws -> [TrackerRecord] {
        try fetchRecords(tracker)
    }
    
    func addRecord(with id: UUID, by date: Date) throws {
        try createNewRecord(id: id, date: date)
    }
    
    func deleteRecord(with id: UUID, by date: Date) throws {
        try removeRecord(idTracker: id, date: date)
    }
    
    private func fetchRecords() -> [TrackerRecordCoreData] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        
        do {
            return try context.fetch(request)
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
    private func countPerfectDays(in dates: [Date]) -> Int {
        return dates.filter { date in
            let weekday = Calendar.current.component(.weekday, from: date)
            return schedule.contains(where: { $0.rawValue == weekday })
        }.count
    }
    
    private func fetchSortedRecords() -> [[String: Any]] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["date"]
        
        let keyPathExp = NSExpression(forKeyPath: "date")
        let expression = NSExpression(forFunction: "count:", arguments: [keyPathExp])
        
        let countDesc = NSExpressionDescription()
        countDesc.expression = expression
        countDesc.name = "count"
        countDesc.expressionResultType = .integer64AttributeType
        
        request.propertiesToFetch = ["date", countDesc]
        request.resultType = .dictionaryResultType
        
        do {
            let trackerRecords = try context.fetch(request) as? [NSDictionary] ?? []
            return trackerRecords.compactMap { $0 as? [String: Any] }
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }
    
    private func calculateStreak(from dates: [Date]) -> Int {
        let sortedDates = dates.sorted()
        guard !sortedDates.isEmpty else { return 0 }
        let referenceDate = Calendar.current.startOfDay(for: sortedDates.first!)
        let dayDifferences = sortedDates.map { date in
            Calendar.current.dateComponents([.day], from: referenceDate, to: date).day!
        }
        return findMaxConsecutiveDays(in: dayDifferences)
    }
    
    private func findMaxConsecutiveDays(in days: [Int]) -> Int {
        var longestStreak = 0
        var currentStreak = 1
        for (prev, next) in zip(days, days.dropFirst()) {
            if next > prev + 1 {
                currentStreak = 1
            } else if next == prev + 1 {
                currentStreak += 1
            }
            longestStreak = max(longestStreak, currentStreak)
        }
        return longestStreak
    }
}
