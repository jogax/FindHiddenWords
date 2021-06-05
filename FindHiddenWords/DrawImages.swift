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
    
    static func drawBoxWithRoundedEdges(size: CGSize) -> SKTexture {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let ctx = UIGraphicsGetCurrentContext()
        let lineWidth: CGFloat = 5
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        ctx!.setLineWidth(lineWidth)
        ctx!.setStrokeColor(UIColor.blue.cgColor)
        ctx!.setFillColor(UIColor.yellow.cgColor)
        ctx!.setLineJoin (.round)
        ctx!.setLineCap (.round)
        let upperLeftCornew = CGPoint(x: 0, y: 0)
        let upperRightConer = CGPoint(x: size.width, y: 0)
        let bottomLeftCornew = CGPoint(x: 0, y: size.height)
        let bottomRightConer = CGPoint(x: size.width, y: size.height)
        ctx!.move(to: upperLeftCornew)
        ctx!.addLine(to: upperRightConer)
        ctx!.addLine(to: bottomRightConer)
        ctx!.addLine(to: bottomLeftCornew)
        ctx!.addLine(to: upperLeftCornew)
        ctx!.fillPath()
        ctx!.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image!.texture()
    }

    static func drawConnections (size: CGSize, connections: ConnectionType) -> SKTexture {
        if GV.connectionImages[connections] != nil {
            return GV.connectionImages[connections]!
        }
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
            GV.connectionImages[connections] = image.texture()
        }
        return GV.connectionImages[connections]!
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
    
    static func drawTipps() -> UIImage {
        let frame = CGRect(origin: CGPoint(), size: CGSize(width: 250, height: 250))
        let size = CGSize(width: frame.width, height: frame.height)
        //let endAngle = CGFloat(2*M_PI)
        
        UIGraphicsBeginImageContextWithOptions(size, DrawImages.opaque, DrawImages.scale)
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.setStrokeColor(UIColor.black.cgColor)
        
        ctx!.beginPath()
        ctx!.setLineWidth(8.0)
        
        let adder:CGFloat = frame.width * 0.05
        let r0 = frame.width * 0.25
        
        let center1 = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + adder + r0 * 1.8)
        //        let center2 = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height - adder - r0 * 1.5)
        
        
        let minAngle1 = 410 * GV.oneGrad
        let maxAngle1 = 130 * GV.oneGrad
        let blitzAngle1 = 200 * GV.oneGrad
        let blitzAngle2 = 230 * GV.oneGrad
        let blitzAngle3 = 270 * GV.oneGrad
        let blitzAngle4 = 310 * GV.oneGrad
        let blitzAngle5 = 340 * GV.oneGrad
        //println("1 Grad: \(oneGrad)")
        
        //        let minAngle2 = 150 * oneGrad
        //        let maxAngle2 = 30 * oneGrad
        
//        CGContextAddArc(ctx, center1.x, center1.y, r0, minAngle1, maxAngle1, 1)
        ctx!.addArc(center: center1, radius: r0, startAngle: minAngle1, endAngle: maxAngle1, clockwise: true)
        ctx!.strokePath()
        
        //        CGContextAddArc(ctx, center2.x, center2.y, r0, minAngle2, maxAngle2, 1)
        //        CGContextStrokePath(ctx)
        
        let endPoint = DrawImages.pointOfCircle(radius: r0, center: center1, angle: minAngle1)
        let p1 = DrawImages.pointOfCircle(radius: r0, center: center1, angle: maxAngle1)
        let p2 = CGPoint(x: p1.x, y: p1.y + 4 * adder)
        let p3 = CGPoint(x: endPoint.x, y: p2.y)
        let p4 = CGPoint(x: p3.x, y: endPoint.y)
        let p5 = CGPoint(x: p1.x, y: p1.y + 1.3 * adder)
        let p6 = CGPoint(x: p3.x, y: p5.y)
        let p7 = CGPoint(x: p1.x, y: p1.y + 2.6 * adder)
        let p8 = CGPoint(x: p3.x, y: p7.y)
        
        let blitzStartAdder = adder * 1
        let blitzEndAdder = adder * 4
        
        let blitzStartPoint1 = DrawImages.pointOfCircle(radius: r0 + blitzStartAdder, center: center1, angle: blitzAngle1)
        let blitzEndPoint1 = DrawImages.pointOfCircle(radius: r0 + blitzEndAdder, center: center1, angle: blitzAngle1)
        let blitzStartPoint2 = DrawImages.pointOfCircle(radius: r0 + blitzStartAdder, center: center1, angle: blitzAngle2)
        let blitzEndPoint2 = DrawImages.pointOfCircle(radius: r0 + blitzEndAdder, center: center1, angle: blitzAngle2)
        let blitzStartPoint3 = DrawImages.pointOfCircle(radius: r0 + blitzStartAdder, center: center1, angle: blitzAngle3)
        let blitzEndPoint3 = DrawImages.pointOfCircle(radius: r0 + blitzEndAdder, center: center1, angle: blitzAngle3)
        let blitzStartPoint4 = DrawImages.pointOfCircle(radius: r0 + blitzStartAdder, center: center1, angle: blitzAngle4)
        let blitzEndPoint4 = DrawImages.pointOfCircle(radius: r0 + blitzEndAdder, center: center1, angle: blitzAngle4)
        let blitzStartPoint5 = DrawImages.pointOfCircle(radius: r0 + blitzStartAdder, center: center1, angle: blitzAngle5)
        let blitzEndPoint5 = DrawImages.pointOfCircle(radius: r0 + blitzEndAdder, center: center1, angle: blitzAngle5)

        
        
        ctx!.move(to: CGPoint(x: p1.x, y: p1.y))
        ctx!.addLine(to: CGPoint(x: p2.x, y: p2.y))
        ctx!.addLine(to: CGPoint(x: p3.x, y: p3.y))
        ctx!.addLine(to: CGPoint(x: p4.x, y: p4.y))
        ctx!.strokePath()

        ctx!.setLineWidth(8.0)
        ctx!.move(to: CGPoint(x: p5.x, y: p5.y))
        ctx!.addLine(to: CGPoint(x: p6.x, y: p6.y))
        ctx!.strokePath()
        
        ctx!.move(to: CGPoint(x: p7.x, y: p7.y))
        ctx!.addLine(to: CGPoint(x: p8.x, y: p8.y))
        ctx!.strokePath()
        
        ctx!.move(to: CGPoint(x: blitzStartPoint1.x, y: blitzStartPoint1.y))
        ctx!.addLine(to: CGPoint(x: blitzEndPoint1.x, y: blitzEndPoint1.y))
        ctx!.strokePath()

        ctx!.move(to: CGPoint(x: blitzStartPoint2.x, y: blitzStartPoint2.y))
        ctx!.addLine(to: CGPoint(x: blitzEndPoint2.x, y: blitzEndPoint2.y))
        ctx!.strokePath()
        
        ctx!.move(to: CGPoint(x: blitzStartPoint3.x, y: blitzStartPoint3.y))
        ctx!.addLine(to: CGPoint(x: blitzEndPoint3.x, y: blitzEndPoint3.y))
        ctx!.strokePath()
        
        ctx!.move(to: CGPoint(x: blitzStartPoint4.x, y: blitzStartPoint4.y))
        ctx!.addLine(to: CGPoint(x: blitzEndPoint4.x, y: blitzEndPoint4.y))
        ctx!.strokePath()
        
        ctx!.move(to: CGPoint(x: blitzStartPoint5.x, y: blitzStartPoint5.y))
        ctx!.addLine(to: CGPoint(x: blitzEndPoint5.x, y: blitzEndPoint5.y))
        ctx!.strokePath()
        
//        CGContextAddArc(ctx, center1.x, center1.y, r0, maxAngle1, minAngle1, 1)
        ctx!.addArc(center: center1, radius: r0, startAngle: maxAngle1, endAngle: minAngle1, clockwise: true)
        ctx!.strokePath()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image!
    }
    

    
    static func drawSettings() -> UIImage {
        let frame = CGRect(origin: CGPoint(), size: CGSize(width: 250, height: 250))
        let size = CGSize(width: frame.width, height: frame.height)
        let endAngle = CGFloat(2 * Double.pi)
        
        UIGraphicsBeginImageContextWithOptions(size, DrawImages.opaque, DrawImages.scale)
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.beginPath()
        
        ctx!.setLineWidth(8.0)
        
        let adder:CGFloat = 10.0
        let center = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height / 2)
        let r0 = frame.width / 2.2 - adder
        let r1 = frame.width / 3.0 - adder
        let r2 = frame.width / 4.0 - adder
        let count: CGFloat = 8
        let countx2 = count * 2
        let firstAngle = (endAngle / countx2) / 2
        
        ctx!.setFillColor(UIColor.black.cgColor)
        
        //CGContextSetRGBFillColor(ctx, UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1).CGColor);
        for ind in 0..<Int(count) {
            let minAngle1 = firstAngle + CGFloat(ind) * endAngle / count
            let maxAngle1 = minAngle1 + endAngle / countx2
            let minAngle2 = maxAngle1
            let maxAngle2 = minAngle2 + endAngle / countx2
            
            
            let startP = DrawImages.pointOfCircle(radius: r1, center: center, angle: maxAngle1)
            let midP1 = DrawImages.pointOfCircle(radius: r0, center: center, angle: maxAngle1)
            let midP2 = DrawImages.pointOfCircle(radius: r0, center: center, angle: maxAngle2)
            let endP = DrawImages.pointOfCircle(radius: r1, center: center, angle: maxAngle2)
//            CGContextAddArc(ctx, center.x, center.y, r0, max(minAngle1, maxAngle1) , min(minAngle1, maxAngle1), 1)
            ctx!.addArc(center: center, radius: r0, startAngle: max(minAngle1, maxAngle1), endAngle: min(minAngle1, maxAngle1), clockwise: true)
            ctx!.strokePath()
            ctx!.move(to: CGPoint(x: startP.x, y: startP.y))
            ctx!.addLine(to: CGPoint(x: midP1.x, y: midP1.y))
            ctx!.strokePath()
//            CGContextAddArc(ctx, center.x, center.y, r1, max(minAngle2, maxAngle2), min(minAngle2, maxAngle2), 1)
            ctx!.addArc(center: center, radius: r1, startAngle: max(minAngle2, maxAngle2), endAngle: min(minAngle2, maxAngle2), clockwise: true)
            ctx!.strokePath()
            ctx!.move(to: CGPoint(x: midP2.x, y: midP2.y))
            ctx!.addLine(to: CGPoint(x: endP.x, y: endP.y))
            ctx!.strokePath()
        }
        ctx!.fillPath()
        
//        CGContextAddArc(ctx, center.x, center.y, r2, 0, endAngle, 1)
        ctx!.addArc(center: center, radius: r2, startAngle: 0, endAngle: endAngle, clockwise: true)
        ctx!.strokePath()
        
        /*
        let center2 = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let radius = frame.width / 2 - 5
        CGContextAddArc(ctx, center2.x, center2.y, radius, CGFloat(0), CGFloat(2 * M_PI), 1)
        CGContextStrokePath(ctx)
        */
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image!
    }

    static func drawWordList() -> UIImage {
        let frame = CGRect(origin: CGPoint(), size: CGSize(width: 250, height: 250))
        let size = CGSize(width: frame.width, height: frame.height)
        UIGraphicsBeginImageContextWithOptions(size, DrawImages.opaque, DrawImages.scale)
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.beginPath()
        ctx!.setLineWidth(6.0)
        let pointSize = size * 0.05
        var firstPoint = CGPoint(x: size.width * 0.1, y: size.height * 0.2)
        var secondPoint = CGPoint(x: size.width * 0.25, y: size.height * 0.225)
        var thirdPoint = CGPoint(x: size.width * 0.9, y: size.height * 0.225)

        for _ in 1...3 {
            let rectangle = CGRect(origin: firstPoint, size: pointSize)
            ctx!.addEllipse(in: rectangle)
//            ctx!.drawPath(using: .fillStroke)
            ctx!.move(to: firstPoint)
            ctx!.move(to: secondPoint)
            ctx?.addLine(to: thirdPoint)
            firstPoint.y += size.height * 0.2
            secondPoint.y += size.height * 0.2
            thirdPoint.y += size.height * 0.2
        }
        
        
        ctx!.setFillColor(UIColor.black.cgColor)
        ctx!.setStrokeColor(UIColor.black.cgColor)
        
//        ctx!.fillPath()
        
        ctx!.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image!
    }

    static func drawStop() -> UIImage {
        let sizeMpx: CGFloat = 0.7
        let frame = CGRect(origin: CGPoint(), size: CGSize(width: 250, height: 250))
        let size = CGSize(width: frame.width, height: frame.height)
        UIGraphicsBeginImageContextWithOptions(size, DrawImages.opaque, DrawImages.scale)
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.beginPath()
        ctx!.setLineWidth(6.0)
        let startX = size.width * (1 - sizeMpx) / 2
        let startY = size.height * (1 - sizeMpx) / 2
        let rect = CGRect(origin: CGPoint(x: startX, y: startY), size: size * sizeMpx)
        let clipPath = UIBezierPath(roundedRect: rect, cornerRadius: size.width * 0.12).cgPath

        ctx!.addPath(clipPath)

        ctx!.setFillColor(UIColor.red.cgColor)
        ctx!.setStrokeColor(UIColor.black.cgColor)
        
        ctx!.fillPath()
        
        ctx!.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image!
    }

    static func drawLater() -> UIImage {
        let sizeMpx: CGFloat = 0.7
        let frame = CGRect(origin: CGPoint(), size: CGSize(width: 250, height: 250))
        let size = CGSize(width: frame.width, height: frame.height)
        let startX = size.width * (1 - sizeMpx) / 2
        let startY = size.height * (1 - sizeMpx) / 2
        let rect = CGRect(origin: CGPoint(x: startX, y: startY), size: size * 0.7)
        let p1 = CGPoint(x: rect.minX, y: rect.minY)
        let p2 = CGPoint(x: rect.maxX, y: rect.midY)
        let p3 = CGPoint(x: rect.minX, y: rect.maxY)
        UIGraphicsBeginImageContextWithOptions(size, DrawImages.opaque, DrawImages.scale)
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.beginPath()
        ctx!.setLineWidth(10.0)
        ctx!.setLineJoin(.round)
        ctx!.setLineCap(.round)
        ctx!.setLineWidth(25)
        ctx!.move(to: p1)
        ctx!.addLine(to: p2)
        ctx!.addLine(to: p3)
//        trianglePath.close()
//        ctx!.addPath(trianglePath)

        ctx!.setFillColor(UIColor.red.cgColor)
        ctx!.setStrokeColor(UIColor.red.cgColor)
        
        ctx!.fillPath()
        
        ctx!.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image!
    }
}




