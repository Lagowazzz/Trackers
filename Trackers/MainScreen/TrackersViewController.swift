import UIKit

protocol TrackersViewControllerDelegate: AnyObject {
    func createdTracker(tracker: Tracker, categoryTitle: String)
}

final class TrackersViewController: UIViewController, UICollectionViewDelegate, AddNewTrackerViewControllerDelegate {
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = .init()
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private var currentFilter: String?
    private let analyticsService = AnalyticsService()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = .current
        datePicker.widthAnchor.constraint(equalToConstant: 120).isActive = true
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private let emptyView: UIView = {
        let emptyView = UIView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        return emptyView
    }()
    
    private let searchBar: UISearchController = {
        let searchBar = UISearchController(searchResultsController: nil)
        searchBar.hidesNavigationBarDuringPresentation = false
        searchBar.searchBar.placeholder = NSLocalizedString("searchBarPlaceholder.title", comment: "")
        searchBar.searchBar.searchTextField.clearButtonMode = .never
        searchBar.searchBar.setValue(NSLocalizedString("searchBarCancelButton.title", comment: ""), forKey: "cancelButtonText")
        return searchBar
    }()
    
    private let starImageView: UIImageView = {
        let starImageView = UIImageView()
        starImageView.image = UIImage(named: "Star")
        starImageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        return starImageView
    }()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.backgroundColor = .spWhite
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(TrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerSupplementaryView.reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 66, right: 0)
        return collectionView
    }()
    
    private let whatsUpLabel: UILabel = {
        let whatsUpLabel = UILabel()
        whatsUpLabel.text = NSLocalizedString("whatsUp.title", comment: "")
        whatsUpLabel.textAlignment = .center
        whatsUpLabel.textColor = .spBlack
        whatsUpLabel.font = .systemFont(ofSize: 12)
        whatsUpLabel.translatesAutoresizingMaskIntoConstraints = false
        return whatsUpLabel
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .color3
        button.setTitle(NSLocalizedString("filters.title", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(pushFiltersButton), for: .touchUpInside)
        return button
    }()
    
    private let noResultImageView: UIImageView = {
        let noResultImageView = UIImageView()
        noResultImageView.translatesAutoresizingMaskIntoConstraints = false
        noResultImageView.image = UIImage(named: "noResult")
        return noResultImageView
    }()
    
    private let noResultLabel: UILabel = {
        let noResultLabel = UILabel()
        noResultLabel.translatesAutoresizingMaskIntoConstraints = false
        noResultLabel.text = NSLocalizedString("noResult.title", comment: "")
        noResultLabel.font = .systemFont(ofSize: 12)
        noResultLabel.textColor = .spBlack
        return noResultLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .spWhite
        edgesForExtendedLayout = .all
        
        filtersButton.isHidden = true
        setupNavigationBar()
        setupConstraints()
        currentDate = Date()
        filterVisibleCategories(for: currentDate)
        emptyCollectionView()
        emptySearchCollectionView()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        tapGesture()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .always
        searchBar.searchBar.delegate = self
        loadAndFilterData()
        trackerStore.setupDelegate(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
             super.viewDidAppear(animated)
             analyticsService.reportEvent(event: "Opened TrackersViewController", parameters: ["event": "open", "screen": "Main"])
         }

         override func viewDidDisappear(_ animated: Bool) {
             super.viewDidDisappear(animated)
             analyticsService.reportEvent(event: "Closed TrackersViewController", parameters: ["event": "close", "screen": "Main"])
         }
    
    @objc private func dateChanged(_ picker: UIDatePicker) {
        analyticsService.reportEvent(event: "Date picker date changed on TrackersViewController", parameters: ["event": "change", "screen": "Main", "item": "date_changed"])
        currentDate = picker.date
        filterVisibleCategories(for: currentDate)
    }
    
    @objc private func pushFiltersButton() {
        analyticsService.reportEvent(event: "Did press the filters button on TrackersViewController", parameters: ["event": "click", "screen": "Main", "item": "filter"])
        let viewController = FilterViewController()
        viewController.delegate = self
        if let currentFilter = currentFilter {
            if currentFilter == NSLocalizedString("Completed", comment: "") || currentFilter == NSLocalizedString("Not completed", comment: "") {
                viewController.currentFilter = currentFilter
            }
        }
        self.present(viewController, animated: true)
    }
    
    @objc private func plusButtonDidTap() {
        analyticsService.reportEvent(event: "Add tracker button tapped on TrackersViewController", parameters: ["event": "click", "screen": "Main", "item": "add_track"])
        let addNewTrackerViewController = AddNewTrackerViewController()
        addNewTrackerViewController.delegate = self
        let addNewTrackerNavigationController = UINavigationController(rootViewController: addNewTrackerViewController)
        present(addNewTrackerNavigationController, animated: true)
    }
    
    @objc private func searchTrackers(_ searchBar: UISearchBar) {
        analyticsService.reportEvent(event: "Attempted searching for trackers on TrackersViewController", parameters: ["event": "search", "screen": "Main"])
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
            noResultImageVisibility(true)
            starImageVisibility(false)
        } else {
            noResultImageVisibility(false)
            starImageVisibility(false)
        }
        collectionView.reloadData()
    }
    
    @objc private func textFieldCleared(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty ?? true {
            filterVisibleCategories(for: currentDate)
            if visibleCategories.isEmpty {
                starImageVisibility(true)
            } else {
                starImageVisibility(false)
            }
            noResultImageVisibility(false)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupConstraints() {
        view.addSubview(emptyView)
        view.addSubview(collectionView)
        starImageView.center = view.center
        view.addSubview(whatsUpLabel)
        view.addSubview(starImageView)
        view.addSubview(noResultImageView)
        view.addSubview(noResultLabel)
        view.addSubview(filtersButton)
        
        NSLayoutConstraint.activate([
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -67),
            
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.heightAnchor.constraint(equalToConstant: 0),
            emptyView.widthAnchor.constraint(equalToConstant: 0),
            
            whatsUpLabel.widthAnchor.constraint(equalToConstant: 343),
            whatsUpLabel.heightAnchor.constraint(equalToConstant: 18),
            whatsUpLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            whatsUpLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            whatsUpLabel.topAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: 8),
            
            noResultImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noResultImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultImageView.widthAnchor.constraint(equalToConstant: 80),
            noResultImageView.heightAnchor.constraint(equalToConstant: 80),
            
            noResultLabel.topAnchor.constraint(equalTo: noResultImageView.bottomAnchor, constant: 8),
            noResultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
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
        plusButton.tintColor = .spBlack
        navigationItem.searchController = searchBar
        navigationItem.title = NSLocalizedString("tabBarTrackers.title", comment: "")
        navigationItem.leftBarButtonItem = plusButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        searchBar.searchBar.delegate = self
    }
    
    private func starImageVisibility(_ isVisible: Bool) {
        starImageView.isHidden = !isVisible
        whatsUpLabel.isHidden = !isVisible
        collectionView.isHidden = isVisible
    }
    
    private func noResultImageVisibility(_ isVisible: Bool) {
        noResultImageView.isHidden = !isVisible
        noResultLabel.isHidden = !isVisible
        collectionView.isHidden = isVisible
    }
    
    private func isMatchingRecord(model: TrackerRecord, with trackerId: UUID) -> Bool {
        return model.id == trackerId && Calendar.current.isDate(model.date, inSameDayAs: currentDate)
    }
    
    private func emptyCollectionView() {
        if visibleCategories.isEmpty && (searchBar.searchBar.text?.isEmpty ?? true) {
            starImageVisibility(true)
            noResultImageVisibility(false)
            filtersButton.isHidden = true
        } else {
            starImageVisibility(false)
            filtersButton.isHidden = false
        }
    }
    
    private func emptySearchCollectionView() {
        if visibleCategories.isEmpty && !(searchBar.searchBar.text?.isEmpty ?? true) {
            noResultImageVisibility(true)
            starImageVisibility(false)
        } else {
            noResultImageVisibility(false)
        }
    }
    
    private func filterVisibleCategories(for selectedDate: Date) {
        let selectedWeekday = Calendar.current.component(.weekday, from: selectedDate)
        
        var newVisibleCategories: [TrackerCategory] = []
        var pinnedTrackers: [Tracker] = []
        
        for category in categories {
            var filteredTrackers: [Tracker] = []
            for tracker in category.trackers {
                if tracker.isPinned {
                    pinnedTrackers.append(tracker)
                } else if tracker.isIrregular && Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                    filteredTrackers.append(tracker)
                } else if tracker.timeTable.contains(WeekDay(rawValue: selectedWeekday) ?? .monday) {
                    filteredTrackers.append(tracker)
                }
            }
            
            if !filteredTrackers.isEmpty {
                newVisibleCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
            }
        }
        
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(title: NSLocalizedString("pinned.title", comment: ""), trackers: pinnedTrackers)
            newVisibleCategories.insert(pinnedCategory, at: 0)
        }
        
        visibleCategories = newVisibleCategories
        
        collectionView.reloadData()
        emptyCollectionView()
    }
    
    private func loadAndFilterData() {
        trackerCategoryStore.getCategories { [weak self] categories in
            self?.categories = categories
            self?.filterVisibleCategories(for: self?.currentDate ?? Date())
        }
    }
    
    private func fetchRecords(for tracker: Tracker) -> [TrackerRecord] {
        do {
            return try trackerRecordStore.recordsFetch(for: tracker)
        } catch {
            assertionFailure("Failed to get records for tracker")
            return []
        }
    }
    
    private func filterTrackersByCompletion(_ categories: [TrackerCategory], completed: Bool) -> [TrackerCategory] {
        var filteredCategories: [TrackerCategory] = []
        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                let trackerRecords = fetchRecords(for: tracker)
                let isCompleted = trackerRecords.contains { record in
                    return Calendar.current.isDate(record.date, inSameDayAs: currentDate)
                }
                return isCompleted == completed
            }
            if !filteredTrackers.isEmpty {
                filteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
            }
        }
        return filteredCategories
    }
    
    private func filterCompletedTrackers(_ categories: [TrackerCategory]) -> [TrackerCategory] {
        return filterTrackersByCompletion(categories, completed: true)
    }
    
    private func filterNotCompletedTrackers(_ categories: [TrackerCategory]) -> [TrackerCategory] {
        return filterTrackersByCompletion(categories, completed: false)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackersCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isCompleted = completedToday(trackerID: tracker.id, tracker: tracker)
        let completedDays = fetchRecords(for: tracker).count
        
        cell.delegate = self
        cell.setupUI(with: tracker, isCompletedToday: isCompleted, completedDays: completedDays, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerSupplementaryView.reuseIdentifier,
            for: indexPath
        ) as? TrackerSupplementaryView else {
            return UICollectionReusableView()
        }
        
        let title = visibleCategories.isEmpty ? "" : visibleCategories[indexPath.section].title
        view.setupTrackerSupplementaryView(text: title)
        return view
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = TrackerSupplementaryView(frame: .zero)
        let indexPath = IndexPath(item: 0, section: section)
        headerView.titleLabel.text = "Заголовок для секции \(indexPath.section + 1)"
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
    
    func deleteTracker(tracker: Tracker) {
        analyticsService.reportEvent(event: "Selected delete option in tracker's context menu", parameters: ["event": "click", "screen": "Main", "item": "delete"])
        let actionList: UIAlertController = {
            let alert = UIAlertController()
            alert.title = NSLocalizedString("deleteAlert.title", comment: "")
            return alert
        }()
        
        let delete = UIAlertAction(title: NSLocalizedString("deleteAlertAction.title", comment: ""), style: .destructive) { [weak self] _ in
            do {
                try self?.trackerStore.deleteTracker(tracker)
                self?.loadAndFilterData()
                self?.collectionView.reloadData()
            } catch {
                assertionFailure("Failed to delete tracker")
            }
        }
        let cancel = UIAlertAction(title: NSLocalizedString("deleteAlertCancel.title", comment: ""), style: .cancel)
        
        actionList.addAction(delete)
        actionList.addAction(cancel)
        
        present(actionList, animated: true)
    }
    
    func completeTracker(id: UUID) {
        analyticsService.reportEvent(event: "Marked tracker completed on TrackersViewController", parameters: ["event": "click", "screen": "Main", "item": "track"])
        guard currentDate <= Date() else {
            return
        }
        let trackerRecord = TrackerRecord(id: id, date: selectedDate())
        try? trackerRecordStore.addRecord(with: trackerRecord.id, by: trackerRecord.date)
        collectionView.reloadData()
        loadAndFilterData()
    }
    
    func noCompleteTracker(id: UUID) {
        analyticsService.reportEvent(event: "Marked tracker not completed on TrackersViewController", parameters: ["event": "click", "screen": "Main", "item": "un_track"])
        let trackerRecord = TrackerRecord(id: id, date: selectedDate())
        try? trackerRecordStore.deleteRecord(with: trackerRecord.id, by: trackerRecord.date)
        collectionView.reloadData()
        loadAndFilterData()
    }
    
    func completedToday(trackerID: UUID, tracker: Tracker) -> Bool {
        let currentDate = datePicker.date
        do {
            let records = try trackerRecordStore.recordsFetch(for: tracker)
            return records.contains { record in
                record.id == trackerID && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
            }
        } catch {
            assertionFailure("Failed to fetch records for tracker")
            return false
        }
    }
    
    func selectedDate() -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: datePicker.date)
        guard let selectedDate = calendar.date(from: dateComponents) else { return Date() }
        return selectedDate
    }
    
    func pinTracker(tracker: Tracker) {
        analyticsService.reportEvent(event: "Pinned or unpinned tracker on TrackersViewController", parameters: ["event": "click", "screen": "Main"])
        do {
            try trackerStore.pinTracker(tracker)
            loadAndFilterData()
        } catch {
            assertionFailure("Failed to pin tracker")
        }
    }
    
    func editTracker(tracker: Tracker) {
        analyticsService.reportEvent(event: "Selected edit option in tracker's context menu", parameters: ["event": "click", "screen": "Main", "item": "edit"])
        let viewController = EditTrackerViewController(activityType: .regular)
        viewController.tracker = tracker
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
}

extension TrackersViewController: TrackersViewControllerDelegate {
    
    func createdTracker(tracker: Tracker, categoryTitle: String) {
        do {
            let category = TrackerCategory(title: categoryTitle, trackers: [])
            try trackerStore.addCategoryIfNeeded(category)
            try trackerStore.addTracker(tracker, toCategory: category)
            
            if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
                let updatedTrackers = categories[index].trackers + [tracker]
                let updatedCategory = TrackerCategory(title: categoryTitle, trackers: updatedTrackers)
                categories[index] = updatedCategory
            } else {
                categories.append(TrackerCategory(title: categoryTitle, trackers: [tracker]))
            }
            
            filterVisibleCategories(for: currentDate)
            starImageVisibility(visibleCategories.isEmpty)
            loadAndFilterData()
        } catch {
            assertionFailure("Failed to add tracker to Core Data")
        }
    }
    
    func cancelCreateTracker() {
        dismiss(animated: true)
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

extension TrackersViewController: TrackerStoreDelegate {
    func trackerStoreUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates {
            collectionView.insertSections(update.addedSections)
            collectionView.insertItems(at: update.addedIndexPaths)
        }
    }
}

extension TrackersViewController: FilterViewControllerDelegate {
    
    func didSelectFilter(_ filter: String) {
        currentFilter = filter
        switch filter {
        case NSLocalizedString("allTrackers.title", comment: ""):
            visibleCategories = categories
            collectionView.reloadData()
        case NSLocalizedString("trackersForToday.title", comment: ""):
            datePicker.date = Date()
            currentDate = datePicker.date
            filterVisibleCategories(for: currentDate)
            collectionView.reloadData()
        case NSLocalizedString("completed.title", comment: ""):
            visibleCategories = filterCompletedTrackers(categories)
            collectionView.reloadData()
        case NSLocalizedString("notCompleted.title", comment: ""):
            visibleCategories = filterNotCompletedTrackers(categories)
            collectionView.reloadData()
        default:
            break
        }
        dismiss(animated: true)
        updateEmptyState()
    }
    
    func didDeselectFilter() {
        self.currentFilter = nil
        visibleCategories = categories
        collectionView.reloadData()
        dismiss(animated: true)
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        if visibleCategories.isEmpty {
            if currentFilter == NSLocalizedString("completed.title", comment: "") || currentFilter == NSLocalizedString("notCompleted.title", comment: "") {
                noResultImageVisibility(true)
            } else {
                starImageVisibility(true)
            }
        } else {
            noResultImageVisibility(false)
            starImageVisibility(false)
        }
    }
}
