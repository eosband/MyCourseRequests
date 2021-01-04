//
//  ProgressBarView.swift
//  MyCourseRequests
//
//  Created by Chris Ward on 5/23/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import Foundation
import UIKit

class ProgressBarView: UIView {
    
     // Modified progress bar code (from circlular example to a line) from https://medium.com/@ashikabala01/creating-custom-progress-bar-in-ios-using-swift-c662525b6ed
    var shapeLayer: CAShapeLayer!
    var progressLayer: CAShapeLayer!
    
    func layerSetup(){
        // Screen width and height from https://stackoverflow.com/questions/24110762/swift-determine-ios-screen-size
        let screenSize = UIScreen.main.bounds
        
        shapeLayer = drawLineFromPointToPoint(startX: Int(screenSize.width/5), toEndingX: Int(4/5*screenSize.width), startingY: Int(screenSize.height*7/8), toEndingY: Int(screenSize.height*7/8), ofColor: UIColor(red: 211, green: 211, blue: 211, alpha: 1), widthOfLine: 5, inView: self)
        
        progressLayer = drawLineFromPointToPoint(startX: Int(screenSize.width/5), toEndingX: Int(4/5*screenSize.width), startingY: Int(screenSize.height*7/8), toEndingY: Int(screenSize.height*7/8), ofColor: UIColor(red: 211, green: 211, blue: 211, alpha: 1), widthOfLine: 5, inView: self)
    }
        
    var progress: Float = 0 {
        willSet(newValue)
        {
            progressLayer.strokeEnd = CGFloat(newValue)
        }
    }
    
    // Draw and display bezier path between two points from https://stackoverflow.com/questions/26662415/draw-a-line-with-uibezierpath
    private func drawLineFromPointToPoint(startX: Int, toEndingX endX: Int, startingY startY: Int, toEndingY endY: Int, ofColor lineColor: UIColor, widthOfLine lineWidth: CGFloat, inView view: UIView) -> CAShapeLayer {
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        
        return shapeLayer
    }
}
