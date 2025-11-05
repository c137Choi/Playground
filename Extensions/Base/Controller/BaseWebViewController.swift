//
//  BaseWebViewController.swift
//
//  Created by Choi on 2022/8/25.
//

import UIKit
import WebKit

class BaseWebViewController: BaseViewController, WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {
    
    lazy var webview = makeWebView()
    
    lazy var progressView = UIProgressView(progressViewStyle: .bar)
    
    var fixedTitle: String? {
        willSet { title = newValue }
    }
    
    private var titleObservation: NSKeyValueObservation?
    private var progressObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(webview, progressView)
        
        /// 观察网页标题
        titleObservation = webview.observe(\.title, options: .live) {
            [unowned self] web, change in
            guard let webTitle = change.newValue else { return }
            title = webTitle.nonEmptyStringOrNil ?? fixedTitle
        }
        
        /// 观察网页加载进度
        progressObservation = webview.observe(\.estimatedProgress, options: .live) {
            [unowned self] web, change in
            guard let progress = change.newValue else {
                progressView.isHidden = true
                return
            }
            progressView.progress = Float(progress)
            progressView.isHidden = progress == 1.0
        }
    }
    
    override func updateViewConstraints() {
        webview.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        progressView.snp.remakeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(1.0)
        }
        super.updateViewConstraints()
    }
    
    func makeWebView() -> WKWebView {
//        /// 适配文字大小
//        let js = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
//        let userScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//
//        let userContentController = WKUserContentController()
//        userContentController.addUserScript(userScript)
        
        let config = WKWebViewConfiguration()
//        config.userContentController = userContentController
        config.preferences.minimumFontSize = 12.0
        if #available(iOS 13, *) {
            /// 适配手机页面
            let pref = WKWebpagePreferences()
            pref.preferredContentMode = .mobile
            config.defaultWebpagePreferences = pref
        }
        
        
        let webview = WKWebView(frame: .zero, configuration: config)
        webview.scrollView.delegate = self
        webview.isOpaque = false
        webview.backgroundColor = .white
        webview.uiDelegate = self
        webview.navigationDelegate = self
        webview.allowsBackForwardNavigationGestures = true
        return webview
    }
    
    override func goBack(animated: Bool = true) {
        if webview.canGoBack {
            webview.goBack()
        } else {
            super.goBack(animated: animated)
        }
    }
    
    deinit {
        titleObservation = nil
        progressObservation = nil
    }
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// 禁止水平方向回弹
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}

extension BaseWebViewController {
    
    convenience init(url: URL?, fixedTitle: String? = nil) {
        self.init()
        self.fixedTitle = fixedTitle
        self.load(url)
    }
    
    /// Webview背景颜色
    var webViewBackgroundColor: UIColor? {
        get { webview.backgroundColor }
        set { webview.backgroundColor = newValue }
    }
    
    /// 网页背景颜色
    var webBackgroundColor: UIColor? {
        get { webview.scrollView.backgroundColor }
        set { webview.scrollView.backgroundColor = newValue }
    }
    
    func load(clearCache: Bool = true, @SingleValueBuilder<URL?> buildURL: () -> URL?) {
        load(buildURL(), clearCache: clearCache)
    }
    
    /// 加载地址
    /// - Parameters:
    ///   - url: 地址
    ///   - clearCache: 是否先执行清除缓存操作
    func load(_ url: URL?, clearCache: Bool = true) {
        guard let url else {
            return trackError("无法加载")
        }
        /// 如果需要的话,清除缓存
        if clearCache {
            self.clearCache()
        }
        /// 请求网页
        let request = URLRequest(url: url)
        webview.load(request)
    }
    
    /// 清除缓存
    func clearCache() {
        let allTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let dataStore = WKWebsiteDataStore.default()
        dataStore.removeData(ofTypes: allTypes, modifiedSince: .distantPast) {}
    }
}
