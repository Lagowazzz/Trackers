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
        let red = UIViewController()
        let redImage = UIImage(named: "red")
        let redImageView = UIImageView(image: redImage)
        redImageView.contentMode = .scaleAspectFill
        red.view.addSubview(redImageView)
        redImageView.translatesAutoresizingMaskIntoConstraints = false
        redImageView.leadingAnchor.constraint(equalTo: red.view.leadingAnchor).isActive = true
        redImageView.trailingAnchor.constraint(equalTo: red.view.trailingAnchor).isActive = true
        redImageView.bottomAnchor.constraint(equalTo: red.view.bottomAnchor).isActive = true
        redImageView.topAnchor.constraint(equalTo: red.view.topAnchor).isActive = true
        
        let redLabel = UILabel()
        redLabel.text = "Даже если это\n не литры воды и йога"
        redLabel.font = .boldSystemFont(ofSize: 32)
        redLabel.textColor = .black
        redLabel.textAlignment = .center
        redLabel.numberOfLines = 3
        red.view.addSubview(redLabel)
        redLabel.translatesAutoresizingMaskIntoConstraints = false
        redLabel.leadingAnchor.constraint(equalTo: red.view.leadingAnchor, constant: 16).isActive = true
        redLabel.trailingAnchor.constraint(equalTo: red.view.trailingAnchor, constant: -16).isActive = true
        redLabel.bottomAnchor.constraint(equalTo: red.view.bottomAnchor, constant: -304).isActive = true
        
        let blue = UIViewController()
        let blueImage = UIImage(named: "blue")
        let blueImageView = UIImageView(image: blueImage)
        blue.view.addSubview(blueImageView)
        blueImageView.translatesAutoresizingMaskIntoConstraints = false
        blueImageView.leadingAnchor.constraint(equalTo: blue.view.leadingAnchor).isActive = true
        blueImageView.trailingAnchor.constraint(equalTo: blue.view.trailingAnchor).isActive = true
        blueImageView.bottomAnchor.constraint(equalTo: blue.view.bottomAnchor).isActive = true
        blueImageView.topAnchor.constraint(equalTo: blue.view.topAnchor).isActive = true
        
        let blueLabel = UILabel()
        blueLabel.text = "Отслеживайте только\n то, что хотите"
        blueLabel.font = .boldSystemFont(ofSize: 32)
        blueLabel.textColor = .black
        blueLabel.textAlignment = .center
        blueLabel.numberOfLines = 3
        blue.view.addSubview(blueLabel)
        blueLabel.translatesAutoresizingMaskIntoConstraints = false
        blueLabel.bottomAnchor.constraint(equalTo: blue.view.bottomAnchor, constant: -304).isActive = true
        blueLabel.leadingAnchor.constraint(equalTo: blue.view.leadingAnchor, constant: 16).isActive = true
        blueLabel.trailingAnchor.constraint(equalTo: blue.view.trailingAnchor, constant: -16).isActive = true
        
        return [blue, red]
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
