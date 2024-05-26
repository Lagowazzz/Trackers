import UIKit

final class ColorsAndEmojisSupplementaryView: UICollectionReusableView {
    
    static let reuseIdentifier = "ColorsAndEmojisSupplementaryView"
    
    let colorAndEmojiLabel: UILabel = {
        let colorAndEmojiLabel = UILabel()
        colorAndEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        colorAndEmojiLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        colorAndEmojiLabel.textColor = .black
        colorAndEmojiLabel.textAlignment = .left
        return colorAndEmojiLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(colorAndEmojiLabel)
        
        NSLayoutConstraint.activate([
            colorAndEmojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            colorAndEmojiLabel.topAnchor.constraint(equalTo: topAnchor),
            colorAndEmojiLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        addSubview(colorAndEmojiLabel)
        
        NSLayoutConstraint.activate([
            colorAndEmojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            colorAndEmojiLabel.topAnchor.constraint(equalTo: topAnchor),
            colorAndEmojiLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        assert(subviews.contains(colorAndEmojiLabel), "colorAndEmojiLabel не добавлен как subview")
    }
}
