    //
//  DrawImages.swift
//  JLinesV2
//
//  Created by Jozsef Romhanyi on 30.04.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import SpriteKit


enum ImageType: Int {
    case GradientRect = 0
}
class DrawImages {
    static let oneGrad:CGFloat = CGFloat(Double.pi) / 180

    var pfeillinksImage = UIImage()
    var pfeilrechtsImage = UIImage()
    var settingsImage = UIImage()
    var backImage = UIImage()
    var undoImage = UIImage()
    var restartImage = UIImage()
    var exchangeImage = UIImage()
    var uhrImage = UIImage()
    var cardPackage = UIImage()
    var tippImage = UIImage()
    
    //let imageColor = GV.khakiColor.CGColor
    static let opaque = false
    static let scale: CGFloat = 1
    
    init() {
    }
    static func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
    
    struct MySize: Hashable {
        var width: CGFloat
        var height: CGFloat
        init(_ size: CGSize) {
            self.width = size.width
            self.height = size.height
        }
    }
    fileprivate static var generatedTextures = [ImageTypes: SKTexture]()
    struct ImageTypes: Hashable {
        var imageType: ImageType
        var size: MySize
        
    }
    
    static func drawOctagon (size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let ctx = UIGraphicsGetCurrentContext()
        let lineWidth: CGFloat = 8
        ctx!.setLineWidth(lineWidth)
       
        let innerSize = CGSize (width: size.width - 20, height: size.height - 20)
        ctx!.setStrokeColor(UIColor.red.cgColor)
        ctx!.setFillColor(UIColor.red.cgColor)
        ctx!.setLineJoin (.round)
        ctx!.setLineCap (.round)
        let startAngle = CGFloat(22.5)
        let a = innerSize.width / 2
        let b = a * tan(startAngle)
        let radius = sqrt(a * a + b * b)
        let center = CGPoint(x: size.width / 2, y: size.width / 2)
        var angle = [CGFloat]()
        angle.append(startAngle)
        for _ in 0...7 {
            angle.append(angle[angle.count - 1] + 45.0)
        }
        let p1 = pointOfCircle(radius: radius, center: center, angle: angle[0] * oneGrad)
        let p2 = pointOfCircle(radius: radius, center: center, angle: angle[1]  * oneGrad)
        let p3 = pointOfCircle(radius: radius, center: center, angle: angle[2]  * oneGrad)
        let p4 = pointOfCircle(radius: radius, center: center, angle: angle[3]  * oneGrad)
        let p5 = pointOfCircle(radius: radius, center: center, angle: angle[4]  * oneGrad)
        let p6 = pointOfCircle(radius: radius, center: center, angle: angle[5]  * oneGrad)
        let p7 = pointOfCircle(radius: radius, center: center, angle: angle[6]  * oneGrad)
        let p8 = pointOfCircle(radius: radius, center: center, angle: angle[7]  * oneGrad)
        let p9 = pointOfCircle(radius: radius, center: center, angle: angle[8]  * oneGrad)
        ctx!.move(to: p1)
        ctx!.addLine(to: p2)
        ctx!.addLine(to: p3)
        ctx!.addLine(to: p4)
        ctx!.addLine(to: p5)
        ctx!.addLine(to: p6)
        ctx!.addLine(to: p7)
        ctx!.addLine(to: p8)
        ctx!.addLine(to: p9)
        ctx!.fillPath()
        ctx!.strokePath()
        
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        return UIImage()
    }

    static func drawConnections (size: CGSize, connections: ConnectionType) -> SKTexture {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let ctx = UIGraphicsGetCurrentContext()
        let lineWidth: CGFloat = 2
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let lineLength = size.width / 2
        ctx!.setLineWidth(lineWidth)
       
        ctx!.setStrokeColor(UIColor.black.cgColor)
        ctx!.setLineJoin (.round)
        ctx!.setLineCap (.round)
        if connections.left {
            ctx!.move(to: center)
            ctx!.addLine(to: CGPoint(x: center.x - lineLength, y: center.y))
            ctx!.strokePath()
        }
        
        if connections.bottom {
            ctx!.move(to: center)
            ctx!.addLine(to: CGPoint(x: center.x, y: center.y + lineLength))
            ctx!.strokePath()
        }
        
        if connections.right {
            ctx!.move(to: center)
            ctx!.addLine(to: CGPoint(x: center.x + lineLength, y: center.y))
            ctx!.strokePath()
        }
        
        if connections.top {
            ctx!.move(to: center)
            ctx!.addLine(to: CGPoint(x: center.x, y: center.y - lineLength))
            ctx!.strokePath()
        }
        
        if connections.leftTop {
            ctx!.move(to: center)
            ctx!.addLine(to: CGPoint(x: center.x - lineLength, y: center.y - lineLength))
            ctx!.strokePath()
        }
        
        if connections.leftBottom {
            ctx!.move(to: center)
            ctx!.addLine(to: CGPoint(x: center.x - lineLength, y: center.y + lineLength))
            ctx!.strokePath()
        }
        
        if connections.rightTop {
            ctx!.move(to: center)
            ctx!.addLine(to: CGPoint(x: center.x + lineLength, y: center.y - lineLength))
            ctx!.strokePath()
        }
        
        if connections.rightBottom {
            ctx!.move(to: center)
            ctx!.addLine(to: CGPoint(x: center.x + lineLength, y: center.y + lineLength))
            ctx!.strokePath()
        }
        

        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image.texture()
        }
        return SKTexture()
    }

    static func drawButton(size: CGSize, outerColor: UIColor = .green, innerColor: UIColor = .lightGray) -> SKTexture {
        //let endAngle = CGFloat(2*M_PI)
        let imageType = ImageTypes(imageType: .GradientRect, size: MySize(size))
        if generatedTextures[imageType] != nil {
            return generatedTextures[imageType]!
        } else {
            UIGraphicsBeginImageContextWithOptions(size, DrawImages.opaque, DrawImages.scale)
            let innerDelta: CGFloat = 5
            let ctx = UIGraphicsGetCurrentContext()!
            
            //        =============================================================
            let locations:[CGFloat] = [0.0, 0.3, 1.0]
            let colors = [UIColor(red: 220/256, green: 220/256, blue: 220/256, alpha: 0.8).cgColor,
                          UIColor(red: 50/256, green: 50/256, blue: 50/256, alpha: 0.8).cgColor,
                          UIColor(red: 180/256, green: 180/256, blue: 180/256, alpha: 0.8).cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!

            var startPoint = CGPoint()
            var endPoint =  CGPoint()

            startPoint.x = size.width / 2
            startPoint.y = innerDelta * 1.2
            endPoint.x = size.width / 2
            endPoint.y = size.height - innerDelta * 1.2

            ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: UInt32(0)))
                         
            ctx.strokePath()
            
            let image = UIGraphicsGetImageFromCurrentImageContext()!.roundedImageWithBorder(width: 5.0, color: .darkGray, radius: 14)!
            
            UIGraphicsEndImageContext()
            return image.texture()
        }
    }
    
    static func pointOfCircle(radius: CGFloat, center: CGPoint, angle: CGFloat) -> CGPoint {
        let pointOfCircle = CGPoint (x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
        return pointOfCircle
    }
    

}




