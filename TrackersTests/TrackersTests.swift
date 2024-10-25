import SnapshotTesting
import XCTest
@testable import Trackers

final class TrackersTests: XCTestCase {
    
    func testTrackersViewControllerLightMode() {
        let vc = TrackersViewController()
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackersViewControllerDarkMode() {
        let vc = TrackersViewController()
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
