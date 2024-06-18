import UIKit

class OnboardingSetupPageViewController: UIViewController {
    
    private let imageView = UIImageView()
    private let label = UILabel()
    
    init(imageName: String, text: String) {
        super.init(nibName: nil, bundle: nil)
        
        setupImageView(imageName: imageName)
        setupLabel(text: text)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupImageView(imageName: String) {
        let image = UIImage(named: imageName)
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupLabel(text: String) {
        label.text = text
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 3
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304)
        ])
    }
}
