//
//  UIView+Extension.swift
//  HBD
//
//  Created by 김수경 on 8/22/24.
//

//import UIKit
//
//extension UIView {
//    func applyNeumorphismEffect(cornerRadius: CGFloat = 20, shadowRadius: CGFloat = 10, shadowOffset: CGSize = CGSize(width: 10, height: 10)) {
//        self.layer.cornerRadius = cornerRadius
//        self.backgroundColor = UIColor.systemGray6
//        
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = shadowOffset
//        self.layer.shadowOpacity = 0.2
//        self.layer.shadowRadius = shadowRadius
//        
//        let highlightLayer = CALayer()
//        highlightLayer.frame = self.bounds
//        highlightLayer.backgroundColor = UIColor.systemGray6.cgColor
//        highlightLayer.cornerRadius = cornerRadius
//        highlightLayer.shadowColor = UIColor.white.cgColor
//        highlightLayer.shadowOffset = CGSize(width: -shadowOffset.width, height: -shadowOffset.height)
//        highlightLayer.shadowOpacity = 0.7
//        highlightLayer.shadowRadius = shadowRadius
//        highlightLayer.masksToBounds = false
//        
//        self.layer.insertSublayer(highlightLayer, at: 0)
//    }
//}

import UIKit

extension UIView {
    func applyNeumorphismEffect(bgColor: UIColor = UIColor.systemBackground, shadowColor: UIColor = UIColor.gray, cornerRadius: CGFloat = 20, shadowOpacity: Float = 0.3, shadowOffset: CGSize = CGSize(width: 8, height: 8), innerShadowOpacity: Float = 0.5, innerShadowOffset: CGSize = CGSize(width: -5, height: -5), shadowRadius: CGFloat = 10) {
        
        self.backgroundColor = bgColor
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        
        // 외부 그림자 추가
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius

        // 내부 그림자 추가
        let innerShadowLayer = CALayer()
        innerShadowLayer.frame = self.bounds
        innerShadowLayer.backgroundColor = bgColor.cgColor
        innerShadowLayer.cornerRadius = cornerRadius
        innerShadowLayer.shadowColor = shadowColor.cgColor
        innerShadowLayer.shadowOpacity = innerShadowOpacity
        innerShadowLayer.shadowOffset = innerShadowOffset
        innerShadowLayer.shadowRadius = shadowRadius
        
        // 그림자 경로 설정
        let innerShadowPath = UIBezierPath(roundedRect: self.bounds.insetBy(dx: -5, dy: -5), cornerRadius: cornerRadius)
        innerShadowLayer.shadowPath = innerShadowPath.cgPath
        
        self.layer.addSublayer(innerShadowLayer)
    }
}
