//
//  StyleKit.swift
//
//  Created on 2016/05/06.
//
//  Generated by PaintCode Plugin for Sketch
//  http://www.paintcodeapp.com/sketch
//

import UIKit



class StyleKit: NSObject {
    
    
    //MARK: - Canvas Drawings
    
    /// Page 1
    
    class func drawIPhone6(frame frame: CGRect = CGRect(x: 0, y: 0, width: 375, height: 667), resizing: ResizingBehavior = .AspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        /// Resize To Frame
        CGContextSaveGState(context)
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 375, height: 667), target: frame)
        CGContextTranslateCTM(context, resizedFrame.minX, resizedFrame.minY)
        let resizedScale = CGSize(width: resizedFrame.width / 375, height: resizedFrame.height / 667)
        CGContextScaleCTM(context, resizedScale.width, resizedScale.height)
        
        /// Prash Card
        let prashCard = NSMutableAttributedString(string: "Prash Card")
        prashCard.addAttribute(NSFontAttributeName, value: UIFont(name: "BanglaMN-Bold", size: 24)!, range: NSRange(location: 0, length: prashCard.length))
        prashCard.addAttribute(NSForegroundColorAttributeName, value: UIColor(hue: 0.244, saturation: 0.957, brightness: 0.46, alpha: 1), range: NSRange(location: 0, length: 1))
        prashCard.addAttribute(NSForegroundColorAttributeName, value: UIColor(hue: 0.59, saturation: 0.674, brightness: 0.886, alpha: 1), range: NSRange(location: 1, length: 1))
        prashCard.addAttribute(NSForegroundColorAttributeName, value: UIColor(hue: 0.154, saturation: 0.937, brightness: 0.961, alpha: 1), range: NSRange(location: 2, length: 1))
        prashCard.addAttribute(NSForegroundColorAttributeName, value: UIColor(hue: 0.104, saturation: 0.856, brightness: 0.962, alpha: 1), range: NSRange(location: 3, length: 1))
        prashCard.addAttribute(NSForegroundColorAttributeName, value: UIColor(hue: 0.98, saturation: 0.991, brightness: 0.816, alpha: 1), range: NSRange(location: 4, length: 1))
        do {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .Center
            prashCard.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: prashCard.length))
        }
        CGContextSaveGState(context)
        prashCard.drawInRect(CGRect(x: 98, y: 21, width: 179, height: 36))
        CGContextRestoreGState(context)
        
        CGContextRestoreGState(context)
    }
    
    
    //MARK: - Canvas Images
    
    /// Page 1
    
    class func imageOfIPhone6(size size: CGSize = CGSize(width: 375, height: 667), resizing: ResizingBehavior = .AspectFit) -> UIImage {
        var image: UIImage
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        StyleKit.drawIPhone6(frame: CGRect(origin: CGPoint.zero, size: size), resizing: resizing)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    //MARK: - Resizing Behavior
    
    enum ResizingBehavior {
        case AspectFit /// The content is proportionally resized to fit into the target rectangle.
        case AspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case Stretch /// The content is stretched to match the entire target rectangle.
        case Center /// The content is centered in the target rectangle, but it is NOT resized.
        
        func apply(rect rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }
            
            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)
            
            switch self {
                case .AspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .AspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .Stretch:
                    break
                case .Center:
                    scales.width = 1
                    scales.height = 1
            }
            
            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
    
    
}