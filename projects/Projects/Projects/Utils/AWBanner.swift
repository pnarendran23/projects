//
//  Banner.swift
//  Debt Reminder
//
//  Created by Rebouh Aymen on 11/10/2015.
//  Copyright © 2015 Rebouh Aymen. All rights reserved.
//

import UIKit

// MARK: - Banner Properties -

private var originY: CGFloat = 0.0
var height: CGFloat    = 0.0
private struct AWBannerProperties {
    
    static let width: CGFloat     = UIScreen.main.bounds.width
}

// MARK: - Banner View -

class AWBannerView: UIView {
    
    var notificationLabel: UILabel!
    
    // MARK: - Lifecycle -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if(UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight){
            height = 0.058 * UIScreen.main.bounds.size.height
        }else{
            height = 0.058 * UIScreen.main.bounds.size.height
        }
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.frame                           = CGRect(x: 0.0, y: originY, width: AWBannerProperties.width, height: 0.0)
        self.notificationLabel               = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: height))
        self.notificationLabel.font          = notificationLabel.font.withSize(15.0)
        self.notificationLabel.textAlignment = .center
        self.notificationLabel.text          = " "
        self.notificationLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(notificationLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AWBannerView.hide))
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - User Interaction -
    
    @objc func hide() {
        AWBanner.hide()
    }
}

open class AWBanner {
    
    fileprivate static let notificationView = AWBannerView()
    
    open static func showWithDuration(_ duration: TimeInterval, delay: TimeInterval, message: String, backgroundColor: UIColor, textColor: UIColor, x: CGFloat, y: CGFloat, width : CGFloat) {
        
        guard let window = UIApplication.shared.delegate?.window, window != nil else {
            return
        }
        
        originY = y
        
        self.notificationView.notificationLabel.text = message
        self.notificationView.backgroundColor = backgroundColor
        self.notificationView.notificationLabel.font = UIFont.init(name: "Gotham-Medium", size: 12)
        self.notificationView.notificationLabel.numberOfLines = 1
        //self.notificationView.notificationLabel.textAlignment = .left
        self.notificationView.notificationLabel.adjustsFontSizeToFitWidth = true
        self.notificationView.notificationLabel.textColor = textColor
        self.notificationView.notificationLabel.textAlignment = .center
        self.notificationView.notificationLabel.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: height)
        UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            
            window!.addSubview(self.notificationView)
            
            self.notificationView.frame = CGRect(x: x, y: y, width: width, height: height) }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.hide()
        }
    }
    
    open static func hide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            self.notificationView.notificationLabel.text = " "
            self.notificationView.notificationLabel.font = UIFont.init(name: "Gotham-Medium", size: 12)
            self.notificationView.notificationLabel.numberOfLines = 3
            self.notificationView.notificationLabel.adjustsFontSizeToFitWidth = true
            self.notificationView.frame = CGRect(x: 0.0, y: originY, width: AWBannerProperties.width, height: 0.0)
            
        }) { if $0 {
            self.notificationView.removeFromSuperview()
            }
        }
    }
}

