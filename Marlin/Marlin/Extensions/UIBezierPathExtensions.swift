//
//  UIBezierPathExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 8/21/23.
//

import Foundation
import UIKit

extension UIBezierPath {
    
    convenience init(text: NSAttributedString) {
        let textPath = CGMutablePath()
        let line = CTLineCreateWithAttributedString(text)
        
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        
        for run in runs
        {
            let attributes: NSDictionary = CTRunGetAttributes(run)
            let font = attributes[kCTFontAttributeName as String] as! CTFont
            
            let count = CTRunGetGlyphCount(run)
            
            for index in 0 ..< count
            {
                let range = CFRangeMake(index, 1)
                
                var glyph = CGGlyph()
                CTRunGetGlyphs(run, range, &glyph)
                
                var position = CGPoint()
                CTRunGetPositions(run, range, &position)
                
                if let letterPath = CTFontCreatePathForGlyph(font, glyph, nil) {
                    let transform = CGAffineTransform(translationX: position.x, y: position.y).concatenating(CGAffineTransform(scaleX:1.0, y:-1.0))
                    textPath.addPath(letterPath, transform: transform)
                }
            }
        }
        
        self.init(cgPath: textPath)
    }
}
