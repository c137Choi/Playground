//
//  ImpactColor.swift
//  KnowLED
//
//  Created by Choi on 2026/5/25.
//

struct ImpactColor {
    private var _rgb: RGB
    private var _cmy: CMY
    private var _hsi: HSI
    private var _xy: XY
    
    init(cct: CCT) {
        self.init(rgb: cct.rgb)
    }
    
    init(rgb: RGB) {
        _rgb = rgb
        _cmy = rgb.cmy
        _hsi = rgb.hsi
        _xy = rgb.xy
    }
    
    init(cmy: CMY) {
        let rgb = cmy.rgb
        _rgb = rgb
        _cmy = cmy
        _hsi = rgb.hsi
        _xy = rgb.xy
    }
    
    init(hsi: HSI) {
        let rgb = hsi.rgb
        _rgb = rgb
        _cmy = rgb.cmy
        _hsi = hsi
        _xy = rgb.xy
    }
}

extension ImpactColor {
    
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
