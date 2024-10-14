import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: String)
    func didDeselectFilter()
}

final class FilterViewController: UIViewController {
    
    weak var delegate: FilterViewControllerDelegate?
    var currentFilter: String?
    
    private let filters = [
        NSLocalizedString("allTrackers.title", comment: ""),
        NSLocalizedString("trackersForToday.title", comment: ""),
        NSLocalizedString("completed.title", comment: ""),
        NSLocalizedString("notCompleted.title", comment: "")
    ]
    
    private let filterTitle: UILabel = {
        let label = UILabel()
        label.textColor = .spWhite
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = NSLocalizedString("filters.title", comment: "")
        return label
    }()
    
    private let filtersTable: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .spWhite
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView()
        tableView.separatorColor = .lightGray
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filtersTable.dataSource = self
        filtersTable.delegate = self
        setupUI()
    }
    
    private func setupUI() {
        
        view.backgroundColor = .spWhite
        view.addSubview(filterTitle)
        view.addSubview(filtersTable)
        
        filterTitle.translatesAutoresizingMaskIntoConstraints = false
        filtersTable.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            filterTitle.heightAnchor.constraint(equalToConstant: 22),
            
            filtersTable.topAnchor.constraint(equalTo: filterTitle.bottomAnchor, constant: 24),
            filtersTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTable.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = .spGray
        cell.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        
        cell.textLabel?.text = filters[indexPath.row]
        
        if currentFilter == filters[indexPath.row] {
            self.filtersTable.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            cell.isSelected = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.row]
        
        if currentFilter == selectedFilter {
            self.dismiss(animated: true)
            return
        }
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        delegate?.didSelectFilter(selectedFilter)
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == filters.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}
