
import UIKit

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func completeTracker(id: UUID)
    func noCompleteTracker(id: UUID)
    func deleteTracker(tracker: Tracker)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCell"
    weak var delegate: TrackersCollectionViewCellDelegate?
    
    var isCompleted: Bool?
    var trackerID: UUID?
    var indexPath: IndexPath?
    
    private let trackerView: UIView = {
        let trackerView = UIView()
        trackerView.translatesAutoresizingMaskIntoConstraints = false
        trackerView.layer.cornerRadius = 16
        trackerView.layer.masksToBounds = true
        trackerView.backgroundColor = .blue
        return trackerView
    }()
    
    private let trackerNameLabel: UILabel = {
        let trackerNameLabel = UILabel()
        trackerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerNameLabel.font = UIFont.systemFont(ofSize: 12)
        trackerNameLabel.textColor = .spWhite
        trackerNameLabel.numberOfLines = 0
        return trackerNameLabel
    }()
    
    private let emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.textAlignment = .center
        emojiLabel.font = UIFont.systemFont(ofSize: 16)
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.layer.masksToBounds = true
        return emojiLabel
    }()
    
    private let trackerDayLabel: UILabel = {
        let trackerDayLabel = UILabel()
        trackerDayLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerDayLabel.font = UIFont.systemFont(ofSize: 12)
        trackerDayLabel.textColor = .spBlack
        return trackerDayLabel
    }()
    
    private lazy var doneButton: UIButton = {
        let doneButton = UIButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.tintColor = .spWhite
        doneButton.layer.cornerRadius = 17
        doneButton.layer.masksToBounds = true
        doneButton.contentMode = .center
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        return doneButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
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
    
    private func setupConstraints() {
        
        contentView.addSubview(trackerView)
        trackerView.addSubview(trackerNameLabel)
        trackerView.addSubview(emojiLabel)
        contentView.addSubview(trackerDayLabel)
        contentView.addSubview(doneButton)
        let interaction = UIContextMenuInteraction(delegate: self)
        trackerView.addInteraction(interaction)
        
        NSLayoutConstraint.activate([
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerView.heightAnchor.constraint(equalToConstant: 90),
            
            trackerNameLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            trackerNameLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
            
            emojiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            trackerDayLabel.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 16),
            trackerDayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            trackerDayLabel.heightAnchor.constraint(equalToConstant: 18),
            
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
        
        let imageName = isCompletedToday ? "checkmark" : "plus"
        let image = UIImage(systemName: imageName)
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
        let formattedString = String.localizedStringWithFormat(
            NSLocalizedString("StringKey", comment: ""),
            completedDays
        )
        trackerDayLabel.text = formattedString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TrackersCollectionViewCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let _ = indexPath,
              let _ = trackerID,
              let _ = isCompleted
        else {
            return nil
        }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { [weak self] _ in
                
                let deleteAction = UIAction(title: NSLocalizedString("deleteAction.title", comment: ""), attributes: .destructive) { _ in
                    guard let trackerID = self?.trackerID,
                          let _ = self?.indexPath else {
                        return
                    }
                    let tracker = Tracker(id: trackerID, name: "", color: .clear, emoji: "", timeTable: [], isIrregular: Bool())
                    self?.delegate?.deleteTracker(tracker: tracker)
                }
                
                return UIMenu(title: "", children: [deleteAction])
            }
        )
    }
}

