import Foundation

extension Data {
    var hex: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
