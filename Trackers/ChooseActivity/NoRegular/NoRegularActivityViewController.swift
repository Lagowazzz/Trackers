
import UIKit

final class NoRegularActivityViewController: UIViewController {
    
    weak var delegate: AddNewTrackerViewControllerDelegate?
    
    private let dataForTableView = "Категория"
    private var selectedWeekTable: [WeekDay] = []
    private var selectedCategory = String()
    private var textField: UITextField!
    private var tableView: UITableView!
    private var stackView: UIStackView!
    private var cancelButton: UIButton!
    private var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupNavBar()
        setupTextField()
        setupStackView()
        setupTableView()
        setupCancelButton()
        setupCreateButton()
        
        createButton.isEnabled = false
        createButton.backgroundColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
        
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
        delegate?.cancelCreateTracker()
    }
    
    @objc private func didTapCreateButton() {
        guard let trackerName = textField.text else { return }
        let currentDate = Date()
        let currentWeekday = Calendar.current.component(.weekday, from: currentDate)
        let newWeekTable = WeekTable(value: WeekDay(rawValue: currentWeekday) ?? .sunday, isActive: true)
        let weekTableArray = [newWeekTable]
        let weekDayArray = weekTableArray.map { $0.value }
        
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: .green,
            emoji: "😎",
            timeTable: weekDayArray
        )
        delegate?.createTracker(tracker: newTracker, categoryTitle: selectedCategory)
        dismiss(animated: true)
    }
    
    private func setupTextField() {
        textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.setupLeftPadding(16)
        textField.placeholder = "Введите название трекера"
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.smartInsertDeleteType = .no
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
        tableView.register(ActivityCell.self, forCellReuseIdentifier: ActivityCell.reuseIdentifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 75),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24)
        ])
    }
    
    private func setupStackView() {
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupCancelButton() {
        cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = .white
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        stackView.addArrangedSubview(cancelButton)
    }
    
    private func setupCreateButton() {
        createButton = UIButton()
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.backgroundColor = .black
        createButton.layer.cornerRadius = 16
        createButton.layer.masksToBounds = true
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        stackView.addArrangedSubview(createButton)
    }
    
    private func setupNavBar(){
        navigationItem.title = "Новое нерегулярное событие"
    }
    
    private func setupSubTitle(_ subTitle: String?, forCellAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ActivityCell else {
            return
        }
        cell.setupText(subText: subTitle)
    }
    
    private func updateCategory(_ category: String) {
        selectedCategory = category
        setupCategoryTitle(selectedCategory)
    }
    
    private func setupCategoryTitle(_ category: String) {
        setupSubTitle(category, forCellAt: IndexPath(row: 0, section: 0))
    }
}

extension NoRegularActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row == 0 else { return }
        let categoryViewController = CategoryViewController()
        categoryViewController.delegate = self
        navigationController?.pushViewController(categoryViewController, animated: true)
    }
}

extension NoRegularActivityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCell.reuseIdentifier, for: indexPath) as! ActivityCell
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        cell.titleLabel.text = dataForTableView
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension NoRegularActivityViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        updateCategory(category)
    }
}

extension NoRegularActivityViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, !text.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .black
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
