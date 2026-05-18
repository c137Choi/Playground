//
//  ImpactColor.swift
//  KnowLED
//
//  Created by Choi on 2026/5/18.
//

struct ImpactColor {
    
    /// 红绿蓝
    var rgb: RGB {
        didSet {
            cmy = rgb.cmy
            hsi = rgb.hsi
        }
    }
    
    /// 青品黄
    var cmy: CMY {
        didSet {
            rgb = cmy.rgb
        }
    }
    
    /// 色相/饱和度
    var hsi: HSI {
        didSet {
            rgb = hsi.rgb
        }
    }
    
    init(rgb: RGB) {
        self.rgb = rgb
        self.cmy = rgb.cmy
        self.hsi = rgb.hsi
    }
    
    init(cmy: CMY) {
        self.init(rgb: cmy.rgb)
    }
    
    init(hsi: HSI) {
        self.init(rgb: hsi.rgb)
    }
}

extension ImpactColor {
    
    var brightness: Double {
        get { hsi.brightness }
        set { hsi.brightness = newValue }
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
}
