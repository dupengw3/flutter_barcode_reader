//
//  Common.swift
//  SwiftScanner
//
//  Created by Jason on 2018/11/29.
//  Copyright © 2018 Jason. All rights reserved.
//

import Foundation


//    NSString * bundlePath = [[NSBundle bundleForClass:[MyViewController class]].resourcePath
//                                 stringByAppendingPathComponent:bundleNameWithExtension];
//    NSBundle * bundle = [NSBundle bundleWithPath:bundlePath];
//    UIImage * image = [UIImage imageNamed:@"icon_sina" inBundle:bundle compatibleWithTraitCollection:nil];


let bundle = Bundle(for: BarcodeScannerViewController.self)


//var bundlePath: Bundle{
//// let associateBundleURL:URL = (Bundle.main.url(forResource: "resource_bundle", withExtension: "xcassets"))!
////    print(associateBundleURL.absoluteString)
////  return Bundle.init(url: associateBundleURL)!
//    print(bundle.bundlePath)
//    return bundle
// }

let screenWidth = UIScreen.main.bounds.width

let screenHeight = UIScreen.main.bounds.height

let statusHeight = UIApplication.shared.statusBarFrame.height



public func imageNamed(_ name:String)-> UIImage{
    guard let image = UIImage(named: name, in: bundle, compatibleWith: nil) else{//
        return UIImage()
    }
    return image
}


extension UIImage{

/// 更改图片颜色
public func changeColor(_ color : UIColor) -> UIImage{
    
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
    
    color.setFill()
    
    let bounds = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
    
    UIRectFill(bounds)
    
    self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
    
    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let image = tintedImage else {
        return UIImage()
    }
    
    return image
}

}
