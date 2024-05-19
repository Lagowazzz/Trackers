import UIKit

final class StatisticViewController: UIViewController {
    
    private var nothingView: UIImageView!
    private var nothingLabel: UILabel!
    private var statisticLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatisticLabel()
        setupNothingView()
        setupNothingLabel()
    }
    
    private func setupStatisticLabel() {
        statisticLabel = UILabel()
        statisticLabel.text = "Статистика"
        statisticLabel.font = .boldSystemFont(ofSize: 34)
        statisticLabel.textColor = .black
        statisticLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statisticLabel)
        
        NSLayoutConstraint.activate([
            statisticLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            statisticLabel.widthAnchor.constraint(equalToConstant: 254),
            statisticLabel.heightAnchor.constraint(equalToConstant: 41)
        ])
    }
    
    private func setupNothingView() {
        let nothingImage = UIImage(named: "nothing")
        nothingView = UIImageView(image: nothingImage)
        nothingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        nothingView.center = view.center
        view.addSubview(nothingView)
    }
    
    private func setupNothingLabel() {
        nothingLabel = UILabel()
        nothingLabel.text = "Анализировать пока нечего"
        nothingLabel.textAlignment = .center
        nothingLabel.textColor = .black
        nothingLabel.font = .systemFont(ofSize: 12)
        nothingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nothingLabel)
        
        NSLayoutConstraint.activate([
            nothingLabel.widthAnchor.constraint(equalToConstant: 343),
            nothingLabel.heightAnchor.constraint(equalToConstant: 18),
            nothingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nothingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nothingLabel.topAnchor.constraint(equalTo: nothingView.bottomAnchor, constant: 8)
        ])
    }
}
