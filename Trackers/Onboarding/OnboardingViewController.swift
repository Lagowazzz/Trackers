import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var onboardingCompletionHandler: (() -> Void)?
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private lazy var pages: [UIViewController] = {
        let page1 = OnboardingSetupPageViewController(imageName: "blue", text: "Отслеживайте только\n то, что хотите")
        let page2 = OnboardingSetupPageViewController(imageName: "red", text: "Даже если это\n не литры воды и йога")
        return [page1, page2]
    }()
    
    private let doneButton: UIButton = {
        let doneButton = UIButton()
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Вот это технологии!", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16)
        doneButton.backgroundColor = .black
        doneButton.addTarget(nil, action: #selector(OnboardingViewController.didTapDoneButton), for: .touchUpInside)
        return doneButton
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        setupUI()
        
        dataSource = self
        delegate = self
    }
    
    @objc private func didTapDoneButton() {
        onboardingCompletionHandler?()
    }
    
    private func setupUI() {
        view.addSubview(doneButton)
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            
            pageControl.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return pages.last
        }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else {
            return pages.first
        }
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
