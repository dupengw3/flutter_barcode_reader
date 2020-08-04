//
//  TestViewController.swift
//  Runner
//
//  Created by 杜鹏 on 2020/8/4.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
     var bundle: Bundle{
    let associateBundleURL:URL = (Bundle.main.url(forResource: "Frameworks", withExtension: nil)?.appendingPathComponent("barcode_scan").appendingPathExtension("framework"))!
     return Bundle.init(url: associateBundleURL)!
    }

//    NSURL *associateBundleURL = [[NSBundle mainBundle] URLForResource:@"Frameworks" withExtension:nil];
//    associateBundleURL = [associateBundleURL URLByAppendingPathComponent:@"CXSalesmanModule"];
//    associateBundleURL = [associateBundleURL URLByAppendingPathExtension:@"framework"];
//    NSBundle *associateBunle = [NSBundle bundleWithURL:associateBundleURL];
//    associateBundleURL = [associateBunle URLForResource:@"CXSalesmanModule" withExtension:@"bundle"];
//    NSBundle *bundle = [NSBundle bundleWithURL:associateBundleURL];
//    self.imagView.image = [UIImage imageNamed:@"icon_mine_grade"
//      inBundle: bundle
//    compatibleWithTraitCollection:nil];
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
