//
//  Utils.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/21/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class Utils {
    static func formatNumber(n: Int) -> String {
        if n >= 1000000 {
            let millions = Double(n)/1000000
            return String(format: "%.0fM", millions)
        } else if n >= 1000 {
            let thousands = Double(n)/1000
            return String(format: "%.1fK", thousands)
        } else {
            return String(n)
        }
    }
    
    static func downloadImage(url: String) -> UIImage? {
        let data = NSData(contentsOfURL: NSURL(string: url)!)
        if data != nil {
            return UIImage(data: data!)
        }
        return nil
    }
    
    static func hexToColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            let idx = cString.startIndex.advancedBy(1)
            cString = cString.substringFromIndex(idx)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
