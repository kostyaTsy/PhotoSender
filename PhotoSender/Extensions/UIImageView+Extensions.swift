import Foundation
import UIKit

extension UIImageView {
    func urlImage(url: URL) {
        let request = URLRequest(url: url)
        self.image = UIImage(systemName: "photo")
        
        Task {
            do {
                let result = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = result.1 as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    return
                }
                
                self.image = UIImage(data: result.0)
            } catch {
                print("error")
            }
        }
    }
}

