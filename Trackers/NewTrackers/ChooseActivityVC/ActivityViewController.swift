import UIKit

protocol ActivityViewControllerDelegate: AnyObject {
    func createTracker(tracker: Tracker, categoryTitle: String?)
    func cancelCreateTracker()
}

final class ActivityViewController: UIViewController {
    
    enum ActivityType {
        case regular
        case nonRegular
    }
    
    weak var delegate: ActivityViewControllerDelegate?
    
    private var weekTableViewController: WeekTableViewController?
    
    private let cellsTableView = ["Категория", "Расписание"]
    private var selectedWeekTable: [WeekDay] = []
    private var selectedCategory = String()
    private var activityType: ActivityType
    
    private let textField: UITextField = {
        let textField = UITextField()
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
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
        tableView.register(ActivityCell.self, forCellReuseIdentifier: ActivityCell.reuseIdentifier)
        return tableView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
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
        return cancelButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton()
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.backgroundColor = .black
        createButton.layer.cornerRadius = 16
        createButton.layer.masksToBounds = true
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return createButton
    }()
    
    init(activityType: ActivityType) {
        self.activityType = activityType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupNavBar()
        setupConstraints()
        createButton.isEnabled = false
        createButton.backgroundColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
        
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        setupCreateButtonState()
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
        delegate?.cancelCreateTracker()
    }
    
    @objc private func didTapCreateButton() {
        guard let trackerName = textField.text, !trackerName.isEmpty else { return }
        let newTracker: Tracker
        
        switch activityType {
        case .regular:
            newTracker = Tracker(
                id: UUID(),
                name: trackerName,
                color: .red,
                emoji: "🍕",
                timeTable: selectedWeekTable
            )
        case .nonRegular:
            let currentDate = Date()
            let currentWeekday = Calendar.current.component(.weekday, from: currentDate)
            let newWeekTable = WeekTable(value: WeekDay(rawValue: currentWeekday) ?? .sunday, isActive: true)
            let weekTableArray = [newWeekTable]
            let weekDayArray = weekTableArray.map { $0.value }
            newTracker = Tracker(
                id: UUID(),
                name: trackerName,
                color: .green,
                emoji: "😎",
                timeTable: weekDayArray
            )
        }
        
        delegate?.createTracker(tracker: newTracker, categoryTitle: selectedCategory.isEmpty ? "" : selectedCategory)
        dismiss(animated: true)
    }
    
    private func setupConstraints() {
        
        view.addSubview(textField)
        view.addSubview(tableView)
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: activityType == .regular ? 150 : 75),
            
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupNavBar() {
        navigationItem.title = activityType == .regular ? "Новая привычка" : "Новое нерегулярное событие"
    }
    
    private func setupSubTitle(_ subTitle: String?, forCellAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ActivityCell else {
            return
        }
        
        if let subTitle = subTitle {
            cell.setupText(subText: subTitle)
        } else {
            let weekDayTitles = selectedWeekTable.map { $0.abb }.joined(separator: ", ")
            cell.setupText(subText: weekDayTitles)
        }
    }
    
    private func updateCategory(_ category: String) {
        selectedCategory = category
        setupCategoryTitle(selectedCategory)
        setupCreateButtonState()
    }
    
    private func setupCategoryTitle(_ category: String) {
        setupSubTitle(category, forCellAt: IndexPath(row: 0, section: 0))
    }
    
    private func setupCreateButtonState() {
        let isTrackerNameEntered = !(textField.text?.isEmpty ?? true)
        
        if activityType == .nonRegular {
            createButton.isEnabled = isTrackerNameEntered
        } else {
            let isWeekTableSelected = !selectedWeekTable.isEmpty
            createButton.isEnabled = isTrackerNameEntered && isWeekTableSelected
        }
        
        createButton.backgroundColor = createButton.isEnabled ? .black : UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
    }
}

extension ActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let categoryViewController = CategoryViewController()
            categoryViewController.delegate = self
            navigationController?.pushViewController(categoryViewController, animated: true)
        } else if indexPath.row == 1 && activityType == .regular {
            weekTableViewController = WeekTableViewController()
            weekTableViewController?.delegate = self
            navigationController?.pushViewController(weekTableViewController!, animated: true)
        }
    }
}

extension ActivityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityType == .regular ? cellsTableView.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCell.reuseIdentifier, for: indexPath) as? ActivityCell else {
            return UITableViewCell()
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        cell.titleLabel.text = cellsTableView[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension ActivityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in: text) else {
            return true
        }
        let updatedText = text.replacingCharacters(in: textRange, with: string)
        
        let minLength = 1
        let maxLength = 38
        let isInRange = updatedText.count >= minLength && updatedText.count <= maxLength
        
        setupCreateButtonState()
        
        return isInRange
    }
}

extension ActivityViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        updateCategory(category)
    }
}

extension ActivityViewController: WeekTableViewControllerDelegate {
    func updateWeekTable(selectedDays: [WeekDay]) {
        selectedWeekTable = selectedDays
        let weekDayAbbreviations = selectedWeekTable.map { $0.abb }.joined(separator: ", ")
        setupSubTitle(weekDayAbbreviations, forCellAt: IndexPath(row: 1, section: 0))
        setupCreateButtonState()
    }
}

