//
//  UIColorExtension.swift
//  ControlHealth
//
//  Created by beta on 27/01/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

public extension UIColor {
    /**
     The shorthand three-digit hexadecimal representation of color.
     #RGB defines to the color #RRGGBB.

     - parameter hex3: Three-digit hexadecimal value.
     - parameter alpha: 0.0 - 1.0. The default is 1.0.
     */
    convenience init(hex3: UInt16, alpha: CGFloat = 1) {
        let divisor = CGFloat(15)
        let red = CGFloat((hex3 & 0xF00) >> 8) / divisor
        let green = CGFloat((hex3 & 0x0F0) >> 4) / divisor
        let blue = CGFloat(hex3 & 0x00F) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /**
     The shorthand four-digit hexadecimal representation of color with alpha.
     #RGBA defines to the color #RRGGBBAA.

     - parameter hex4: Four-digit hexadecimal value.
     */
    convenience init(hex4: UInt16) {
        let divisor = CGFloat(15)
        let red = CGFloat((hex4 & 0xF000) >> 12) / divisor
        let green = CGFloat((hex4 & 0x0F00) >> 8) / divisor
        let blue = CGFloat((hex4 & 0x00F0) >> 4) / divisor
        let alpha = CGFloat(hex4 & 0x000F) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /**
     The six-digit hexadecimal representation of color of the form #RRGGBB.

     - parameter hex6: Six-digit hexadecimal value.
     */
    convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green = CGFloat((hex6 & 0x00FF00) >> 8) / divisor
        let blue = CGFloat(hex6 & 0x0000FF) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /**
     The six-digit hexadecimal representation of color with alpha of the form #RRGGBBAA.

     - parameter hex8: Eight-digit hexadecimal value.
     */
    convenience init(hex8: UInt32) {
        let divisor = CGFloat(255)
        let red = CGFloat((hex8 & 0xFF00_0000) >> 24) / divisor
        let green = CGFloat((hex8 & 0x00FF_0000) >> 16) / divisor
        let blue = CGFloat((hex8 & 0x0000_FF00) >> 8) / divisor
        let alpha = CGFloat(hex8 & 0x0000_00FF) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /**
     The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, fails to nil.

     - parameter rgba: String value.
     */
    static func hex(_ rgba: String?) -> UIColor? {
        if let value = rgba {
            return hex(value)
        }
        return nil
    }

    /**
     The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, fails to nil.

     - parameter rgba: String value.
     */
    static func hex(_ rgba: String) -> UIColor? {
        guard rgba.hasPrefix("#") else {
            return nil
        }

        let hexString: String = String(rgba[String.Index(encodedOffset: 1)...])
        var hexValue: UInt32 = 0

        guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
            return nil
        }

        let color: UIColor?
        switch hexString.count {
        case 3:
            color = UIColor(hex3: UInt16(hexValue))
        case 4:
            color = UIColor(hex4: UInt16(hexValue))
        case 6:
            color = UIColor(hex6: hexValue)
        case 8:
            color = UIColor(hex8: hexValue)
        default:
            color = nil
        }

        return color
    }

    /**
     The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB, fails to default color.

     - parameter rgba: String value.
     */
    convenience init(_ rgba: String, defaultColor: UIColor = UIColor.clear) {
        guard rgba.hasPrefix("#") else {
            self.init(cgColor: defaultColor.cgColor)
            return
        }

        let hexString: String = String(rgba[String.Index(encodedOffset: 1)...])
        var hexValue: UInt32 = 0

        guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
            self.init(cgColor: defaultColor.cgColor)
            return
        }

        switch hexString.count {
        case 3:
            self.init(hex3: UInt16(hexValue))
        case 4:
            self.init(hex4: UInt16(hexValue))
        case 6:
            self.init(hex6: hexValue)
        case 8:
            self.init(hex8: hexValue)
        default:
            self.init(cgColor: defaultColor.cgColor)
            return
        }
    }

    /**
     Hex string of a UIColor instance, fails to empty string.

     - parameter includeAlpha: Whether the alpha should be included.
     */
    func hexString(_ includeAlpha: Bool = true) throws -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)

        guard r >= 0, r <= 1, g >= 0, g <= 1, b >= 0, b <= 1 else {
            assertionFailure()
            return ""
        }

        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
        } else {
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
    }
}

/*
 public extension UIColor {
 // MARK: - RGB

 static func rgb(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> UIColor {
 let r = CGFloat(r)
 let g = CGFloat(g)
 let b = CGFloat(b)
 let divider: CGFloat = 255

 return UIColor(red: r / divider, green: g / divider, blue: b / divider, alpha: a)
 }

 @available(iOS 10.0, *)
 static func rgbP3(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> UIColor {
 let r = CGFloat(r)
 let g = CGFloat(g)
 let b = CGFloat(b)
 let divider: CGFloat = 255

 return UIColor(displayP3Red: r / divider, green: g / divider, blue: b / divider, alpha: a)
 }

 // MARK: - HEX

 static func hex(_ hex: Int, _ a: CGFloat = 1) -> UIColor {
 let r = (hex >> 16) & 0xFF
 let g = (hex >> 8) & 0xFF
 let b = (hex >> 0) & 0xFF

 return UIColor.rgb(r, g, b, a)
 }

 static func hex(_ string: String, _ a: CGFloat = 1) -> UIColor {
 let hex = Int(string, radix: 16) ?? 0

 let r = (hex >> 16) & 0xFF
 let g = (hex >> 8) & 0xFF
 let b = (hex >> 0) & 0xFF

 return UIColor.rgb(r, g, b, a)
 }

 @available(iOS 10.0, *)
 static func hexP3(_ hex: Int, _ a: CGFloat = 1) -> UIColor {
 let r = (hex >> 16) & 0xFF
 let g = (hex >> 8) & 0xFF
 let b = (hex >> 0) & 0xFF

 return UIColor.rgbP3(r, g, b, a)
 }

 @available(iOS 10.0, *)
 static func hexP3(_ string: String, _ a: CGFloat = 1) -> UIColor {
 let hex = Int(string, radix: 16) ?? 0

 let r = (hex >> 16) & 0xFF
 let g = (hex >> 8) & 0xFF
 let b = (hex >> 0) & 0xFF

 return UIColor.rgbP3(r, g, b, a)
 }
 }
 */
