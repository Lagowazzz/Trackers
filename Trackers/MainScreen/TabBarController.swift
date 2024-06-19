
import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let separator = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1))
        separator.backgroundColor = .gray
        tabBar.addSubview(separator)
        
        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabBarTrackers.title", comment: ""),
            image: UIImage(named: "circle"),
            selectedImage: nil)
        
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabBarStatistic.title", comment: ""),
            image: UIImage(named: "rabbit"),
            selectedImage: nil)
        
        self.viewControllers = [trackersNavigationController, statisticViewController]
    }
}
