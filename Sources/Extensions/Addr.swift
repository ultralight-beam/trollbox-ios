import UB

extension Addr {
    var hex: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
