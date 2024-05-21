
import UIKit

final class ActivityCell: UITableViewCell {
    
    static let reuseIdentifier = "ActivityCell"
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    private let subTitleLabel: UILabel = {
        let subTitleLabel = UILabel()
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.font = UIFont.systemFont(ofSize: 17)
        subTitleLabel.numberOfLines = 0
        return subTitleLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    private func setupConstraints() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)])
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    func setupText(subText: String?) {
        if let subText = subText {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            let subTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)]
            let subAttributedString = NSMutableAttributedString(string: subText, attributes: subTextAttributes)
            subAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: subAttributedString.length))
            
            titleLabel.numberOfLines = 1
            subTitleLabel.numberOfLines = 1
            subTitleLabel.attributedText = subAttributedString
        } else {
            titleLabel.text = nil
            subTitleLabel.text = nil
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
