import Foundation
import UIKit


class PhotoService {
    func loadPhoto(page: Int) async -> PhotoType? {
        let url = URL(string: "\(photoGetRequestUrl)?page=\(page)")!
        let request = URLRequest(url: url)
        
        do {
            let result = try await URLSession.shared.data(for: request)
            
            guard let response = result.1 as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else { return nil }
            
            let responseData = try? JSONDecoder().decode(PhotoType.self, from: result.0)
            return responseData
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    func sendPhoto(sendData: SendPhoto) async {
        
        let imageData = sendData.image.jpegData(compressionQuality: 0.5)!
        
        let url = URL(string: photoPostRequestUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let data = getDataParams(image: imageData, sendData: sendData)
        
        do {
            let result = try await URLSession.shared.upload(for: request, from: data)
            
            guard let response = result.1 as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else { return }
            
            let responseData = try? JSONSerialization.jsonObject(with: result.0) as? [String: Any]
            
            guard let id = responseData?["id"] else {
                print("Error response")
                return
            }
            
            print(id)
            
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
    private func getDataParams(image: Data, sendData: SendPhoto) -> Data {
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(sendData.developer)".data(using: .utf8)!)
        
        let imageName = "\(sendData.id).jpeg"
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(imageName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(image.mimeType!)\r\n\r\n".data(using: .utf8)!)
        data.append(image)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(sendData.id)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        print(data)
        return data
    }
    
    private let boundary = UUID().uuidString
    
    private var photoGetRequestUrl = "https://junior.balinasoft.com/api/v2/photo/type"
    private var photoPostRequestUrl = "https://junior.balinasoft.com/api/v2/photo"
}
