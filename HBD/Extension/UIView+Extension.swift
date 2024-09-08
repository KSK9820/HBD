//
//  UIView+Extension.swift
//  HBD
//
//  Created by 김수경 on 8/22/24.
//

import UIKit

extension UIView {
    func applyNeumorphismEffect(cornerRadius: CGFloat = 20, shadowRadius: CGFloat = 10, shadowOffset: CGSize = CGSize(width: 10, height: 10), backgroundColor: UIColor = .systemGray6) {
        self.layer.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = shadowRadius
        
        let highlightLayer = CALayer()
        highlightLayer.frame = self.bounds
        highlightLayer.backgroundColor = UIColor.systemGray6.cgColor
        highlightLayer.cornerRadius = cornerRadius
        highlightLayer.shadowColor = UIColor.white.cgColor
        highlightLayer.shadowOffset = CGSize(width: -shadowOffset.width, height: -shadowOffset.height)
        highlightLayer.shadowOpacity = 0.7
        highlightLayer.shadowRadius = shadowRadius
        highlightLayer.masksToBounds = false
        
        self.layer.insertSublayer(highlightLayer, at: 0)
    }
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
    func findNavigationController() -> UINavigationController? {
        return findViewController()?.navigationController
    }
}

