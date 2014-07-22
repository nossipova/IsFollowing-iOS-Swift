//
//  ResultView.swift
//  IsFollowing
//
//  Created by Natalia Ossipova on 07.07.2014.
//  Copyright (c) 2014 Natalia Ossipova. All rights reserved.
//

import UIKit

class ResultView: UIView {

    let lineWidth: CGFloat = 1.0

    var result = false

    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)

        CGContextSetAllowsAntialiasing(context, true)
        CGContextSetShouldAntialias(context, true)
        CGContextSetLineWidth(context, 1.0)

        // draw background circle
        CGContextSetStrokeColorWithColor(context, UIColor(red:175.0/255.0, green:175.0/255.0, blue:175.0/255.0, alpha:1.0).CGColor)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextAddEllipseInRect(context, CGRectMake(lineWidth, lineWidth, 88.0 - lineWidth * 2.0, 88.0 - lineWidth * 2.0))
        CGContextDrawPath(context, kCGPathFillStroke)

        // draw mark
        if (result) {
            drawMarkYesWithContext(context, colorRef:UIColor(red:0.000, green:0.502, blue:0.251, alpha:1.000).CGColor)
        } else {
            drawMarkNoWithContext(context, colorRef:UIColor.redColor().CGColor)
        }

        CGContextRestoreGState(context);
    }

    func drawMarkYesWithContext(context: CGContextRef, colorRef: CGColorRef) {
        CGContextSetStrokeColorWithColor(context, colorRef)
        CGContextSetLineWidth(context, 10.0)

        CGContextMoveToPoint(context, 14.0, 44.0)
        CGContextAddLineToPoint(context, 34.0, 67.0)
        CGContextAddLineToPoint(context, 70.0, 20.0)

        CGContextDrawPath(context, kCGPathStroke)
    }

    func drawMarkNoWithContext(context: CGContextRef, colorRef: CGColorRef) {
        CGContextSetStrokeColorWithColor(context, colorRef)
        CGContextSetLineWidth(context, 10.0)

        CGContextMoveToPoint(context, 19.0, 19.0)
        CGContextAddLineToPoint(context, 69.0, 69.0)

        CGContextMoveToPoint(context, 19.0, 69.0)
        CGContextAddLineToPoint(context, 69.0, 19.0)
        
        CGContextDrawPath(context, kCGPathStroke)
    }
}
