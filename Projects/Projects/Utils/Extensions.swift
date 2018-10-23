//
//  Extensions.swift
//  USGBC
//
//  Created by Pradheep Narendran on 15/02/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import UIKit
import RealmSwift

extension UIColor {
    static func hex (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

extension UILabel {
    func setHTMLFromString(htmlText: String) {
        let modifiedFont = NSString(format:"<span style=\"font-family: '\(self.font)'; font-size: \(self.font!.pointSize)\">%@</span>" as NSString, htmlText) as String
        
        
        //process collection values
        var attrStr = NSAttributedString()
        do {
         attrStr = try NSAttributedString(data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        }catch{
            attrStr = NSAttributedString.init(string: "")
        }
        
        self.attributedText = attrStr
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        
        return array
    }
}

extension String {
    
    static func mediumDateShortTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    static func mediumDateNoTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    static func fullDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full
        return dateFormatter.string(from: date)
    }
}

extension UIColor {
    
    class func formerColor() -> UIColor {
        return UIColor(red: 0.14, green: 0.16, blue: 0.22, alpha: 1)
    }
    
    class func formerSubColor() -> UIColor {
        return UIColor(red: 0.9, green: 0.55, blue: 0.08, alpha: 1)
    }
    
    class func formerHighlightedSubColor() -> UIColor {
        return UIColor(red: 1, green: 0.7, blue: 0.12, alpha: 1)
    }
}

extension NSDate {
    
    // -> Date System Formatted Medium
    func ToDateMediumString() -> NSString? {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self as Date) as NSString
    }
}

extension UIFont{
    class func gothamBold(size: CGFloat) -> UIFont{
        return UIFont(name: "Gotham-Bold", size: size)!
    }
    
    class func gothamMedium(size: CGFloat) -> UIFont{
        return UIFont(name: "Gotham-Medium", size: size)!
    }
    
    class func gothamBook(size: CGFloat) -> UIFont{
        return UIFont(name: "Gotham-Book", size: size)!
    }
    
    class func gothamThin(size: CGFloat) -> UIFont{
        return UIFont(name: "Gotham-Thin", size: size)!
    }
    
    class func gothamLight(size: CGFloat) -> UIFont{
        return UIFont(name: "Gotham-Light", size: size)!
    }
    
    class func AktivGrotesk_Bd(size: CGFloat) -> UIFont{
        return UIFont(name: "AktivGroteskTrial-Bold", size: size)!
    }
    
    class func AktivGrotesk_Blk(size: CGFloat) -> UIFont{
        return UIFont(name: "AktivGrotesk-Blk", size: size)!
    }
    
    class func AktivGrotesk_Hair(size: CGFloat) -> UIFont{
        return UIFont(name: "AktivGrotesk-Hair", size: size)!
    }
    
    class func AktivGrotesk_Lt(size: CGFloat) -> UIFont{
        return UIFont(name: "AktivGrotesk-Lt", size: size)!
    }
    
    class func AktivGrotesk_Md(size: CGFloat) -> UIFont{
        return UIFont(name: "AktivGroteskTrial-Medium", size: size)!
    }
    
    class func AktivGrotesk_Rg(size: CGFloat) -> UIFont{
        return UIFont(name: "AktivGroteskTrial-Regular", size: size)!
    }
    
    class func AktivGrotesk_Th(size: CGFloat) -> UIFont{
        return UIFont(name: "AktivGrotesk-Th", size: size)!
    }
    class func AktivGrotesk_XBd(size: CGFloat) -> UIFont{
        return UIFont(name: "AktivGrotesk-XBd", size: size)!
    }
    class func AktivGroteskCd_Blk(size: CGFloat) -> UIFont{
        return UIFont(name: "AktivGroteskCd-Blk", size: size)!
    }

    
    /*AktivGroteskCd-Hair.ttf
    AktivGroteskCd-Lt.ttf
    AktivGroteskCd-Md.ttf
    AktivGroteskCd-Rg.ttf
    AktivGroteskCd-Th.ttf
    AktivGroteskCd-XBd.ttf
    AktivGroteskEx-Bd.ttf
    AktivGroteskEx-Blk.ttf
    AktivGroteskEx-Hair.ttf
    AktivGroteskEx-Lt.ttf
    AktivGroteskEx-Md.ttf
    AktivGroteskEx-Rg.ttf
    AktivGroteskEx-Th.ttf
    AktivGroteskEx-XBd.ttf*/
}

extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension UITableView {
    func reloadData(with animation: UITableViewRowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
}

extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0;

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(number: Int, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        var badgeWidth = 20
        var numberOffset = 10
        
        
        
        // Initialize Badge
        let badge = CAShapeLayer()
        var radius = CGFloat(11)
        if(number > 50){
            radius = CGFloat(11)
            badgeWidth = 20
            numberOffset = 10
        }else{
            if number > 9 {
                radius = CGFloat(11)
                badgeWidth = 20
                numberOffset = 10
            }
        }
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        if(number > 50 ){
            label.string = "50+"
        }
        label.alignmentMode = kCAAlignmentCenter
        label.fontSize = 11
        label.font = UIFont.gothamBook(size: 11)
        label.frame = CGRect(origin: CGPoint(x: location.x - CGFloat(numberOffset), y: offset.y), size: CGSize(width: badgeWidth, height: 16))
        if(number > 0){
        label.frame.origin = CGPoint(x: location.x - CGFloat(numberOffset),y: 6)
        }
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}
