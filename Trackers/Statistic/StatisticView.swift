import UIKit

final class StatisticView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .spWhite
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .spBlack
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .spBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let backgroundGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [
            UIColor(named: "Color1")?.cgColor as Any,
            UIColor(named: "Color9")?.cgColor as Any,
            UIColor(named: "Color3")?.cgColor as Any
        ]
        return gradientLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureUI()
        backgroundGradientLayer.frame = bounds
    }
    
    func refreshView(with number: String, and name: String) {
        titleLabel.text = name
        valueLabel.text = number
    }
    
    private func configureUI() {
        clipsToBounds = true
        layer.cornerRadius = 16
        
        layer.insertSublayer(backgroundGradientLayer, at: 0)
        
        addSubview(containerView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1),
            
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 11),
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 11),
            valueLabel.heightAnchor.constraint(equalToConstant: 41),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 11),
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}
