import UIKit

final class ColorsAndEmojisCells: UICollectionViewCell {
    
    static let reuseIdentifier = "ColorsAndEmojisCells"
    
    private let colorAndEmojiLabel: UILabel = {
        let colorAndEmojiLabel = UILabel()
        colorAndEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        colorAndEmojiLabel.textAlignment = .center
        colorAndEmojiLabel.layer.cornerRadius = 8
        colorAndEmojiLabel.layer.masksToBounds = true
        return colorAndEmojiLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorAndEmojiLabel)
        
        NSLayoutConstraint.activate([
            colorAndEmojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorAndEmojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorAndEmojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorAndEmojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }
    
    required init?(coder: NSCoder) {
        super .init(coder: coder)
        
        contentView.addSubview(colorAndEmojiLabel)
        
        NSLayoutConstraint.activate([
            colorAndEmojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorAndEmojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorAndEmojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorAndEmojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
        assert(subviews.contains(colorAndEmojiLabel), "colorAndEmojiLabel не добавлен как subview")
    }
}
