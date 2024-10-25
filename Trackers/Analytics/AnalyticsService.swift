import AppMetricaCore

final class AnalyticsService {
    
    static func activate() {
        let configuration = AppMetricaConfiguration(apiKey: "0cf928e2-f088-415a-b461-773d532fb2ec")
           AppMetrica.activate(with: configuration!)
    }
    
    func reportEvent(event: String, parameters: [String: String]) {
        AppMetrica.reportEvent(name: event, parameters: parameters, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
