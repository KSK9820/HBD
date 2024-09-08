//
//  UITextView+Extension.swift
//  HBD
//
//  Created by 김수경 on 8/28/24.
//

import UIKit

extension UITextView {
    func addLeftPadding(_ padding: CGFloat) {
        self.textContainerInset = UIEdgeInsets(top: self.textContainerInset.top,
                                               left: padding,
                                               bottom: self.textContainerInset.bottom,
                                               right: -padding)
    }
}
