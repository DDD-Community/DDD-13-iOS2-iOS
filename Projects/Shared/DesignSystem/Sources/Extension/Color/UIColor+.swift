//
//  UIColor+.swift
//  DDDAttendance
//
//  Created by DDD-iOS2 on 4/7/26.
//

import UIKit

public extension UIColor {
  convenience init(hex: String, alpha: Double? = .zero) {
    let scanner = Scanner(string: hex)
    _ = scanner.scanString("#")
    
    var rgb: UInt64 = 0
    scanner.scanHexInt64(&rgb)
    
    let r = Double((rgb >> 16) & 0xFF) / 255.0
    let g = Double((rgb >>  8) & 0xFF) / 255.0
    let b = Double((rgb >>  0) & 0xFF) / 255.0
    self.init(red: r, green: g, blue: b, alpha: 100)
  }
}
