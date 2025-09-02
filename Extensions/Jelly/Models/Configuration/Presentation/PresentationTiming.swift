import UIKit

public struct PresentationTiming: PresentationTimingProtocol {
    public var duration: JellyDuration
    public var presentationCurve: UIView.AnimationCurve
    public var dismissCurve: UIView.AnimationCurve
    
    public init(duration: JellyDuration = .medium,
                presentationCurve: UIView.AnimationCurve = .linear,
                dismissCurve: UIView.AnimationCurve = .linear) {
        self.duration = duration
        self.presentationCurve = presentationCurve
        self.dismissCurve = dismissCurve
    }
}
