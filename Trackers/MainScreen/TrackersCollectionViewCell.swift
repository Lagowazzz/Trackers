
import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    private var trackerNameLabel: UILabel!
    var trackerView: UIView!
    private var emojiLabel: UILabel!
    private var trackerDayLabel: UILabel!
    private var doneButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDoneButton()
        setupTrackerDayLabel()
        setupTrackerNameLabel()
        setupEmojiLabel()
        setupTrackerView()
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
        doneButton.setImage(UIImage(named: "plus"), for: .normal)
        doneButton.layer.cornerRadius = 17
        doneButton.layer.masksToBounds = true
        doneButton.contentMode = .center
        contentView.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 8),
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            doneButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
