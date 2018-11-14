//
//  noiseView.swift
//  SwiftSnake
//
//  Created by Charlie Trenholm on 11/14/18.
//  Copyright © 2018 Weizhong Yang. All rights reserved.
//

import Foundation
import UIKit

let noiseImageCache = NSCache<AnyObject, AnyObject>()

@IBDesignable class NoiseView: UIView {
    
    let noiseImageSize = CGSize(width: 100, height: 100)
    
    @IBInspectable var noiseColor: UIColor = UIColor.black {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var noiseMinAlpha: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var noiseMaxAlpha: CGFloat = 1 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var noisePasses: Int = 1 {
        didSet {
            noisePasses = max(0, noisePasses)
            setNeedsDisplay()
        }
    }
    @IBInspectable var noiseSpacing: Int = 1 {
        didSet {
            noiseSpacing = max(1, noiseSpacing)
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        UIColor(patternImage: currentUIImage()).set()
        UIRectFillUsingBlendMode(bounds, .normal)
    }
    
    private func currentUIImage() -> UIImage {
        
        //  Key based on all parameters
        let cacheKey = "\(noiseImageSize),\(noiseColor),\(noiseMinAlpha),\(noiseMaxAlpha),\(noisePasses)"
        
        var image = noiseImageCache.object(forKey: cacheKey as AnyObject) as! UIImage!
        
        if image == nil {
            image = generatedUIImage()
            
            #if !TARGET_INTERFACE_BUILDER
            noiseImageCache.setObject(image!, forKey: cacheKey as AnyObject)
            #endif
        }
        
        return image!
    }
    
    private func generatedUIImage() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(noiseImageSize, false, 0)
        
        let accuracy: CGFloat = 1000.0
        
        for _ in 0..<noisePasses {
            for y in 0..<Int(noiseImageSize.height) {
                for x in 0..<Int(noiseImageSize.width) {
                    if arc4random() % UInt32(noiseSpacing) == 0 {
                        let alpha = (CGFloat(arc4random() % UInt32((noiseMaxAlpha - noiseMinAlpha) * accuracy)) / accuracy) + noiseMinAlpha
                        noiseColor.withAlphaComponent(alpha).set()
                        let rect = CGRect(origin: CGPoint(x: CGFloat(x), y: CGFloat(y)), size: CGSize(width: 1, height: 1))
                        UIRectFill(rect)
                    }
                }
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext() as! UIImage
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
