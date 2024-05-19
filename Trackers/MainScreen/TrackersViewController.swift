import UIKit

final class TrackersViewController: UIViewController {
    
    private var plusButton: UIButton!
    private var dateButton: UIButton!
    private var mainLabel: UILabel!
    private var starImageView: UIImageView!
    private var whatsUpLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPlusButton()
        setupDateButton()
        setupMainLabel()
        setupSearchTextField()
        setupStarImageView()
        setupWhatsUpLabel()
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
    
    private func setupSearchTextField() {
        let searchTextField = UITextField()
        searchTextField.placeholder = "      Поиск"
        searchTextField.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12)
        
        searchTextField.layer.cornerRadius = 8
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchTextField)
        
        let searchIconImageView = UIImageView(image: UIImage(named: "search"))
        searchIconImageView.contentMode = .scaleAspectFit
        searchIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        searchTextField.leftViewMode = .always
        searchTextField.addSubview(searchIconImageView)
        
        NSLayoutConstraint.activate([
            searchIconImageView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor, constant: 8),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 15.5),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 15.5),
            searchIconImageView.topAnchor.constraint(equalTo: searchTextField.topAnchor, constant: 10),
            searchIconImageView.bottomAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 7),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36)
        ])
        
    }
    
    private func setupDateButton() {
        dateButton = UIButton(type: .custom)
        dateButton.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        dateButton.setTitle(formatDate(date: Date()), for: .normal)
        dateButton.setTitleColor(.black, for: .normal)
        dateButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        dateButton.layer.cornerRadius = 8
        dateButton.layer.masksToBounds = true
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateButton)
        
        NSLayoutConstraint.activate([
            dateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dateButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 49),
            dateButton.widthAnchor.constraint(equalToConstant: 77),
            dateButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupPlusButton() {
        let image = UIImage(named: "plus")
        plusButton = UIButton(type: .custom)
        plusButton.setImage(image, for: .normal)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            plusButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            plusButton.widthAnchor.constraint(equalToConstant: 42),
            plusButton.heightAnchor.constraint(equalToConstant: 42)
            
        ])
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.MM.yy"
        return formatter.string(from: date)
    }
}

