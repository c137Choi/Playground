import UIKit

public protocol PresentationTimingProtocol {
    var duration: JellyDuration { get set }
    var presentationCurve: UIView.AnimationCurve { get set }
    var dismissCurve: UIView.AnimationCurve { get set }
}
