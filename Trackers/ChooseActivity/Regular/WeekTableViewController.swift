
import UIKit

protocol WeekTableViewControllerDelegate: AnyObject {
    func updateWeekTable(_ selectedDays: [WeekDay])
}

final class WeekTableViewController: UIViewController {
    
    private var doneButton: UIButton!
    private var tableView: UITableView!
    weak var delegate: WeekTableViewControllerDelegate?
    private var selectedWeekTable: [WeekDay] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupTableView()
        setupDoneButton()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc private func didTapDoneButton() {
        switchStatus()
        delegate?.updateWeekTable(selectedWeekTable)
        navigationController?.popViewController(animated: true)
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 525),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)])
    }
    
    private func setupDoneButton() {
        doneButton = UIButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.backgroundColor = .black
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            doneButton.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 24),
            doneButton.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 47)
        ])
    }
    
    private func setupNavBar() {
        navigationItem.title = "Расписание"
    }
    
    private func switchStatus() {
        for (index, weekDay) in WeekDay.allCases.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            guard let switchView = cell?.accessoryView as? UISwitch else {return}
            
            if switchView.isOn {
                selectedWeekTable.append(weekDay)
            } else {
                selectedWeekTable.removeAll { $0 == weekDay }
            }
        }
    }
}

extension WeekTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath) as? CustomTableViewCell else { return UITableViewCell()}
        cell.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
        cell.textLabel?.text = WeekDay.allCases[indexPath.row].value
        let switchButton = UISwitch(frame: .zero)
        switchButton.setOn(false, animated: true)
        switchButton.onTintColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1)
        switchButton.tag = indexPath.row
        cell.accessoryView = switchButton
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == WeekDay.allCases.count - 1 {
            return 76
        } else {
            return 75
        }
    }
}
