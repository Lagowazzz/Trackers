import UIKit

final class AddNewTrackerViewController: UIViewController {
    
    private var regularButton: UIButton!
    private var noRegularButton: UIButton!
    private var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupStackView()
        setupNoRegularButton()
        setupRegularButton()
        setupNavigationBar()
    }
    
    @objc private func regularButtonDidTap() {
    }
    
    @objc private func noRegularButtonDidTap() {
    }
        
        private func setupRegularButton() {
            regularButton = UIButton()
            regularButton.translatesAutoresizingMaskIntoConstraints = false
            regularButton.backgroundColor = .black
            regularButton.layer.cornerRadius = 16
            regularButton.layer.masksToBounds = true
            regularButton.setTitle("Привычка", for: .normal)
            regularButton.setTitleColor(.white, for: .normal)
            regularButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            regularButton.addTarget(self, action: #selector(regularButtonDidTap), for: .touchUpInside)
            stackView.addArrangedSubview(regularButton)
        }
        
        private func setupNoRegularButton() {
            noRegularButton = UIButton()
            noRegularButton.translatesAutoresizingMaskIntoConstraints = false
            noRegularButton.backgroundColor = .black
            noRegularButton.layer.cornerRadius = 16
            noRegularButton.layer.masksToBounds = true
            noRegularButton.setTitle("Нерегулярное событие", for: .normal)
            noRegularButton.setTitleColor(.white, for: .normal)
            noRegularButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            noRegularButton.addTarget(self, action: #selector(noRegularButtonDidTap), for: .touchUpInside)
            stackView.addArrangedSubview(noRegularButton)
        }
        
        private func setupStackView() {
            stackView = UIStackView()
            view.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.distribution = .fillEqually
            stackView.spacing = 16
            stackView.axis = .vertical
            
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
