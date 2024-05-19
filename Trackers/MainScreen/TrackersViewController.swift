import UIKit

protocol TrackersViewControllerDelegate: AnyObject {
    func createdTracker(tracker: Tracker, categoryTitle: String)
}

final class TrackersViewController: UIViewController, UICollectionViewDelegate {
    
    private var mainLabel: UILabel!
    private var starImageView: UIImageView!
    private var whatsUpLabel: UILabel!
    private var searchBar: UISearchController!
    private var collectionView: UICollectionView!
    private var noResultImageView: UIImageView!
    private var noResultLabel: UILabel!
    private var datePicker: UIDatePicker!
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        currentDate = Date()
        filterVisibleCategories(for: currentDate)
        emptyCollectionView()
        emptySearchCollectionView()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        tapGesture()
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.searchBar.delegate = self
    }
    
    @objc private func dateChanged(_ picker: UIDatePicker) {
        currentDate = datePicker.date
        filterVisibleCategories(for: currentDate)
        if let datePickerContainerView = view.subviews.first(where: { String(describing: type(of: $0)).contains("UIDatePicker") }) {
            datePickerContainerView.subviews.forEach { subview in
                if let button = subview as? UIButton {
                    button.sendActions(for: .touchUpInside)
                }
            }
        }
    }
    
    @objc private func plusButtonDidTap() {
        let addNewTrackerViewController = AddNewTrackerViewController()
        addNewTrackerViewController.delegate = self
        let addNewTrackerNavigationController = UINavigationController(rootViewController: addNewTrackerViewController)
        present(addNewTrackerNavigationController, animated: true)
    }
    
    @objc private func searchTrackers(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            filterVisibleCategories(for: currentDate)
            return
        }
        
        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.name.localizedCaseInsensitiveContains(searchText) &&
                tracker.timeTable.contains(WeekDay(rawValue: Calendar.current.component(.weekday, from: currentDate)) ?? .monday)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        if visibleCategories.isEmpty {
            showNoResultImage()
            hideStarImage()
        } else {
            hideNoResultImage()
            hideStarImage()
        }
        collectionView.reloadData()
    }
    
    @objc private func textFieldCleared(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty ?? true {
            filterVisibleCategories(for: currentDate)
            if visibleCategories.isEmpty {
                showStarImage()
            } else {
                hideStarImage()
            }
            hideNoResultImage()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        setupMainLabel()
        setupSearchBar()
        setupCollectionView()
        setupStarImageView()
        setupWhatsUpLabel()
        setupDatePicker()
        setupNavigationBar()
        setupNoResultImageView()
        setupNoResultLabel()
    }
    
    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.widthAnchor.constraint(equalToConstant: 120).isActive = true
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    private func tapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupNavigationBar() {
        guard let navigatorBar = navigationController?.navigationBar else { return }
        navigationItem.hidesSearchBarWhenScrolling = false
        navigatorBar.prefersLargeTitles = true
        let plusImage = UIImage(named: "plus")
        let plusButton = UIBarButtonItem(
            image: plusImage,
            style: .plain,
            target: self,
            action: #selector(plusButtonDidTap))
        plusButton.tintColor = .black
        navigationItem.searchController = searchBar
        
        navigationItem.leftBarButtonItem = plusButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        searchBar.searchBar.delegate = self
    }
    
    private func setupSearchBar() {
        searchBar = UISearchController(searchResultsController: nil)
        searchBar.hidesNavigationBarDuringPresentation = false
        searchBar.searchBar.placeholder = "Поиск"
        searchBar.searchBar.searchTextField.clearButtonMode = .never
        searchBar.searchBar.setValue("Отмена", forKey: "cancelButtonText")
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(TrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerSupplementaryView.reuseIdentifier)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupWhatsUpLabel() {
        whatsUpLabel = UILabel()
        whatsUpLabel.text = "Что будем отслеживать?"
        whatsUpLabel.textAlignment = .center
        whatsUpLabel.textColor = .black
        whatsUpLabel.font = .systemFont(ofSize: 12)
        whatsUpLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(whatsUpLabel)
        
        NSLayoutConstraint.activate([
            whatsUpLabel.widthAnchor.constraint(equalToConstant: 343),
            whatsUpLabel.heightAnchor.constraint(equalToConstant: 18),
            whatsUpLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            whatsUpLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            whatsUpLabel.topAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupStarImageView() {
        starImageView = UIImageView()
        starImageView.image = UIImage(named: "Star")
        starImageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        starImageView.center = view.center
        view.addSubview(starImageView)
    }
    
    private func setupMainLabel() {
        mainLabel = UILabel()
        mainLabel.text = "Трекеры"
        mainLabel.textColor = .black
        mainLabel.font = .boldSystemFont(ofSize: 34)
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainLabel)
        
        NSLayoutConstraint.activate([
            mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            mainLabel.widthAnchor.constraint(equalToConstant: 254),
            mainLabel.heightAnchor.constraint(equalToConstant: 41)
        ])
    }
    
    private func setupNoResultImageView() {
        noResultImageView = UIImageView()
        noResultImageView.translatesAutoresizingMaskIntoConstraints = false
        noResultImageView.image = UIImage(named: "noResult")
        view.addSubview(noResultImageView)
        
        NSLayoutConstraint.activate([
            noResultImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noResultImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultImageView.widthAnchor.constraint(equalToConstant: 80),
            noResultImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupNoResultLabel() {
        noResultLabel = UILabel()
        noResultLabel.translatesAutoresizingMaskIntoConstraints = false
        noResultLabel.text = "Ничего не найдено"
        noResultLabel.font = .systemFont(ofSize: 12)
        noResultLabel.textColor = .black
        view.addSubview(noResultLabel)
        
        NSLayoutConstraint.activate([
            noResultLabel.topAnchor.constraint(equalTo: noResultImageView.bottomAnchor, constant: 8),
            noResultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func showStarImage() {
        starImageView.isHidden = false
        whatsUpLabel.isHidden = false
    }
    
    private func hideStarImage() {
        starImageView.isHidden = true
        whatsUpLabel.isHidden = true
    }
    
    private func showNoResultImage() {
        noResultImageView.isHidden = false
        noResultLabel.isHidden = false
    }
    
    private func hideNoResultImage() {
        noResultImageView.isHidden = true
        noResultLabel.isHidden = true
    }
    
    private func isMatchingRecord(model: TrackerRecord, with trackerId: UUID) -> Bool {
        return model.id == trackerId && Calendar.current.isDate(model.date, inSameDayAs: currentDate)
    }
    
    private func emptyCollectionView() {
        if visibleCategories.isEmpty && (searchBar.searchBar.text?.isEmpty ?? true) {
            showStarImage()
            hideNoResultImage()
        } else {
            hideStarImage()
        }
    }
    
    private func emptySearchCollectionView() {
        if visibleCategories.isEmpty && !(searchBar.searchBar.text?.isEmpty ?? true) {
            showNoResultImage()
            hideStarImage()
        } else {
            hideNoResultImage()
        }
    }
    
    private func filterVisibleCategories(for selectedDate: Date) {
        let selectedWeekday = Calendar.current.component(.weekday, from: selectedDate)
        visibleCategories = categories.filter { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.timeTable.contains(WeekDay(rawValue: selectedWeekday) ?? .monday)
            }
            return !filteredTrackers.isEmpty
        }
        if visibleCategories.isEmpty {
            showStarImage()
        } else {
            hideStarImage()
        }
        collectionView.reloadData()
        emptyCollectionView()
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories.isEmpty ? 0 : visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier, for: indexPath) as! TrackersCollectionViewCell
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isCompleted = completedTrackers.contains {
            isMatchingRecord(model: $0, with: tracker.id)
        }
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        
        cell.delegate = self
        cell.setupUI(with: tracker, isCompletedToday: isCompleted, completedDays: completedDays, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerSupplementaryView.reuseIdentifier, for: indexPath) as! TrackerSupplementaryView
        view.setupTrackerSupplementaryView(text: visibleCategories.isEmpty ? "" : visibleCategories[indexPath.section].title)
        return view
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 148
        let interItemSpacing: CGFloat = 10
        let width = (collectionView.bounds.width - interItemSpacing) / 2
        return CGSize(width: width, height: height)
    }
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func completeTracker(id: UUID) {
        guard currentDate <= Date() else {
            return
        }
        completedTrackers.append(TrackerRecord(id: id, date: currentDate))
        collectionView.reloadData()
    }
    
    func noCompleteTracker(id: UUID) {
        completedTrackers.removeAll { element in
            if (element.id == id &&  Calendar.current.isDate(element.date, equalTo: currentDate, toGranularity: .day)) {
                return true
            } else {
                return false
            }
        }
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackersViewControllerDelegate {
    func createdTracker(tracker: Tracker, categoryTitle: String) {
        categories.append(TrackerCategory(title: categoryTitle, trackers: [tracker]))
        updateVisibleCategories()
        collectionView.reloadData()
        if visibleCategories.isEmpty {
            showStarImage()
        } else {
            hideStarImage()
        }
    }
    
    private func updateVisibleCategories() {
        let selectedWeekday = Calendar.current.component(.weekday, from: currentDate)
        visibleCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.timeTable.contains(WeekDay(rawValue: selectedWeekday) ?? .monday)
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTrackers(searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        textFieldCleared(searchBar)
    }
}
