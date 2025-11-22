//
//  UIViewController+Jelly.swift
//  KnowLED
//
//  Created by Choi on 2025/11/22.
//

import UIKit

extension UIViewController {
    
    func pageSheet(
        _ controller: PresentedControllerType,
        presentationSize: CGSize? = nil,
        alignment: PresentationAlignment = .centerAlignment,
        uiConfiguration: PresentationUIConfiguration? = nil,
        tapToDismiss: Bool = true)
    {
        let screenSize = Size.screenSize
        let defaultWidth = min(screenSize.width * 0.676, 730.0)
        let defaultHight = min(screenSize.height * 0.869, 704.0)
        let defaultSize = CGSize(width: defaultWidth, height: defaultHight)
        let size = presentationSize.or(defaultSize).presentationSize
        let targetUiConfiguration = uiConfiguration ?? PresentationUIConfiguration(
            cornerRadius: 10,
            backgroundStyle: .dimmed(alpha: 0.618),
            isTapBackgroundToDismissEnabled: tapToDismiss
        )
        let presentation = CoverPresentation(
            directionShow: .bottom,
            directionDismiss: .bottom,
            uiConfiguration: targetUiConfiguration,
            size: size,
            alignment: alignment,
            timing: PresentationTiming(duration: .custom(duration: 0.4), presentationCurve: .easeInOut, dismissCurve: .easeOut)
        )
        let animator = JellyAnimator(presentation: presentation)
        controller.prepareAnimator(animator)
        present(controller, animated: true)
    }
    
    func fadeIn(_ controller: PresentedControllerType, tapBackgroundToDismissEnabled: Bool = true, alignment: PresentationAlignmentProtocol? = nil, ui: PresentationUIConfigurationProtocol? = nil) {
        let fade = FadePresentation(
            alignment: alignment ?? PresentationAlignment.centerAlignment,
            size: controller.preferredContentSize.presentationSize,
            ui: ui ?? PresentationUIConfiguration(
                cornerRadius: 10.0,
                backgroundStyle: .dimmed(alpha: 0.618),
                isTapBackgroundToDismissEnabled: tapBackgroundToDismissEnabled,
                corners: .allCorners
            )
        )
        let animator = JellyAnimator(presentation: fade)
        controller.prepareAnimator(animator)
        present(controller, animated: true)
    }
    
    func popDialog(_ controller: PresentedControllerType, tapBackgroundToDismissEnabled: Bool = true) {
        let timing = PresentationTiming(
            duration: .custom(duration: 0.25),
            presentationCurve: .easeInOut,
            dismissCurve: .easeInOut
        )
        let ui = PresentationUIConfiguration(
            cornerRadius: 10,
            backgroundStyle: .dimmed(alpha: 0.618),
            isTapBackgroundToDismissEnabled: tapBackgroundToDismissEnabled,
            corners: .allCorners
        )
        let fade = FadePresentation(
            size: controller.preferredContentSize.presentationSize,
            timing: timing,
            ui: ui
        )
        let animator = JellyAnimator(presentation: fade)
        controller.prepareAnimator(animator)
        present(controller, animated: true)
    }
    
    func slideIn(
        _ controller: PresentedControllerType,
        contentSize: CGSize? = nil,
        cornerRadius: CGFloat = 0,
        alignment: PresentationAlignment,
        directionShow: Direction,
        directionDismiss: Direction? = nil,
        tapToDismiss: Bool = true)
    {
        let uiConfiguration = PresentationUIConfiguration(
            cornerRadius: cornerRadius,
            backgroundStyle: .dimmed(alpha: 0.618),
            isTapBackgroundToDismissEnabled: tapToDismiss
        )
        let presentation = CoverPresentation(
            directionShow: directionShow,
            directionDismiss: directionDismiss ?? directionShow,
            uiConfiguration: uiConfiguration,
            size: contentSize.or(controller.preferredContentSize).presentationSize,
            alignment: alignment,
            timing: PresentationTiming(duration: .normal, presentationCurve: .easeIn, dismissCurve: .easeOut)
        )
        let animator = JellyAnimator(presentation: presentation)
        controller.prepareAnimator(animator)
        present(controller, animated: true)
    }
    
    /// 从底部滑入弹窗(选择相册/相机)
    func slideIn(_ controller: PresentedControllerType) {
        let uiConfiguration = PresentationUIConfiguration(
            cornerRadius: 20,
            backgroundStyle: .dimmed(alpha: 0.618),
            isTapBackgroundToDismissEnabled: true,
            corners: .layerMinXMinYCorner.union(.layerMaxXMinYCorner)
        )
        let presentation = CoverPresentation(
            directionShow: .bottom,
            directionDismiss: .bottom,
            uiConfiguration: uiConfiguration,
            size: controller.preferredContentSize.presentationSize,
            alignment: PresentationAlignment(vertical: .bottom, horizontal: .center),
            timing: PresentationTiming(duration: .normal, presentationCurve: .easeIn, dismissCurve: .easeOut)
        )
        let animator = JellyAnimator(presentation: presentation)
        controller.prepareAnimator(animator)
        present(controller, animated: true)
    }
}
