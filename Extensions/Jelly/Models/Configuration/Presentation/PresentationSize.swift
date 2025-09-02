import Foundation

public struct PresentationSize: PresentationSizeProtocol {
    public var width: JellySize
    public var height: JellySize
    
    public init(width: JellySize = .fullscreen,
                height: JellySize = .fullscreen) {
        self.width = width
        self.height = height
    }
}
