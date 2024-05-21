import UIKit

final class RegularActivityViewController: UIViewController {
    
    weak var delegate: AddNewTrackerViewControllerDelegate?
    private var weekTableViewController: WeekTableViewController?
    
    private let cellsTableView = ["Категория", "Расписание"]
    private var selectedWeekTable: [WeekDay] = []
    private var selectedCategory = String()
    
    private let trackerName: UITextField = {
        let trackerName = UITextField()
        trackerName.translatesAutoresizingMaskIntoConstraints = false
        trackerName.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        trackerName.layer.cornerRadius = 16
        trackerName.layer.masksToBounds = true
        trackerName.font = UIFont.systemFont(ofSize: 17)
        trackerName.setupLeftPadding(16)
        trackerName.placeholder = "Введите название трекера"
        trackerName.clearButtonMode = .whileEditing
        trackerName.returnKeyType = .done
        trackerName.enablesReturnKeyAutomatically = true
        trackerName.smartInsertDeleteType = .no
        return trackerName
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
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
        cancelButton.setTitleColor(UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1), for: .normal)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        return cancelButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton()
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.backgroundColor = .black
        createButton.setTitleColor(.white, for: .normal)
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.layer.cornerRadius = 16
        createButton.layer.masksToBounds = true
        createButton.addTarget(self, action: #selector(createButtonDidTap), for: .touchUpInside)
        return createButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
        setupNavBar()
        createButton.isEnabled = false
        createButton.backgroundColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
        trackerName.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc private func cancelButtonDidTap() {
        dismiss(animated: true)
        delegate?.cancelCreateTracker()
    }
    
    @objc private func createButtonDidTap() {
        guard let trackerName = trackerName.text else { return }
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: .red,
            emoji: "🍕",
            timeTable: selectedWeekTable)
        delegate?.createTracker(tracker: newTracker, categoryTitle: selectedCategory)
        dismiss(animated: true)
    }
    
    private func setupConstraints() {
        view.addSubview(trackerName)
        view.addSubview(tableView)
        view.addSubview(stackView)
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        
        NSLayoutConstraint.activate([
            trackerName.heightAnchor.constraint(equalToConstant: 75),
            trackerName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            tableView.heightAnchor.constraint(equalToConstant: 150),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: trackerName.bottomAnchor, constant: 24),
            
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupNavBar() {
        navigationItem.title = "Новая привычка"
    }
    
    private func setupSubTitle(_ subTitle: String?, forCellAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ActivityCell else {
            return
        }
        cell.setupText(subText: subTitle)
    }
    
    private func createWeekTable(weekTable: [WeekDay]) {
        self.selectedWeekTable = weekTable
        let subText = selectedWeekTable.map { $0.abb }.joined(separator: ", ")
        setupSubTitle(subText, forCellAt: IndexPath(row: 1, section: 0))
        tableView.reloadData()
    }
    
    private func didSelectDays(_ days: [WeekDay]) {
        let abbreviatedDays = days.map { $0.abb }.joined(separator: ", ")
        if let weekDayCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ActivityCell {
            weekDayCell.setupText(subText: abbreviatedDays)
        }
    }
    
    private func updateCategory(_ category: String) {
        selectedCategory = category
        setCategoryTitle(selectedCategory)
    }
    
    private func setCategoryTitle(_ category: String) {
        setupSubTitle(category, forCellAt: IndexPath(row: 0, section: 0))
    }
    
    private func updateCreateButtonActivation() {
        let isWeekTableSelected = !selectedWeekTable.isEmpty
        let isTrackerNameEntered = !(trackerName.text ?? "").isEmpty
        createButton.isEnabled = isWeekTableSelected && isTrackerNameEntered
        createButton.backgroundColor = isWeekTableSelected && isTrackerNameEntered ? .black : UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
    }
}

extension RegularActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let categoryViewController = CategoryViewController()
            categoryViewController.delegate = self
            navigationController?.pushViewController(categoryViewController, animated: true)
        } else if indexPath.row == 1 {
            weekTableViewController = WeekTableViewController()
            weekTableViewController?.delegate = self
            navigationController?.pushViewController(weekTableViewController!, animated: true)
        }
    }
}

extension RegularActivityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellsTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCell.reuseIdentifier, for: indexPath)
        
        guard let activityCell = cell as? ActivityCell else {
            return UITableViewCell()
        }
        
        activityCell.accessoryType = .disclosureIndicator
        activityCell.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        
        if indexPath.row == 0 {
            activityCell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            activityCell.titleLabel.text = cellsTableView[indexPath.row]
        } else {
            activityCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            activityCell.titleLabel.text = cellsTableView[indexPath.row]
        }
        
        return activityCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension RegularActivityViewController: WeekTableViewControllerDelegate {
    
    func updateWeekTable(_ selectedDays: [WeekDay]) {
        let abbreviatedDays = selectedDays.map { $0.abb }.joined(separator: ", ")
        createWeekTable(weekTable: selectedDays)
        setupSubTitle(abbreviatedDays, forCellAt: IndexPath(row: 1, section: 0))
        updateCreateButtonActivation()
        tableView.reloadData()
    }
}

extension RegularActivityViewController: CategoryViewControllerDelegate {
    
    func didSelectCategory(_ category: String) {
        updateCategory(category)
        updateCreateButtonActivation()
    }
}

extension RegularActivityViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
