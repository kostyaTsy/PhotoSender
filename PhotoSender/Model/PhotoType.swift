import Foundation

struct PhotoType: Codable {
    let page: Int
    let totalPages: Int
    let content: [Photo]
}
