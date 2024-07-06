import CoreData
import UIKit

struct TrackerStoreUpdate {
    let addedIndexPaths: [IndexPath]
    let addedSections: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    func addCategoryIfNeeded(_ category: TrackerCategory) throws
    func setupDelegate(_ delegate: TrackerStoreDelegate)
    func fetchTracker(_ trackerCoreData: TrackerCoreData) throws -> Tracker
    func addTracker(_ tracker: Tracker, toCategory category: TrackerCategory) throws
    func pinTracker(_ tracker: Tracker) throws
}

final class TrackerStore: NSObject {
    
    weak var delegate: TrackerStoreDelegate?
    private let uiColorMarshalling = UIColorMarshalling()
    private var addedSections: IndexSet = []
    private var addedIndexPaths: [IndexPath] = []
    private var trackers: [Tracker] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let trackers = try? objects.map({ try self.convertTracker(from: $0) })
        else { return [] }
        return trackers
    }
    
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol = {
        TrackerCategoryStore(context: context)
    }()
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.categoryTitle, ascending: false)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        
        try? controller.performFetch()
        return controller
    }()
    
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
    }
    
    private func convertTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let idTracker = trackerCoreData.idTracker,
              let name = trackerCoreData.name,
              let colorString = trackerCoreData.color,
              let emoji = trackerCoreData.emoji else {
            throw NSError(domain: "Invalid data", code: 1, userInfo: nil)
        }
        
        let color = uiColorMarshalling.color(from: colorString)
        let timeTable = WeekDay.weekDays(fromWeekDay: trackerCoreData.weekDays)
        let isIrregular = timeTable.isEmpty
        let isPinned = trackerCoreData.isPinned
        
        return Tracker(
            id: idTracker,
            name: name,
            color: color,
            emoji: emoji,
            timeTable: timeTable,
            isIrregular: isIrregular,
            isPinned: isPinned
        )
    }
    
    private func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        let trackerCategoryCoreData = try trackerCategoryStore.fetchCategoryCoreData(for: category)
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.idTracker = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.weekDays = WeekDay.weekDay(fromWeekDays: tracker.timeTable)
        trackerCoreData.category = trackerCategoryCoreData
        trackerCoreData.isPinned = tracker.isPinned
        
        try saveContext()
    }
    
    private func saveContext() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    func addCategoryIfNeeded(_ category: TrackerCategory) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "categoryTitle == %@", category.title)
        
        let results = try context.fetch(request)
        
        if results.isEmpty {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.categoryTitle = category.title
            try saveContext()
        }
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idTracker == %@", tracker.id as CVarArg)
        if let result = try context.fetch(fetchRequest).first {
            context.delete(result)
            try saveContext()
        } else {
            let userInfo: [String: Any] = [
                NSLocalizedDescriptionKey: "Failed to delete tracker.",
                NSLocalizedFailureReasonErrorKey: "Tracker with the specified ID was not found.",
                "TrackerID": tracker.id
            ]
            throw NSError(domain: NSCocoaErrorDomain, code: NSManagedObjectValidationError, userInfo: userInfo)
        }
    }
    
    func pinTracker(_ tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idTracker == %@", tracker.id as CVarArg)
        if let result = try context.fetch(fetchRequest).first {
            result.isPinned = !result.isPinned
            try saveContext()
        } else {
            let userInfo: [String: Any] = [
                NSLocalizedDescriptionKey: "Failed to pin tracker.",
                NSLocalizedFailureReasonErrorKey: "Tracker with the specified ID was not found.",
                "TrackerID": tracker.id
            ]
            throw NSError(domain: NSCocoaErrorDomain, code: NSManagedObjectValidationError, userInfo: userInfo)             }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreUpdate(
            TrackerStoreUpdate(
                addedIndexPaths: addedIndexPaths, addedSections: addedSections
            )
        )
        addedSections.removeAll()
        addedIndexPaths.removeAll()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        addedSections.removeAll()
        addedIndexPaths.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                addedIndexPaths.append(indexPath)
            }
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            addedSections.insert(sectionIndex)
        default:
            break
        }
    }
}

extension TrackerStore: TrackerStoreProtocol {
    
    func setupDelegate(_ delegate: TrackerStoreDelegate) {
        self.delegate = delegate
    }
    
    func fetchTracker(_ trackerCoreData: TrackerCoreData) throws -> Tracker {
        try convertTracker(from: trackerCoreData)
    }
    
    func addTracker(_ tracker: Tracker, toCategory category: TrackerCategory) throws {
        try addTracker(tracker, to: category)
    }
}
