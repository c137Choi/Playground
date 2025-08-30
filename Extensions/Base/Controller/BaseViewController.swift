//
//  BaseViewController.swift
//  ExtensionDemo
//
//  Created by Choi on 2022/5/31.
//  Copyright © 2022 Choi. All rights reserved.
//

import UIKit
import QMUIKit
import Photos
import PhotosUI
import RxSwift
import RxCocoa

// MARK: - 控制器配置协议
protocol ViewControllerConfiguration: UIViewController {

	/// 默认标题
	var defaultTitle: String? { get }
	
	/// 大标题导航栏
	var preferLargeTitles: Bool { get }
	
	/// 控制器配置 | 调用时机: init
	func initialConfigure()
	
	/// 配置导航条目 | 调用时机: viewWillAppear
	func configureNavigationItem(_ navigationItem: UINavigationItem)
	
	/// 配置导航栏样式 | 调用时机: viewWillAppear
	/// - Parameter navigationController: 导航控制器
	func configureNavigationController(_ navigationController: UINavigationController)
}

enum NavigationBarStyle {
    /// 毛玻璃效果(默认)
    case `default`
    /// 不透明
    case opaqueBackground
    /// 全透明
    case transparentBackground
}

// MARK: - 基类控制器
class BaseViewController: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ViewControllerConfiguration, ErrorTracker, ActivityTracker {
	
    lazy var presentor = ControllerPresentor(presentingController: self)
    
    var targetImageSize: CGSize?
    
    /// 是否始终在导航栏右侧显示关闭按钮 | 点击后dismiss导航控制器或自身
    var alwaysShowDismissButton = false
    
    var defaultMainView: UIView? { nil }
    
    /// The image should defined as a global computed property in each project.
    private(set) lazy var backBarButtonItem = UIBarButtonItem(
        image: backBarButtonImage,
        style: .plain,
        target: self,
        action: #selector(leftBarButtonItemTriggered))
    
    /// The image should defined as a global computed property in each project.
    private(set) lazy var closeBarButtonItem = UIBarButtonItem(
        image: closeBarButtonImage,
        style: .plain,
        target: self,
        action: #selector(leftBarButtonItemTriggered))
    
    /// The image should defined as a global computed property in each project.
    private(set) lazy var dismissBarButtonItem = UIBarButtonItem(
        image: closeBarButtonImage,
        style: .plain,
        target: self,
        action: #selector(dismissNavigationControllerOrSelf))
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initialConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialConfigure()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        defaultStatusBarStyle
    }
    
    override func loadView() {
        if let defaultMainView {
            view = defaultMainView
        } else {
            super.loadView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// view loaded 之后的配置
        afterViewLoadedConfigure()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		/// 配置导航控制器
		if let navigationController = navigationController {
			configureNavigationController(navigationController)
		}
        
        configureNavigationItem(navigationItem)
	}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    /// 默认标题
    var defaultTitle: String? { .none }
    
    /// 大标题导航栏
    var preferLargeTitles: Bool { false }
    
    /// 是否显示导航栏
    var doHideNavigationBar: Bool { false }
    
    /// 默认的导航栏样式
    var defaultNavigationBarStyle: NavigationBarStyle { navigationBarStyle }
    
    /// 导航栏分割线颜色
    var defaultNavigationBarShadowColor: UIColor? {
        navigationBarShadowColor
    }
    
    /// 默认的导航栏背景色; 如果为空则使用defaultNavigationBarStyle的样式
    var defaultNavigationBarBackgroundColor: UIColor? { navigationBarBackgroundColor }
    
    /// 是否可以返回
    var isBackAvailable = true
    
    /// 不能返回时给出的提示
    var tipsForBackUnavailable: String?
    
    /// 控制器配置 | 调用时机: init
    func initialConfigure() {
        
        /// 导航控制器压栈时默认隐藏TabBar, 首页的几个RootController单独设置此属性为false
        /// 注: 此属性只有在控制器放入Navigation Stack之前设置才有效
        hidesBottomBarWhenPushed = true
    }
    
    /// viewDidLoad之后的配置 | 调用时机: viewDidLoad
    func afterViewLoadedConfigure() {
        /// 配置标题
        if title == .none, let defaultTitle = defaultTitle {
            title = defaultTitle
        }
        
        /// 配置Targets
        prepareTargets()
    }
    
    /// 配置导航条目 | 调用时机: viewWillAppear
    func configureNavigationItem(_ navigationItem: UINavigationItem) {
        /// 大标题模式
        navigationItem.largeTitleDisplayMode = preferLargeTitles ? .automatic : .never
        /// 在导航控制器中
        if let navigationController = navigationController {
            /// 被present出来的
            lazy var isPresented = presentingViewController != nil
            /// 是子控制器(被父控制器添加为子控制器)
            lazy var isChildController = parent != nil
            /// 至少2个视图控制器
            lazy var moreThanOneViewController = navigationController.viewControllers.count > 1
            /// 单个视图控制器
            lazy var singleViewController = navigationController.viewControllers.count == 1
            /// 根据条件判断按钮显示/隐藏
            if moreThanOneViewController {
                navigationItem.leftBarButtonItem = backBarButtonItem
                if alwaysShowDismissButton {
                    navigationItem.rightBarButtonItem = dismissBarButtonItem
                }
            }
            /// 导航栏(单个控制器) 且自己是被present出来的或父控制器非空(父控制器添加子控制器)
            else if singleViewController && (isPresented || isChildController) {
                if alwaysShowDismissButton {
                    navigationItem.rightBarButtonItem = dismissBarButtonItem
                } else {
                    navigationItem.leftBarButtonItem = closeBarButtonItem
                }
            }
        }
    }
    
    /// 配置导航栏样式 | 调用时机: viewWillAppear
    /// - Parameter navigationController: 导航控制器
    func configureNavigationController(_ navigationController: UINavigationController) {
        
        /// 控制导航栏是否显示
        navigationController.setNavigationBarHidden(doHideNavigationBar, animated: true)
        
        /// 重新开启右滑返回(禁用) | 这种写法会导致有时push了控制器但是没显示的问题
        /// 替换方案: 重写QMUI的 forceEnableInteractivePopGestureRecognizer() 方法
//        navigationController.interactivePopGestureRecognizer?.delegate = self
//        navigationController.interactivePopGestureRecognizer?.isEnabled = true
//        navigationController.delegate = self
        
        let navigationBar = navigationController.navigationBar
        /// 导航栏会根据navigationItem.largeTitleDisplayMode显示大标题样式
        navigationBar.prefersLargeTitles = true
        
        if #available(iOS 13, *) {
            /// 配置样式
            let navBarAppearance = UINavigationBarAppearance(idiom: .phone)
            configureNavigationBarAppearance(navBarAppearance)
            
            /// 配置导航按钮样式
            let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
            barButtonItemAppearance.normal.titleTextAttributes = [:]
            barButtonItemAppearance.highlighted.titleTextAttributes = [:]
            barButtonItemAppearance.disabled.titleTextAttributes = [:]
            
            navBarAppearance.buttonAppearance = barButtonItemAppearance
            navBarAppearance.backButtonAppearance = barButtonItemAppearance
            navBarAppearance.doneButtonAppearance = barButtonItemAppearance
            
            /// 配置导航栏
            /// Represents a navigation bar in regular height without a large title.
            /// 其他两个属性使用这个当做默认值
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.compactAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
            func globalConfigure() {
                let appearance = UINavigationBar.appearance()
                appearance.standardAppearance = navBarAppearance
                appearance.compactAppearance = navBarAppearance
                appearance.scrollEdgeAppearance = navBarAppearance
            }
        } else {
            configureNavigationBar(navigationBar)
        }
    }
    
    @available(iOS 13, *)
    func configureNavigationBarAppearance(_ barAppearance: UINavigationBarAppearance) {
        
        /// 设置导航栏样式
        switch defaultNavigationBarStyle {
        case .default:
            barAppearance.configureWithDefaultBackground() /// 毛玻璃效果(默认)
        case .opaqueBackground:
            barAppearance.configureWithOpaqueBackground() /// 不透明
        case .transparentBackground:
            barAppearance.configureWithTransparentBackground() /// 全透明
        }
        
        /// 隐藏分割线
        barAppearance.shadowColor = defaultNavigationBarShadowColor
        
        /// 设置返回按钮图片
        barAppearance.setBackIndicatorImage(nil, transitionMaskImage: nil)
        
        /// This will result in true color, just like when you set barTintColor with isTranslucent = false.
        if let defaultNavigationBarBackgroundColor = defaultNavigationBarBackgroundColor {
            barAppearance.backgroundColor = defaultNavigationBarBackgroundColor
        }
        
        /// 调整Title位置
        barAppearance.titlePositionAdjustment = navigationTitlePositionAdjustment
        
        /// 设置大标题属性
        var largeTitleTextAttributes: [NSAttributedString.Key: Any] = [:]
        largeTitleTextAttributes[.foregroundColor] = navigationLargeTitleColor
        largeTitleTextAttributes[.font] = navigationLargeTitleFont
        barAppearance.largeTitleTextAttributes = largeTitleTextAttributes
        
        /// 设置标题属性
        var titleTextAttributes: [NSAttributedString.Key: Any] = [:]
        titleTextAttributes[.foregroundColor] = navigationTitleColor
        titleTextAttributes[.font] = navigationTitleFont
        barAppearance.titleTextAttributes = titleTextAttributes
        
        //barAppearance.backgroundImage
        //barAppearance.backgroundEffect
        //barAppearance.backgroundImageContentMode
    }
    
    func configureNavigationBar(_ navigationBar: UINavigationBar) {
        lazy var emptyImage = UIImage()
        /// 设置返回按钮图片
        navigationBar.backIndicatorImage = nil
        /// The image used as a mask for content during push and pop transitions.
        navigationBar.backIndicatorTransitionMaskImage = nil
        /// 导航栏全透明
        navigationBar.setBackgroundImage(emptyImage, for: .default)
        navigationBar.shadowImage = emptyImage
        navigationBar.isTranslucent = true
        func transparentBarGlobally() {
            let barAppearance = UINavigationBar.appearance()
            barAppearance.setBackgroundImage(emptyImage, for: .default)
            barAppearance.shadowImage = emptyImage
            barAppearance.isTranslucent = true
        }
    }
    
    
    /// 添加事件
    /// 调用时机: viewDidload -> afterViewLoadedConfigure
    func prepareTargets() {
        rx.disposeBag.insert {
            UIApplication.shared.rx.latestKeyboardPresentation.bindErrorIgnored {
                [unowned self] presentation in
                keyboardPresentation(presentation)
            }
        }
    }
    
    func keyboardPresentation(_ presentation: KeyboardPresentation) {}
    
    @objc func leftBarButtonItemTriggered() {
        escape(animated: true)
    }
    
    /// 开启可返回
    func enableBack() {
        makeIsBackAvailable(true)
    }
    
    /// 关闭可返回
    func disableBack() {
        makeIsBackAvailable(false)
    }
    
    /// 调整可否返回
    /// - Parameter available: 是否可返回
    private func makeIsBackAvailable(_ available: Bool) {
        isBackAvailable = available
    }
    
    /// 检查是否可以返回
    /// - Returns: 是否可返回
    private func checkIsBackAvailable() -> Bool {
        guard isBackAvailable else {
            if let tipsForBackUnavailable {
                popToast(tipsForBackUnavailable)
            }
            return false
        }
        return isBackAvailable
    }
    
    /// 有导航控制器的时候返回 | 没有导航控制的时候执行dismiss
    @objc func escape(animated: Bool = true) {
        guard checkIsBackAvailable() else {
            return
        }
        if let navigationController {
            if navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: animated)
            } else if navigationController.presentingViewController != .none {
                navigationController.dismiss(animated: animated)
            }
        } else {
            dismiss(animated: animated)
        }
    }
    
    @objc func dismissNavigationControllerOrSelf() {
        close(animated: true, completion: nil)
    }
    
    @objc func close(animated: Bool = true, completion: SimpleCallback? = nil) {
        if let navigationController = navigationController {
            navigationController.dismiss(animated: animated, completion: completion)
        } else {
            dismiss(animated: animated, completion: completion)
        }
    }
    
    @objc func goBack(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func didGetImages(_ imageItems: [ImageItem]) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        /// 原始图片
        guard var image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        /// 编辑过的图片
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        }
        
        if let preferredImageSize = targetImageSize {
            if let resized = image.qmui_imageResized(inLimitedSize: preferredImageSize, resizingMode: .scaleAspectFit, scale: UIScreen.main.scale) {
                image = resized
            }
        }
        var imageItem = ImageItem(image: image)
        if let imageURL = info[.imageURL] as? URL {
            imageItem.imageURL = imageURL
        }
        didGetImages([imageItem])
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func trackError(_ error: Error?, isFatal: Bool = true) {
        guard let error else { return }
        if isFatal {
            view.popFailToast(error.localizedDescription)
        } else {
            view.popToast(error.localizedDescription)
        }
    }
    
    func trackActivity(_ isProcessing: Bool) {
        if isProcessing {
            view.makeToastActivity(.center)
        } else {
            view.hideToastActivity()
        }
    }
    
    override func forceEnableInteractivePopGestureRecognizer() -> Bool {
        isBackAvailable
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension BaseViewController {
    
    var latestMessage: String? {
        get { nil }
        set {
            popToast(newValue)
        }
    }
    
    /// 弹出相机授权失败对话框
    /// - Parameter title: 相应的标题,提示具体使用相机的用途
    func popCameraAccessDeniedDialog(title: String) {
        presentor.popDialog {
            AlertDialog(
                title: title,
                message: NSLocalizedString("是否打开权限设置页面?", comment: "")) {
                    DialogAction.cancel
                    DialogAction(title: NSLocalizedString("是", comment: "")) {
                        UIApplication.openSettings()
                    }
                }
        }
    }
    
    func popToast(_ message: String?) {
        view.popToast(message)
    }
    
    func fetchPhotos(count: Int = 1, targetImageSize: CGSize? = nil, allowsEditing: Bool = false) {
        self.targetImageSize = targetImageSize
        let sheet = ActionSheetController {
            DialogAction(title: NSLocalizedString("相册", comment: "")) {
                [unowned self] in getPhotos(count: count, from: .photoLibrary, allowsEditing: allowsEditing)
            }
            DialogAction(title: NSLocalizedString("拍照", comment: "")) {
                [unowned self] in getPhotos(count: 1, from: .camera, allowsEditing: allowsEditing)
            }
        }
        presentor.slideIn(sheet)
    }
    
    func getPhotos(count: Int, from source: UIImagePickerController.SourceType, allowsEditing: Bool = false) {
        /// 检查图片源是否可用
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            trackError("Not supported source type.")
            return
        }
        
        /// 拍照 | 旧版图片选择控制器
        let pickPhotoFrom: (UIImagePickerController.SourceType) -> Void = {
            [unowned self] imageSource in
            let picker = UIImagePickerController()
            picker.sourceType = imageSource
            picker.allowsEditing = allowsEditing
            picker.delegate = self
            picker.modalPresentationStyle = UIDevice.current.userInterfaceIdiom == .phone ? .fullScreen : .pageSheet
            present(picker, animated: true)
        }
        
        /// 显示图片选择器
        let showPickerController = {
            pickPhotoFrom(source)
            return
//            if #available(iOS 14, *) {
//                let photoLibrary = PHPhotoLibrary.shared()
//                var config = PHPickerConfiguration(photoLibrary: photoLibrary)
//                config.filter = .images
//                config.selectionLimit = count
//                config.preferredAssetRepresentationMode = .automatic
//                if #available(iOS 15.0, *) {
//                    config.preselectedAssetIdentifiers = []
//                }
//
//                let picker = PHPickerViewController(configuration: config)
//                picker.modalPresentationStyle = UIDevice.current.userInterfaceIdiom == .phone ? .fullScreen : .pageSheet
//                picker.delegate = self
//                self.present(picker, animated: true)
//            } else {
//                pickPhotoFrom(source)
//            }
        }
        
        switch source {
        case .camera:
            rx.disposeBag.insert {
                AVAuthorizationStatus.checkValidVideoStatus
                    .subscribe(with: self) { weakSelf, status in
                        pickPhotoFrom(source)
                    } onError: { weakSelf, error in
                        weakSelf.popCameraAccessDeniedDialog(title: error.localizedDescription)
                    }
            }
        case .photoLibrary, .savedPhotosAlbum:
            rx.disposeBag.insert {
                PHPhotoLibrary.chekValidAuthorizationStatus
                    .trackError(self)
                    .then(blockByError: true, sink(showPickerController))

            }
        @unknown default:
            break
        }
    }
}

extension BaseViewController: PHPickerViewControllerDelegate {
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        guard results.isNotEmpty else {
            DispatchQueue.main.async {
                picker.dismiss(animated: true)
            }
            return
        }
        DispatchQueue.main.async {
            QMUITips.showLoading("正在处理", in: picker.view)
        }
        let imageURLs: [URL] = []
        var precessedImage = 0
        func doneProcess() {
            precessedImage += 1
            if precessedImage == results.count {
                /// 主线程调用
                DispatchQueue.main.async {
                    /// 隐藏提示
                    QMUITips.hideAllTips(in: picker.view)
                    let items = imageURLs.map { url in
                        ImageItem(imageURL: url)
                    }
                    /// 传回图片
                    self.didGetImages(items)
                    picker.dismiss(animated: true)
                }
            }
        }
        
        DispatchQueue.global().async {
            do {
                var imageItems: [ImageItem] = []
                let semaphore = DispatchSemaphore(value: 0)
                for result in results {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                        if let image = object as? UIImage {
                            let item = ImageItem(image: image)
                            imageItems.append(item)
                        }
                        semaphore.signal()
                    }
                    semaphore.wait()
                }
                DispatchQueue.main.async {
                    /// 隐藏提示
                    QMUITips.hideAllTips(in: picker.view)
                    self.didGetImages(imageItems)
                    picker.dismiss(animated: true)
                }
            }
            
//            /// 方法2
//            do {
//                let identifiers = results.compactMap(\.assetIdentifier)
//                let finalResult: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
//                finalResult.enumerateObjects { asset, index, tag in
//                    let resources = PHAssetResource.assetResources(for: asset)
//                    if let first = resources.first, let url = first.value(forKey: "privateFileURL") as? URL {
//                        imageURLs.append(url)
//                    }
//                    doneProcess()
//                }
//            }
            
//            /// 方法3
//            do {
//                for result in results {
//                    let itemProvider = result.itemProvider
//                    /// In this code, the order of the UTType check is deliberate(故意的).
//                    /// A live photo can be supplied in a simple UIImage representation, so if we test for images before live photos, we won’t learn that the result is a live photo.
//                    if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
//                        // it's a video
//                    } else if itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
//                        // it's a live photo
//                    } else if itemProvider.canLoadObject(ofClass: UIImage.self) {
//                        // it's a photo
//                        let commonImageTypes: [UTType] = [.jpeg, .png, .heic, .heif]
//                        var iterator = commonImageTypes.makeIterator()
//                        var notFound = true
//                        while let imageType = iterator.next(), notFound {
//                            let semaphore = DispatchSemaphore(value: 0)
//                            itemProvider.loadFileRepresentation(forTypeIdentifier: imageType.identifier) { url, error in
//                                dprint("haha", url.asAny)
//                            }
//                            itemProvider.loadInPlaceFileRepresentation(forTypeIdentifier: imageType.identifier) { url, flag, error in
//                                if let validURL = url {
//                                    imageURLs.append(validURL)
//                                    notFound = false
//                                    doneProcess()
//                                } else {
//                                    dprint("无法处理")
//                                }
//                                semaphore.signal()
//                            }
//                            semaphore.wait()
//                        }
//                    }
//                }
//            }
        }
    }
}
