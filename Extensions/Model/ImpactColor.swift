//
//  ImpactColor.swift
//  KnowLED
//
//  Created by Choi on 2026/5/25.
//

import UIKit

struct ImpactColor {
    private var _rgb: RGB
    private var _cmy: CMY
    private var _hsi: HSI
    private var _xy: XY
    
    init(cct: CCT) {
        self.init(rgb: cct.rgb)
    }
    
    init(red: Double, green: Double, blue: Double) {
        let rgb = RGB(red: red, green: green, blue: blue)
        self.init(rgb: rgb)
    }
    
    init(rgb: RGB) {
        _rgb = rgb
        _cmy = rgb.cmy
        _hsi = rgb.hsi
        _xy = rgb.xy
    }
    
    init(cyan: Double, magenta: Double, yellow: Double) {
        let cmy = CMY(cyan: cyan, magenta: magenta, yellow: yellow)
        self.init(cmy: cmy)
    }
    
    init(cmy: CMY) {
        let rgb = cmy.rgb
        _rgb = rgb
        _cmy = cmy
        _hsi = rgb.hsi
        _xy = rgb.xy
    }
    
    init(hue: Double, saturation: Double) {
        let hsi = HSI(hue: hue, saturation: saturation, brightness: 1.0)
        self.init(hsi: hsi)
    }
    
    init(hsi: HSI) {
        let rgb = hsi.rgb
        _rgb = rgb
        _cmy = rgb.cmy
        _hsi = hsi
        _xy = rgb.xy
    }
    
    init(x: Double, y: Double) {
        let xy = XY(x: x, y: y)
        self.init(xy: xy)
    }
    
    init(xy: XY) {
        let rgb = RGB(xy: xy)
        _rgb = rgb
        _cmy = rgb.cmy
        _hsi = rgb.hsi
        _xy = xy
    }
}

extension ImpactColor: Configurable {}
extension ImpactColor: CustomDebugStringConvertible {
    var debugDescription: String {
        rgb.debugDescription
    }
}

extension ImpactColor {
    
    var maxBrightness: ImpactColor {
        with(new: \.brightness, 1.0)
    }
    
    var uiColor: UIColor {
        UIColor(rgb: rgb)
    }
    
    var red: Double {
        get { rgb.red }
        set { rgb.red = newValue }
    }
    
    var green: Double {
        get { rgb.green }
        set { rgb.green = newValue }
    }
    
    var blue: Double {
        get { rgb.blue }
        set { rgb.blue = newValue }
    }
    
    var cyan: Double {
        get { cmy.cyan }
        set { cmy.cyan = newValue }
    }
    
    var magenta: Double {
        get { cmy.magenta }
        set { cmy.magenta = newValue }
    }
    
    var yellow: Double {
        get { cmy.yellow }
        set { cmy.yellow = newValue }
    }
    
    var hue: Double {
        get { hsi.hue }
        set { hsi.hue = newValue }
    }
    
    var saturation: Double {
        get { hsi.saturation }
        set { hsi.saturation = newValue }
    }
    
    var brightness: Double {
        get { hsi.brightness }
        set { hsi.brightness = newValue }
    }
    
    var x: Double {
        xy.x
    }
    
    var y: Double {
        xy.y
    }
    
    var rgb: RGB {
        get { _rgb }
        set {
            _rgb = newValue
            _cmy = newValue.cmy
            _hsi = newValue.hsi
            _xy = newValue.xy
        }
    }
    
    var cmy: CMY {
        get { _cmy }
        set {
            let rgb = newValue.rgb
            _rgb = rgb
            _cmy = newValue
            _hsi = rgb.hsi
            _xy = rgb.xy
        }
    }
    
    var hsi: HSI {
        get { _hsi }
        set {
            let rgb = newValue.rgb
            _rgb = rgb
            _cmy = rgb.cmy
            _hsi = newValue
            _xy = rgb.xy
        }
    }
    
    var xy: XY {
        _xy
    }
}
