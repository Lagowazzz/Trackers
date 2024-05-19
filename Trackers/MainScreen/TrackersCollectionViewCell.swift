
import UIKit

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func completeTracker(id: UUID)
    func noCompleteTracker(id: UUID)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCell"
    weak var delegate: TrackersCollectionViewCellDelegate?
    
    var isCompleted: Bool?
    var trackerID: UUID?
    var indexPath: IndexPath?
    
    private var trackerNameLabel: UILabel!
    var trackerView: UIView!
    private var emojiLabel: UILabel!
    private var trackerDayLabel: UILabel!
    private var doneButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTrackerView()
        setupDoneButton()
        setupTrackerDayLabel()
        setupTrackerNameLabel()
        setupEmojiLabel()
    }
    
    @objc private func didTapDoneButton() {
        guard let isCompleted = isCompleted,
              let trackerID = trackerID
        else {
            return
        }
        if isCompleted {
            delegate?.noCompleteTracker(id: trackerID)
        } else {
            delegate?.completeTracker(id: trackerID)
        }
    }
    
    private func setupTrackerView() {
        trackerView = UIView()
        trackerView.translatesAutoresizingMaskIntoConstraints = false
        trackerView.layer.cornerRadius = 16
        trackerView.layer.masksToBounds = true
        trackerView.backgroundColor = .blue
        contentView.addSubview(trackerView)
        
        NSLayoutConstraint.activate([
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerView.heightAnchor.constraint(equalToConstant: 90)])
    }
    
    private func setupTrackerNameLabel() {
        trackerNameLabel = UILabel()
        trackerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerNameLabel.font = UIFont.systemFont(ofSize: 12)
        trackerNameLabel.textColor = .white
        trackerNameLabel.numberOfLines = 0
        trackerView.addSubview(trackerNameLabel)
        
        NSLayoutConstraint.activate([
            trackerNameLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            trackerNameLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12)])
    }
    
    private func setupEmojiLabel() {
        emojiLabel = UILabel()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.textAlignment = .center
        emojiLabel.font = UIFont.systemFont(ofSize: 16)
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.layer.masksToBounds = true
        trackerView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24)])
    }
    
    private func setupTrackerDayLabel() {
        trackerDayLabel = UILabel()
        trackerDayLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerDayLabel.font = UIFont.systemFont(ofSize: 12)
        trackerDayLabel.textColor = .black
        contentView.addSubview(trackerDayLabel)
        
        NSLayoutConstraint.activate([
            trackerDayLabel.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 16),
            trackerDayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            trackerDayLabel.heightAnchor.constraint(equalToConstant: 18)])
    }
    
    private func setupDoneButton() {
        doneButton = UIButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.tintColor = .white
        doneButton.layer.cornerRadius = 17
        doneButton.layer.masksToBounds = true
        doneButton.contentMode = .center
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        contentView.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 8),
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            doneButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func setupUI(
        with tracker: Tracker,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath
    ) {
        self.trackerID = tracker.id
        self.isCompleted = isCompletedToday
        self.indexPath = indexPath
        
        trackerView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        trackerNameLabel.text = tracker.name
        updateTrackerDayLabel(completedDays: completedDays)
        
        let image = isCompleted! ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        doneButton.backgroundColor = isCompletedToday ? tracker.color.withAlphaComponent(0.3) : tracker.color
        trackerNameLabel.backgroundColor = tracker.color
        for view in self.doneButton.subviews {
            view.removeFromSuperview()
        }
        doneButton.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: doneButton.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor)
        ])
    }
    
    private func updateTrackerDayLabel(completedDays: Int) {
        let daysText: String
        
        switch completedDays {
        case 1:
            daysText = "день"
        case 2...4:
            daysText = "дня"
        default:
            daysText = "дней"
        }
        trackerDayLabel.text = "\(completedDays) \(daysText)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
