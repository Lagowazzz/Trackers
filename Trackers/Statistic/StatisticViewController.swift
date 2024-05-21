import UIKit

final class StatisticViewController: UIViewController {
    
    private let statisticLabel: UILabel = {
        let statisticLabel = UILabel()
        statisticLabel.text = "Статистика"
        statisticLabel.font = .boldSystemFont(ofSize: 34)
        statisticLabel.textColor = .black
        statisticLabel.translatesAutoresizingMaskIntoConstraints = false
        return statisticLabel
    }()
    
    private let nothingView: UIImageView = {
        let nothingImage = UIImage(named: "nothing")
        let nothingView = UIImageView(image: nothingImage)
        nothingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        return nothingView
    }()
    
    private let nothingLabel: UILabel = {
        let nothingLabel = UILabel()
        nothingLabel.text = "Анализировать пока нечего"
        nothingLabel.textAlignment = .center
        nothingLabel.textColor = .black
        nothingLabel.font = .systemFont(ofSize: 12)
        nothingLabel.translatesAutoresizingMaskIntoConstraints = false
        return nothingLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        view.addSubview(statisticLabel)
        view.addSubview(nothingView)
        view.addSubview(nothingLabel)
        
        nothingView.center = view.center
        
        NSLayoutConstraint.activate([
            statisticLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            statisticLabel.widthAnchor.constraint(equalToConstant: 254),
            statisticLabel.heightAnchor.constraint(equalToConstant: 41),
            
            nothingLabel.widthAnchor.constraint(equalToConstant: 343),
            nothingLabel.heightAnchor.constraint(equalToConstant: 18),
            nothingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nothingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nothingLabel.topAnchor.constraint(equalTo: nothingView.bottomAnchor, constant: 8)
        ])
    }
}
