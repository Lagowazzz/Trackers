import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class CategoryViewController: UIViewController {
    
    private var viewModel = CategoryViewModel(categoryStore: TrackerCategoryStore())
    
    weak var delegate: CategoryViewControllerDelegate?
    
    private var cellsTableView: [String] = []
    private var selectedCategoryIndex: Int?
    
    private let starImageView: UIImageView = {
        let starImageView = UIImageView()
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        starImageView.image = UIImage(named: "Star")
        return starImageView
    }()
    
    private let starLabel: UILabel = {
        let starLabel = UILabel()
        starLabel.translatesAutoresizingMaskIntoConstraints = false
        starLabel.numberOfLines = 2
        starLabel.text = NSLocalizedString("category.title", comment: "")
        starLabel.textAlignment = .center
        starLabel.font = .systemFont(ofSize: 12)
        starLabel.textColor = .black
        return starLabel
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView()
        tableView.separatorColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var categoryButton: UIButton = {
        let categoryButton = UIButton()
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        categoryButton.backgroundColor = .black
        categoryButton.layer.cornerRadius = 16
        categoryButton.layer.masksToBounds = true
        categoryButton.setTitle(NSLocalizedString("addCategory.title", comment: ""), for: .normal)
        categoryButton.setTitleColor(.white, for: .normal)
        categoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        categoryButton.addTarget(self, action: #selector(didTapCategoryButton), for: .touchUpInside)
        return categoryButton
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateHandler()
        viewModel.fetchCategories()
        view.backgroundColor = .white
        setupNavBar()
        setupConstraints()
        setupTableView()
        updateEmptyStateVisibility()
    }
    
    @objc private func didTapCategoryButton() {
        let newCategoryViewController = NewCategoryViewController()
        let navigationController = UINavigationController(rootViewController: newCategoryViewController)
        present(navigationController, animated: true) {
            newCategoryViewController.delegate = self
        }
    }
    
    private func updateHandler() {
        viewModel = CategoryViewModel(categoryStore: TrackerCategoryStore())
        viewModel.updateHandler = { [weak self] categories in
            self?.tableView.reloadData()
            self?.updateEmptyStateVisibility()
        }
    }
    
    private func setupConstraints() {
        view.addSubview(starImageView)
        view.addSubview(starLabel)
        view.addSubview(tableView)
        view.addSubview(categoryButton)
        
        NSLayoutConstraint.activate([
            starImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            starImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starImageView.widthAnchor.constraint(equalToConstant: 80),
            starImageView.heightAnchor.constraint(equalToConstant: 80),
            
            starLabel.topAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: 8),
            starLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.heightAnchor.constraint(equalToConstant: 525),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            categoryButton.heightAnchor.constraint(equalToConstant: 60),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupNavBar() {
        navigationItem.title = NSLocalizedString("categoryMain.title", comment: "")
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func updateEmptyStateVisibility() {
        let isTableEmpty = viewModel.numberOfCategories() == 0
        starImageView.isHidden = !isTableEmpty
        starLabel.isHidden = !isTableEmpty
        tableView.isHidden = isTableEmpty
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedCategoryIndex = indexPath.row
        tableView.reloadData()
        
        let selectedCategory = viewModel.category(at: indexPath.row)
        delegate?.didSelectCategory(selectedCategory.title)
        navigationController?.popViewController(animated: true)
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath)
        guard cell is CustomTableViewCell else {
            return UITableViewCell()
        }
        let category = viewModel.category(at: indexPath.row)
        cell.textLabel?.text = category.title
        cell.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        cell.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16.0
        
        if viewModel.numberOfCategories() == 1 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
            if indexPath.row == 0 {
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if indexPath.row == numberOfRows - 1 {
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                cell.layer.maskedCorners = []
            }
        }
        
        if indexPath.row == selectedCategoryIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension CategoryViewController: NewCategoryViewControllerDelegate {
    func didCreateCategory(_ category: TrackerCategory) {
        viewModel.addCategory(category)
        tableView.reloadData()
        updateEmptyStateVisibility()
    }
    
    func updatedCategoryList(_ categories: [String]) {
        cellsTableView = categories
        tableView.reloadData()
        updateEmptyStateVisibility()
    }
}
