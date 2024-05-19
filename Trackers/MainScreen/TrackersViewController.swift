import UIKit

final class TrackersViewController: UIViewController, UICollectionViewDelegate {
    
    private var mainLabel: UILabel!
    private var starImageView: UIImageView!
    private var whatsUpLabel: UILabel!
    private var searchTextField: UISearchTextField!
    private var collectionView: UICollectionView!
    private var categories: [TrackerCategory] = []
    private var doneTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupMainLabel()
        setupSearchTextField()
        setupCollectionView()
        setupStarImageView()
        setupWhatsUpLabel()
        setupNavigationBar()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.bringSubviewToFront(searchTextField)
    }
    
    @objc private func plusButtonDidTap() {
        let addNewTrackerViewController = UINavigationController(rootViewController: AddNewTrackerViewController())
        present(addNewTrackerViewController, animated: true)
    }
    
    private func setupNavigationBar() {
        let plusImage = UIImage(named: "plus")
        let plusButton = UIBarButtonItem(
            image: plusImage,
            style: .plain,
            target: self,
            action: #selector(plusButtonDidTap))
        plusButton.tintColor = .black
        navigationItem.leftBarButtonItem = plusButton
        
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.widthAnchor.constraint(equalToConstant: 120).isActive = true

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let formattedDate = formatter.string(from: datePicker.date)
        datePicker.date = formatter.date(from: formattedDate) ?? Date()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    private func setupSearchTextField() {
        searchTextField = UISearchTextField()
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholder = "Поиск"
        searchTextField.font = UIFont.systemFont(ofSize: 17)
        view.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 7),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
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
        let starView = UIImage(named: "Star")
        starImageView = UIImageView(image: starView)
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
    
    func addNewTracker(_ tracker: Tracker, to categoryIndex: Int) {
        guard categoryIndex >= 0 && categoryIndex < categories.count else { return }
        categories[categoryIndex].trackers.append(tracker)
    }
    
    func addCompletedTrackerRecord(_ trackerRecord: TrackerRecord) {
        doneTrackers.append(trackerRecord)
    }
    
    func removeCompletedTrackerRecord(_ trackerRecord: TrackerRecord) {
        if let index = doneTrackers.firstIndex(where: { $0.id == trackerRecord.id && $0.date == trackerRecord.date }) {
            doneTrackers.remove(at: index)
        }
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackersCollectionViewCell
        cell?.trackerView.backgroundColor = .blue
        return cell ?? TrackersCollectionViewCell()
    }
}
