//
//  UIViewControllerPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/3/3.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import RxSwift
import RxCocoa

final class RxImagePickerDelegate: NSObject, ObservableType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    typealias Element = UIImage
    
    private var observers: [AnyObserver<Element>] = []
    
    func subscribe<Observer>(_ observer: Observer) -> any RxSwift.Disposable where Observer : RxSwift.ObserverType, Element == Observer.Element {
        observers.append(observer.asObserver())
        return Disposables.create()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard var image = info[.originalImage] as? UIImage else {
            return imagePickerControllerDidCancel(picker)
        }
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        }
        for observer in observers {
            observer.onNext(image)
            observer.onCompleted()
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        for observer in observers {
            observer.onCompleted()
        }
        picker.dismiss(animated: true)
    }
}

extension UIViewController {
    
    func getPictures(count: Int, from source: UIImagePickerController.SourceType) -> Observable<UIImage> {
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            return .error("Source Unavailable")
        }
        return AVAuthorizationStatus.checkValidVideoStatus.withUnretained(self).flatMapLatest(\.0.takePhoto)
    }
    
    fileprivate var takePhoto: Observable<UIImage> {
        let delegate = RxImagePickerDelegate()
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = delegate
        picker.references["strongDelegate"] = delegate
        picker.modalPresentationStyle = .pageSheet
        
        present(picker, animated: true)
        
        return delegate.asObservable()
    }
    
    private func pickPicture(count: Int) {
        let photoLibrary = PHPhotoLibrary.shared()
        
        var config = PHPickerConfiguration(photoLibrary: photoLibrary)
        config.filter = .images
        config.selectionLimit = count
        config.preferredAssetRepresentationMode = .automatic
        config.preselectedAssetIdentifiers = []
        
        let picker = PHPickerViewController(configuration: config)
        picker.modalPresentationStyle = .pageSheet
        present(picker, animated: true)
    }
    
    /// Dismiss所有的presentedViewController | 最后dismiss自己
    func dismissPresentedViewControllerIfNeeded(_ completion: SimpleCallback? = nil) {
        if let presentedViewController {
            /// 不加动画
            presentedViewController.dismiss(animated: false) {
                [unowned self] in dismissPresentedViewControllerIfNeeded()
            }
        } else {
            /// 如果presentedViewController为空,则dismiss自己 | 带动画
            dismiss(animated: true, completion: completion)
        }
    }
    
    
    /// 获取目标导航控制器
    /// - Parameter navigationType: 导航控制器类型
    /// - Returns: 目标导航控制器
    func targetNavigation<T>(_ navigationType: T.Type) -> T? where T: UINavigationController {
        if let tab = self as? UITabBarController {
            func matches(controller: UIViewController) -> Bool {
                controller.isMember(of: navigationType)
            }
            return tab.viewControllers?.first(where: matches) as? T
        } else if let navi = self as? T {
            return navi
        } else {
            return navigationController as? T
        }
    }
    
    func push(_ controller: UIViewController, animated: Bool = true) {
        if let navi = self as? UINavigationController {
            navi.pushViewController(controller, animated: animated)
        } else {
            navigationController?.pushViewController(controller, animated: animated)
        }
    }
    
    func embedInNavigationController<NavigationController>(_ navigationControllerType: NavigationController.Type = UINavigationController.self as! NavigationController.Type) -> NavigationController where NavigationController: UINavigationController {
        NavigationController(rootViewController: self)
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
extension UIViewController {
	
	private struct Preview: UIViewControllerRepresentable {
		
		let viewController: UIViewController

		func makeUIViewController(context: Context) -> UIViewController { viewController }

		func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
	}

	var preview: some View {
		Preview(viewController: self)
	}
}
#endif
