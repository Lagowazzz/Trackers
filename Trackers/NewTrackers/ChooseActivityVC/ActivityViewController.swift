import UIKit

protocol ActivityViewControllerDelegate: AnyObject {
    func createTracker(tracker: Tracker, categoryTitle: String)
    func cancelCreateTracker()
}

final class ActivityViewController: UIViewController {
    
    enum ActivityType {
        case regular
        case nonRegular
    }
    
    weak var delegate: ActivityViewControllerDelegate?
    
    private var weekTableViewController: WeekTableViewController?
    
    private let cellsTableView = [NSLocalizedString("categoryMain.title", comment: ""), NSLocalizedString("schedule.title", comment: "")]
    private var selectedWeekTable: [WeekDay] = []
    private var selectedCategory = String()
    private var activityType: ActivityType
    private var selectedColor: UIColor?
    private var selectedEmoji: String?
    private var selectedColorIndex: Int?
    private var selectedEmojiIndex: Int?
    
    private var emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    private var colors: [UIColor] = [
        .color1, .color2, .color3,
        .color4, .color5, .color6,
        .color7, .color8, .color9,
        .color10, .color11, .color12,
        .color13, .color14, .color15,
        .color16, .color17, .color18
    ]
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .spGray
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.setupLeftPadding(16)
        textField.placeholder = NSLocalizedString("getNameToTracker.title", comment: "")
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
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .lightGray
        tableView.tableHeaderView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
        cancelButton.backgroundColor = .spWhite
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.setTitle(NSLocalizedString("cancelButton.title", comment: ""), for: .normal)
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
        createButton.backgroundColor = .spBlack
        createButton.layer.cornerRadius = 16
        createButton.layer.masksToBounds = true
        createButton.setTitle(NSLocalizedString("createButton.title", comment: ""), for: .normal)
        createButton.setTitleColor(.spWhite, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return createButton
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private let colorsAndEmojisCollectionView: UICollectionView = {
        let colorsAndEmojisCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        colorsAndEmojisCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorsAndEmojisCollectionView.backgroundColor = .spWhite
        colorsAndEmojisCollectionView.isScrollEnabled = false
        colorsAndEmojisCollectionView.register(
            ColorsAndEmojisCells.self,
            forCellWithReuseIdentifier: ColorsAndEmojisCells.reuseIdentifier
        )
        colorsAndEmojisCollectionView.register(
            ColorsAndEmojisSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ColorsAndEmojisSupplementaryView.reuseIdentifier
        )
        return colorsAndEmojisCollectionView
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
        view.backgroundColor = .spWhite
        setupNavBar()
        setupConstraints()
        createButton.isEnabled = false
        createButton.backgroundColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
        
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        if activityType == .nonRegular {
                   tableView.separatorStyle = .none
               } else {
                   tableView.separatorStyle = .singleLine
               }
        
        colorsAndEmojisCollectionView.dataSource = self
        colorsAndEmojisCollectionView.delegate = self
        
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
                color: selectedColor ?? .spBlack,
                emoji: selectedEmoji ?? "🤷‍♂️",
                timeTable: selectedWeekTable,
                isIrregular: true,
                isPinned: false
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
                color: selectedColor ?? .spBlack,
                emoji: selectedEmoji ?? "🤷‍♂️",
                timeTable: weekDayArray,
                isIrregular: false,
                isPinned: false
            )
        }
        
        delegate?.createTracker(tracker: newTracker, categoryTitle: selectedCategory)
        dismiss(animated: true)
        delegate?.cancelCreateTracker()
    }
    
    private func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(textField)
        contentView.addSubview(tableView)
        contentView.addSubview(stackView)
        contentView.addSubview(colorsAndEmojisCollectionView)
        
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: activityType == .regular ? 150 : 75),
            
            colorsAndEmojisCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            colorsAndEmojisCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorsAndEmojisCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorsAndEmojisCollectionView.heightAnchor.constraint(equalToConstant: 460),
            
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: colorsAndEmojisCollectionView.bottomAnchor, constant: 32),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupNavBar() {
        navigationItem.title = activityType == .regular ? NSLocalizedString("newHabit.title", comment: "") : NSLocalizedString("newIrregularEvent.title", comment: "")
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
        
        createButton.backgroundColor = createButton.isEnabled ? .spBlack : UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
    }
}

extension ActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let categoryViewController = CategoryViewController()
            categoryViewController.delegate = self
            navigationController?.pushViewController(categoryViewController, animated: true)
        } else
        if indexPath.row == 1 && activityType == .regular {
            weekTableViewController = WeekTableViewController()
            weekTableViewController?.delegate = self
            navigationController?.pushViewController(weekTableViewController ?? WeekTableViewController(), animated: true)
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
        cell.backgroundColor = .spGray
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: .zero, right: 16)
            cell.titleLabel.text = cellsTableView[indexPath.row]
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: .zero, right: .greatestFiniteMagnitude)
            cell.titleLabel.text = cellsTableView[indexPath.row]
        }
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

extension ActivityViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return emojis.count
        } else if section == 1 {
            return colors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsAndEmojisCells.reuseIdentifier, for: indexPath) as? ColorsAndEmojisCells else {
            return UICollectionViewCell()
        }
        
        if indexPath.section == 0 {
            let emoji = emojis[indexPath.row]
            cell.colorAndEmojiLabel.text = emoji
        } else if indexPath.section == 1 {
            let color = colors[indexPath.row]
            cell.colorAndEmojiLabel.backgroundColor = color
        }
        
        cell.colorAndEmojiLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ColorsAndEmojisSupplementaryView.reuseIdentifier,
            for: indexPath
        ) as? ColorsAndEmojisSupplementaryView else {
            return UICollectionReusableView()
        }
        
        if indexPath.section == 0 {
            view.colorAndEmojiLabel.text = "Emoji"
        } else if indexPath.section == 1 {
            view.colorAndEmojiLabel.text = NSLocalizedString("color.title", comment: "")
        }
        return view
    }
}

extension ActivityViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 40, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                                             at: indexPath)
        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let selectedEmojiIndex = selectedEmojiIndex {
                let previousSelectedIndexPath = IndexPath(item: selectedEmojiIndex, section: 0)
                if let cell = collectionView.cellForItem(at: previousSelectedIndexPath) as? ColorsAndEmojisCells {
                    cell.backgroundColor = .clear
                }
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorsAndEmojisCells {
                cell.layer.cornerRadius = 16
                cell.layer.masksToBounds = true
                cell.backgroundColor = .spGray
                selectedEmoji = emojis[indexPath.row]
                selectedEmojiIndex = indexPath.row
            }
        } else if indexPath.section == 1 {
            if let selectedColorIndex = selectedColorIndex {
                let previousSelectedIndexPath = IndexPath(item: selectedColorIndex, section: 1)
                if let cell = collectionView.cellForItem(at: previousSelectedIndexPath) as? ColorsAndEmojisCells {
                    cell.layer.borderColor = UIColor.clear.cgColor
                    cell.layer.borderWidth = 0
                }
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorsAndEmojisCells {
                cell.layer.cornerRadius = 8
                cell.layer.masksToBounds = true
                cell.layer.borderColor = colors[indexPath.row].cgColor.copy(alpha: 0.3)
                cell.layer.borderWidth = 3
                selectedColor = colors[indexPath.row]
                selectedColorIndex = indexPath.row
            }
        }
    }
}
