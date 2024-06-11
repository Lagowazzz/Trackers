import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("Failed to get AppDelegate")
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let appSettingsStore = AppSettingsStore(context: context)
        
        window = UIWindow(windowScene: windowScene)
        
        if appSettingsStore.hasSeenOnboarding() {
            let tabBarController = TabBarController()
            window?.rootViewController = tabBarController
        } else {
            let onboardingViewController = OnboardingViewController()
            onboardingViewController.onboardingCompletionHandler = {
                appSettingsStore.setHasSeenOnboarding(true)
                let tabBarController = TabBarController()
                self.window?.rootViewController = tabBarController
            }
            window?.rootViewController = onboardingViewController
        }
        
        window?.makeKeyAndVisible()
    }
}
