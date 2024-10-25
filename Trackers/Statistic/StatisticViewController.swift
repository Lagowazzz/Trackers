import UIKit

final class StatisticViewController: UIViewController {
    
    private let trackerRecordStore: TrackerRecordStore = TrackerRecordStore()
    
    private let statisticLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("tabBarStatistic.title", comment: "")
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .spBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nothingView: UIImageView = {
        let nothingImage = UIImage(named: "nothing")
        let view = UIImageView(image: nothingImage)
        view.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        return view
    }()
    
    private let nothingLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("nothingToAnalyze.title", comment: "")
        label.textAlignment = .center
        label.textColor = .spBlack
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bestPeriodView = StatisticView() 
    private lazy var perfectDaysView = StatisticView()
    private lazy var completedTrackersView = StatisticView()
    private lazy var averageView = StatisticView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchStats()
    }
    
    private func setupConstraints() {
        
        [nothingLabel,
         bestPeriodView,
         perfectDaysView,
         completedTrackersView,
         averageView
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(statisticLabel)
        view.addSubview(nothingView)
        view.addSubview(nothingLabel)
        view.addSubview(bestPeriodView)
        view.addSubview(perfectDaysView)
        view.addSubview(completedTrackersView)
        view.addSubview(averageView)
        
        nothingView.center = view.center
        
        NSLayoutConstraint.activate([
            statisticLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            statisticLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            nothingLabel.topAnchor.constraint(equalTo: nothingView.bottomAnchor, constant: 8),
            nothingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bestPeriodView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bestPeriodView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bestPeriodView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -198),
            bestPeriodView.heightAnchor.constraint(equalToConstant: 90),
            
            perfectDaysView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            perfectDaysView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            perfectDaysView.topAnchor.constraint(equalTo: bestPeriodView.bottomAnchor, constant: 12),
            perfectDaysView.heightAnchor.constraint(equalToConstant: 90),
            
            completedTrackersView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            completedTrackersView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            completedTrackersView.topAnchor.constraint(equalTo: perfectDaysView.bottomAnchor, constant: 12),
            completedTrackersView.heightAnchor.constraint(equalToConstant: 90),
            
            averageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            averageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            averageView.topAnchor.constraint(equalTo: completedTrackersView.bottomAnchor, constant: 12),
            averageView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func setPlaceholder(isVisible: Bool) {
        nothingLabel.isHidden = !isVisible
        nothingView.isHidden = !isVisible
        bestPeriodView.isHidden = isVisible
        perfectDaysView.isHidden = isVisible
        completedTrackersView.isHidden = isVisible
        averageView.isHidden = isVisible
    }
    
    private func fetchStats() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let trackersCompleted = self.trackerRecordStore.getNumberOfCompletedTrackers()
            print("Trackers completed: \(trackersCompleted)")
            
            DispatchQueue.main.async {
                if trackersCompleted == 0 {
                    self.setPlaceholder(isVisible: true)
                    return
                }
                
                if let stats = self.trackerRecordStore.getStats() {
                    print("Stats received: \(stats)")
                    
                    self.setPlaceholder(isVisible: false)
                    
                    let perfectDays = stats[0]
                    self.perfectDaysView.refreshView(
                        with: perfectDays > 0 ? "\(perfectDays)" : NSLocalizedString("0", comment: ""),
                        and: NSLocalizedString("Perfect days.title", comment: "")
                    )
                    
                    self.completedTrackersView.refreshView(
                        with: "\(trackersCompleted)",
                        and: NSLocalizedString("Trackers completed.title", comment: "")
                    )
                    
                    let average = stats[1]
                    self.averageView.refreshView(
                        with: average > 0 ? "\(average)" : NSLocalizedString("0", comment: ""),
                        and: NSLocalizedString("Average value.title", comment: "")
                    )
                    
                    let bestPeriod = stats[2]
                    self.bestPeriodView.refreshView(
                        with: bestPeriod > 0 ? "\(bestPeriod)" : NSLocalizedString("0", comment: ""),
                        and: NSLocalizedString("Best period.title", comment: "")
                    )
                    
                    self.bestPeriodView.setNeedsLayout()
                    self.perfectDaysView.setNeedsLayout()
                    self.completedTrackersView.setNeedsLayout()
                    self.averageView.setNeedsLayout()
                } else {
                    print("Failed to retrieve stats")
                    self.setPlaceholder(isVisible: true)
                }
            }
        }
    }
}
