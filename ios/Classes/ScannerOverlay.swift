//
//  ScannerOverlay.swift
//  barcode_scan
//
//  Created by Julian Finkler on 20.02.20.
//

import Foundation

public enum ScanAnimationStyle {
    /// 单线扫描样式
    case `default`
    /// 网格扫描样式
    case grid
}


class ScannerOverlay: UIView {
//    private let line: UIView = UIView()
    lazy var contentView = UIView()

    var style:ScanAnimationStyle = .default
    

    
//    private var scanLineRect: CGRect {
//        let scanRect = calculateScanRect()
//        let positionY = scanRect.origin.y + (scanRect.size.height / 2)
//
//        return CGRect(x: scanRect.origin.x,
//                      y: positionY,
//                      width: scanRect.size.width,
//                      height: 1
//        )
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        line.backgroundColor = UIColor.red
//        line.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(line)


        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
      let holeRect = calculateScanRect()
       drawScan(rect,holeRect: holeRect)
        

        var rect:CGRect?
            
        var img:UIImage? = nil
        if style == .default{
            img = imageNamed("ScanLine");
        }else{
            img = imageNamed("ScanNet");
        }
        guard let image = img else {
            return
        }
        
           let  imageView = UIImageView(image:image.changeColor(UIColor.init(red: 62.0/255.0, green: 186/255.0, blue: 222/255.0, alpha: 1)))
        
            if style == .default {
                rect = CGRect(x: 0 , y: -(12 + 20), width: holeRect.width , height: 12)
            }else{
                rect = CGRect(x: 0, y: -(holeRect.width + 20), width: holeRect.width, height:holeRect.height)
            }
        
        
            contentView = UIView(frame:holeRect)

            contentView.backgroundColor = .clear
            
            contentView.clipsToBounds = true
            
            addSubview(contentView)
            
            ScanAnimation.shared.startWith(rect!, contentView, imageView: imageView)
        
            setupTips("请将条码/二维码放入框内")
        
    }
    
    public func startAnimating() {
        ScanAnimation.shared.startAnimation()

//        layer.removeAnimation(forKey: "flashAnimation")
//        let flash = CABasicAnimation(keyPath: "opacity")
//        flash.fromValue = NSNumber(value: 0.0)
//        flash.toValue = NSNumber(value: 1.0)
//        flash.duration = 0.25
//        flash.autoreverses = true
//        flash.repeatCount = HUGE
//        line.layer.add(flash, forKey: "flashAnimation")
    }
//
    public func stopAnimating() {
        ScanAnimation.shared.stopAnimation()

//        layer.removeAnimation(forKey: "flashAnimation")
    }

    private func calculateScanRect() -> CGRect {
        let rect = frame
        
        let frameWidth = rect.size.width
        var frameHeight = rect.size.height
        
        let isLandscape = frameWidth > frameHeight
        let widthOnPortrait = isLandscape ? frameHeight : frameWidth
        let scanRectWidth = widthOnPortrait * 0.7
        let aspectRatio: CGFloat = 0.7
        let scanRectHeight = scanRectWidth * aspectRatio
        
        if isLandscape {
            let navbarHeight: CGFloat = 32
            frameHeight += navbarHeight
        }
        
        let scanRectOriginX = (frameWidth - scanRectWidth) / 2
        let scanRectOriginY = (frameHeight - scanRectHeight) / 2 - 44
        return CGRect(x: scanRectOriginX,
                      y: scanRectOriginY,
                      width: scanRectWidth,
                      height: scanRectHeight
        )
    }
    
    
    func drawScan(_ rect: CGRect,holeRect:CGRect) {

        let context = UIGraphicsGetCurrentContext()
              
              let overlayColor = UIColor(red: 0.0,
                                         green: 0.0,
                                         blue: 0.0,
                                         alpha: 0.55
              )
              
              context?.setFillColor(overlayColor.cgColor)
              context?.fill(bounds)
              
              // make a hole for the scanner
             // let holeRect = calculateScanRect()
              let holeRectIntersection = holeRect.intersection(rect)
              UIColor.clear.setFill()
              UIRectFill(holeRectIntersection)

              // draw a horizontal line over the middle
//              let lineRect = scanLineRect
//              line.frame = lineRect
              
              // draw the green corners
              let cornerSize: CGFloat = 20
              let path = UIBezierPath()
              
              //top left corner
              path.move(to: CGPoint(x: holeRect.origin.x, y: holeRect.origin.y + cornerSize))
              path.addLine(to: CGPoint(x: holeRect.origin.x, y: holeRect.origin.y))
              path.addLine(to: CGPoint(x: holeRect.origin.x + cornerSize, y: holeRect.origin.y))
              
              //top right corner
              let rightHoleX = holeRect.origin.x + holeRect.size.width
              path.move(to: CGPoint(x: rightHoleX - cornerSize, y: holeRect.origin.y))
              path.addLine(to: CGPoint(x: rightHoleX, y: holeRect.origin.y))
              path.addLine(to: CGPoint(x: rightHoleX, y: holeRect.origin.y + cornerSize))
              
              // bottom right corner
              let bottomHoleY = holeRect.origin.y + holeRect.size.height
              path.move(to: CGPoint(x: rightHoleX, y: bottomHoleY - cornerSize))
              path.addLine(to: CGPoint(x: rightHoleX, y: bottomHoleY))
              path.addLine(to: CGPoint(x: rightHoleX - cornerSize, y: bottomHoleY))
              
              // bottom left corner
              path.move(to: CGPoint(x: holeRect.origin.x + cornerSize, y: bottomHoleY))
              path.addLine(to: CGPoint(x: holeRect.origin.x, y: bottomHoleY))
              path.addLine(to: CGPoint(x: holeRect.origin.x, y: bottomHoleY - cornerSize))
              path.lineWidth = 4
              UIColor.init(red: 62.0/255.0, green: 186/255.0, blue: 222/255.0, alpha: 1).setStroke()
              path.stroke()
              
    }
    
    func setupTips(_ tips:String) {
        
        if tips == "" {
            return
        }

        let tipsLbl = UILabel.init(frame: CGRect.init(x: 0, y: contentView.frame.maxY, width: screenWidth, height: 20))
        
        tipsLbl.text = tips
        
        tipsLbl.textColor = .white
        
        tipsLbl.textAlignment = .center
        
        tipsLbl.font = UIFont.systemFont(ofSize: 13)
        
        addSubview(tipsLbl)
        
        
    }
    
}
