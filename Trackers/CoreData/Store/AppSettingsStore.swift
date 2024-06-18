import CoreData
import UIKit

final class AppSettingsStore {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func hasSeenOnboarding() -> Bool {
        let request: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let settings = try context.fetch(request).first
            return settings?.hasSeenOnboarding ?? false
        } catch {
            assertionFailure("Failed to fetch AppSettings: \(error)")
            return false
        }
    }
    
    func setHasSeenOnboarding(_ seen: Bool) {
        let request: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let settings = try context.fetch(request).first ?? AppSettings(context: context)
            settings.hasSeenOnboarding = seen
            try context.save()
        } catch {
            assertionFailure("Failed to update AppSettings: \(error)")
        }
    }
}
