//
//  PositionAwareTextField.swift
//  IsFollowing
//
//  Created by Natalia Ossipova on 07.07.2014.
//  Copyright (c) 2014 Natalia Ossipova. All rights reserved.
//

import UIKit

class PositionAwareTextField: UITextField {

    let textPadding: CGFloat = 5.0
    var originalPosition: CGPoint?

    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(bounds.origin.x + textPadding, bounds.origin.y, bounds.size.width - textPadding * 2.0, bounds.size.height)
    }

    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return self.textRectForBounds(bounds)
    }

    func isAboveTextField(otherTextField: UITextField) -> Bool {
        return self.frame.origin.y < otherTextField.frame.origin.y
    }
}
