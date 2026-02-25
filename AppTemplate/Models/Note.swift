import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date
    var needsSync: Bool

    init(
        id: UUID = UUID(),
        title: String = "",
        body: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        needsSync: Bool = false
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.needsSync = needsSync
    }
}
