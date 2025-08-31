import Foundation

@MainActor
class TrainScheduelViewModel: ObservableObject {
    @Published var scheduel : [UnifiedArrivalModel] = []

    func loadSpecificData(id: String, type: String) async {
        self.scheduel = []
        
        guard let encodedID = id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error: Could not percent-encode the ID: \(id)")
            return
        }

        
        guard let url = URL(string:
                                "https://aydanbp.pythonanywhere.com/unified_api?id=\(encodedID)&type=\(type)") else {
            print("Error: Could not create a valid URL with the encoded ID: \(encodedID)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let arrivals = try JSONDecoder().decode([UnifiedArrivalModel].self, from: data)
            
            self.scheduel = arrivals
        } catch {
            print("Error fetching or decoding arrivals for id \(id): \(error)")
            self.scheduel = []
        }
    }
}
