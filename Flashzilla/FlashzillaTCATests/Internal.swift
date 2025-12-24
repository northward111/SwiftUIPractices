import Foundation
import SQLiteData

@testable import FlashzillaTCA

extension Database {
  func seed() throws {
    try seed {
        Card(id: UUID(1), prompt: "Capital of France?", answer: "Paris")
        Card(id: UUID(2), prompt: "2 + 2", answer: "4")
    }
  }
}
