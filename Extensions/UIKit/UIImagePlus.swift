//
//  UIImagePlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2020/7/29.
//  Copyright © 2020 Choi. All rights reserved.
//

import UIKit
import Photos
import SpriteKit

extension UIImage {
    
    public convenience init?(base64Encoded base64String: String) {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        self.init(data: data, scale: 1.0)
    }
    
    public convenience init?(qrContent: String?, size: CGFloat = 300.0) {
        guard let qrContent else { return nil }
        let data = qrContent.data(using: .utf8)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        /// 设置数据
        filter.setValue(data, forKey: "inputMessage")
        /// 设置容错率 (L: 7%, M: 15%, Q: 25%, H: 30%).
        filter.setValue("M", forKey: "inputCorrectionLevel")
        /// 生成图片
        guard let ciImage = filter.outputImage else { return nil }
        /// 调整大小
        let scaleX = size / ciImage.extent.size.width
        let scaleY = size / ciImage.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleX,y: scaleY)
        let transformed = ciImage.transformed(by: transform)
        /// 这里必须转换一下否则无法保存到相册
        if #available(iOS 17.0, *) {
            guard let heicData = UIImage(ciImage: transformed).heicData() else { return nil }
            self.init(data: heicData)
        } else {
            guard let pngData = UIImage(ciImage: transformed).pngData() else { return nil }
            self.init(data: pngData)
        }
    }
    
    /// 源SVG图片要显示到MTKView上时需要重绘
    var pngImage: UIImage? {
        let canvas = CGRect(origin: .zero, size: size)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.preferredRange = .extended
        let renderer = UIGraphicsImageRenderer(bounds: canvas, format: format)
        let pngData = renderer.pngData { _ in
            self.draw(in: canvas)
        }
        return UIImage(data: pngData)
    }
    
    var skTexture: SKTexture {
        SKTexture(image: self)
    }
    
    /// SwifterSwift: Average color for this image.
    var averageColor: UIColor? {
        // https://stackoverflow.com/questions/26330924
        guard let ciImage = ciImage ?? CIImage(image: self) else { return nil }
        
        // CIAreaAverage returns a single-pixel image that contains the average color for a given region of an image.
        let parameters = [kCIInputImageKey: ciImage, kCIInputExtentKey: CIVector(cgRect: ciImage.extent)]
        guard let outputImage = CIFilter(name: "CIAreaAverage", parameters: parameters)?.outputImage else {
            return nil
        }
        
        // After getting the single-pixel image from the filter extract pixel's RGBA8 data
        var bitmap = [UInt8](repeating: 0, count: 4)
        let workingColorSpace: Any = cgImage?.colorSpace ?? NSNull()
        let context = CIContext(options: [.workingColorSpace: workingColorSpace])
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        // Convert pixel data to UIColor
        return UIColor(red: CGFloat(bitmap[0]) / 255.0,
                       green: CGFloat(bitmap[1]) / 255.0,
                       blue: CGFloat(bitmap[2]) / 255.0,
                       alpha: CGFloat(bitmap[3]) / 255.0)
    }
    
	/// 给图片着色
	/// - Parameters:
	///   - tintColor: 要改变的颜色
	///   - blendMode: 着色模式
	/// - Returns: 着色后的图片
	func imageWith(tintColor: UIColor, blendMode: CGBlendMode = .overlay) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
		defer {
			UIGraphicsEndImageContext()
		}
		// 定义画布
		let canvas = CGRect(origin: .zero, size: size)
		tintColor.setFill()
		UIRectFill(canvas)
		draw(in: canvas, blendMode: blendMode, alpha: 1.0)
		if blendMode != .destinationIn {
			draw(in: canvas, blendMode: .destinationIn, alpha: 1.0)
		}
		return UIGraphicsGetImageFromCurrentImageContext()
		/* 备注:
		因为每次使用此方法绘图时，都使用了CG的绘制方法
		这就意味着每次调用都会是用到CPU的Offscreen drawing
		大量使用的话可能导致性能的问题（主要对于iPhone 3GS或之前的设备，可能同时处理大量这样的绘制调用的能力会有不足）。
		原文地址: https://onevcat.com/2013/04/using-blending-in-ios/
		*/
	}
	
	//将图片缩放成指定尺寸（多余部分自动删除）
	func scaled(to newSize: CGSize) -> UIImage? {
		//计算比例
		let aspectWidth  = newSize.width/size.width
		let aspectHeight = newSize.height/size.height
		let aspectRatio = max(aspectWidth, aspectHeight)
		
		//图片绘制区域
		var canvas = CGRect.zero
		canvas.size.width  = size.width * aspectRatio
		canvas.size.height = size.height * aspectRatio
		canvas.origin.x = (newSize.width - size.width * aspectRatio) / 2.0
		canvas.origin.y = (newSize.height - size.height * aspectRatio) / 2.0
		
		//绘制并获取最终图片
		UIGraphicsBeginImageContext(newSize)
		defer {
			UIGraphicsEndImageContext()
		}
		draw(in: canvas)
		return UIGraphicsGetImageFromCurrentImageContext()
	}
	
	func saveToPhotoLibrary(completionHandler: @escaping (Bool, Error?) -> Void) {
		PHPhotoLibrary.shared().performChanges {
			PHAssetChangeRequest.creationRequestForAsset(from: self)
		} completionHandler: { result, error in
			DispatchQueue.main.async {
				completionHandler(result, error)
			}
		}
	}
	
	func image(with insets: UIEdgeInsets) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size + insets, false, scale)
		let origin = CGPoint(x: insets.left, y: insets.top)
		draw(at: origin)
		defer {
			UIGraphicsEndImageContext()
		}
		return UIGraphicsGetImageFromCurrentImageContext().or(self)
	}
	
	/// 启动图截图
	static var launchScreenSnapshot: UIImage? {
		guard let infoDict = Bundle.main.infoDictionary else { return .none }
		guard let nameValue = infoDict["UILaunchStoryboardName"] else { return .none }
		guard let name = nameValue as? String else { return .none }
		let storyboard = UIStoryboard(name: name, bundle: .none)
		guard let vc = storyboard.instantiateInitialViewController() else { return .none }
		let screenSize = UIScreen.main.bounds.size
		let screenScale = UIScreen.main.scale
		UIGraphicsBeginImageContextWithOptions(screenSize, false, screenScale)
		guard let context = UIGraphicsGetCurrentContext() else { return .none }
		vc.view.layer.render(in: context)
		return UIGraphicsGetImageFromCurrentImageContext()
	}
	
    var jpegCompressedData: Data? {
        jpegData(compressionQuality: 0.3)
    }
	
	/// 圆角图片(圆角
	var roundImage: UIImage? {
        roundImage(clipCorners: .allCorners, cornerRadius: nil)
	}
	
	/// 给图片加圆角
	func roundImage(clipCorners: UIRectCorner = .allCorners, cornerRadius: CGFloat? = nil) -> UIImage? {
        let scale = UIScreen.main.scale
        let isOpaque = false
        let maxCornerRadius = min(size.width, size.height) / 2.0
        let finalCornerRadius: CGFloat
        if let cornerRadius, cornerRadius > 0 && cornerRadius <= maxCornerRadius {
            finalCornerRadius = cornerRadius
        } else {
            finalCornerRadius = maxCornerRadius
        }
        if #available(iOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.scale = scale
            format.opaque = isOpaque
            /// 创建绘图渲染器
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            /// 使用PNG图片格式
            let pngData = renderer.pngData { context in
                let rect = CGRect(origin: .zero, size: self.size)
                let cornerSize = CGSize(width: finalCornerRadius, height: finalCornerRadius)
                UIBezierPath(roundedRect: rect, byRoundingCorners: clipCorners, cornerRadii: cornerSize).addClip()
                self.draw(in: rect)
            }
            /// 或者使用JPEG图片
            let _ = renderer.jpegData(withCompressionQuality: 1.0) { context in
                
            }
            return UIImage(data: pngData)
        } else {
            UIGraphicsBeginImageContextWithOptions(size, isOpaque, scale)
            defer {
                UIGraphicsEndImageContext()
            }
            let rect = CGRect(origin: .zero, size: size)
            let cornerSize = CGSize(width: finalCornerRadius, height: finalCornerRadius)
            UIBezierPath(roundedRect: rect, byRoundingCorners: clipCorners, cornerRadii: cornerSize).addClip()
            draw(in: rect)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
	}
}
