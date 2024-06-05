import UIKit

protocol AddNewTrackerViewControllerDelegate: AnyObject {
    func createdTracker(tracker: Tracker, categoryTitle: String)
    func cancelCreateTracker()
}

final class AddNewTrackerViewController: UIViewController {
    
    weak var delegate: AddNewTrackerViewControllerDelegate?
    
    private lazy var regularButton: UIButton = {
        let regularButton = UIButton()
        regularButton.translatesAutoresizingMaskIntoConstraints = false
        regularButton.backgroundColor = .black
        regularButton.layer.cornerRadius = 16
        regularButton.layer.masksToBounds = true
        regularButton.setTitle("Привычка", for: .normal)
        regularButton.setTitleColor(.white, for: .normal)
        regularButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        regularButton.addTarget(self, action: #selector(regularButtonDidTap), for: .touchUpInside)
        return regularButton
    }()
    
    private lazy var noRegularButton: UIButton = {
        let noRegularButton = UIButton()
        noRegularButton.translatesAutoresizingMaskIntoConstraints = false
        noRegularButton.backgroundColor = .black
        noRegularButton.layer.cornerRadius = 16
        noRegularButton.layer.masksToBounds = true
        noRegularButton.setTitle("Нерегулярное событие", for: .normal)
        noRegularButton.setTitleColor(.white, for: .normal)
        noRegularButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        noRegularButton.addTarget(self, action: #selector(noRegularButtonDidTap), for: .touchUpInside)
        return noRegularButton
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.axis = .vertical
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupConstraints()
    }
    
    @objc private func regularButtonDidTap() {
        let activityViewController = ActivityViewController(activityType: .regular)
        activityViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: activityViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func noRegularButtonDidTap() {
        let activityViewController = ActivityViewController(activityType: .nonRegular)
        activityViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: activityViewController)
        present(navigationController, animated: true)
    }
    
    private func setupConstraints() {
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(regularButton)
        stackView.addArrangedSubview(noRegularButton)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 136)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Создание трекера"
    }
}

extension AddNewTrackerViewController: ActivityViewControllerDelegate {
    func createTracker(tracker: Tracker, categoryTitle: String) {
        delegate?.createdTracker(tracker: tracker, categoryTitle: categoryTitle)
        dismiss(animated: true)
    }
    
    func cancelCreateTracker() {
        dismiss(animated: true)
    }
}
