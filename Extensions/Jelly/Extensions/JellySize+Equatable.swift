import Foundation

extension JellySize: Equatable {
    public static func == (lhs: JellySize, rhs: JellySize) -> Bool {
        switch (lhs, rhs) {
            case (.fullscreen,.fullscreen), (.halfscreen,.halfscreen):
                return true
            case (.custom(let lhsValue), .custom(let rhsValue)):
                return lhsValue == rhsValue
            default:
                return false
        }
    }
}
