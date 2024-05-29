import CoreData
import UIKit

struct TrackerCategoryStoreUpdate {
    let addedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

protocol TrackerCategoryStoreProtocol {
    func setupDelegate(_ delegate: TrackerCategoryStoreDelegate)
    func getCategories() throws -> [TrackerCategory]
    func fetchCategoryCoreData(for category: TrackerCategory) throws -> TrackerCategoryCoreData
    func addCategory(_ category: TrackerCategory) throws
}

final class TrackerCategoryStore: NSObject {
    
    weak var delegate: TrackerCategoryStoreDelegate?
        
    private lazy var trackerStore: TrackerStore = {
        TrackerStore(context: context)
    }()
    
    private var insertedIndexPaths: [IndexPath] = []
    private var deletedIndexPaths: [IndexPath] = []
    
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchedRequest = TrackerCategoryCoreData.fetchRequest()
        fetchedRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.categoryTitle, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchedRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        
        try? controller.performFetch()
        return controller
    }()
        
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
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
    
    private func convertTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.categoryTitle else {
            throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error in category title"])
        }
        guard let trackersSet = trackerCategoryCoreData.tracker as? Set<TrackerCoreData> else {
            throw NSError(domain: "", code: 2, userInfo: [NSLocalizedDescriptionKey: "Error in trackers set"])
        }
        let trackerList = try trackersSet.compactMap { trackerCoreData in
            guard let tracker = try? trackerStore.fetchTracker(trackerCoreData) else {
                throw NSError(domain: "", code: 3, userInfo: [NSLocalizedDescriptionKey: "Error initializing tracker"])
            }
            return tracker
        }
        return TrackerCategory(title: title, trackers: trackerList)
    }
    
    private func fetchCategories() throws -> [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            throw NSError(domain: "", code: 4, userInfo: [NSLocalizedDescriptionKey: "Error fetching categories"])
        }
        let categories = try objects.map { try convertTrackerCategory(from: $0) }
        return categories
    }
    
    private func fetchTrackerCategoryCoreData(for category: TrackerCategory) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K = %@",
            #keyPath(TrackerCategoryCoreData.categoryTitle), category.title
        )
        guard let categoryCoreData = try context.fetch(request).first else {
            throw NSError(domain: "", code: 5, userInfo: [NSLocalizedDescriptionKey: "Error fetching category core data"])
        }
        return categoryCoreData
    }
    
    private func checkTitle(with title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K = %@",
            #keyPath(TrackerCategoryCoreData.categoryTitle), title
        )
        let count = try context.count(for: request)
        guard count == 0 else {
            return
        }
    }
    
    private func addNewCategory(_ category: TrackerCategory) throws {
        try checkTitle(with: category.title)
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.categoryTitle = category.title
        categoryCoreData.tracker = NSSet()
        try saveContext()
    }
}

extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    
    func setupDelegate(_ delegate: TrackerCategoryStoreDelegate) {
        self.delegate = delegate
    }
    
    func getCategories() throws -> [TrackerCategory] {
        try fetchCategories()
    }
    
    func fetchCategoryCoreData(for category: TrackerCategory) throws -> TrackerCategoryCoreData {
        try fetchTrackerCategoryCoreData(for: category)
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        try addNewCategory(category)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths.removeAll()
        deletedIndexPaths.removeAll()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(
            TrackerCategoryStoreUpdate(
                addedIndexPaths: insertedIndexPaths,
                deletedIndexPaths: deletedIndexPaths
            )
        )
        insertedIndexPaths.removeAll()
        deletedIndexPaths.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexPaths.append(indexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexPaths.append(indexPath)
            }
        default:
            break
        }
    }
}
