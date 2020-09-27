//
//  BarcodeScannerViewController.swift
//  barcode_scan
//
//  Created by Julian Finkler on 20.02.20.
//

import Foundation
import MTBBarcodeScanner

//let bundle = Bundle(for: BarcodeScannerViewController.self)
//
//let screenWidth = UIScreen.main.bounds.width
//
//let screenHeight = UIScreen.main.bounds.height
//
//let statusHeight = UIApplication.shared.statusBarFrame.height
//
//
//public func imageNamed(_ name:String)-> UIImage{
//
//    guard let image = UIImage(named: name, in: bundle, compatibleWith: nil) else{
//        return UIImage()
//    }
//
//    return image
//
//}


class BarcodeScannerViewController: UIViewController {
  private var previewView: UIView?
  private var scanRect: ScannerOverlay?
  private var scanner: MTBBarcodeScanner?
  
  var config: Configuration = Configuration.with {
    $0.strings = [
     "title" : "扫一扫",
     "detail" : "请将条码/二维码放入框内",
      "flash_on" : "打开手电筒",
      "flash_off" : "关闭手电筒",
      "hand_input" : "手动输入",
      "show_hand_input" : "0",
      "hand_input_dialog_title" : "输入付款码",
    ]
    $0.useCamera = -1 // Default camera
    $0.autoEnableFlash = false
  }
  
  private let formatMap = [
    BarcodeFormat.aztec : AVMetadataObject.ObjectType.aztec,
    BarcodeFormat.code39 : AVMetadataObject.ObjectType.code39,
    BarcodeFormat.code93 : AVMetadataObject.ObjectType.code93,
    BarcodeFormat.code128 : AVMetadataObject.ObjectType.code128,
    BarcodeFormat.dataMatrix : AVMetadataObject.ObjectType.dataMatrix,
    BarcodeFormat.ean8 : AVMetadataObject.ObjectType.ean8,
    BarcodeFormat.ean13 : AVMetadataObject.ObjectType.ean13,
    BarcodeFormat.interleaved2Of5 : AVMetadataObject.ObjectType.interleaved2of5,
    BarcodeFormat.pdf417 : AVMetadataObject.ObjectType.pdf417,
    BarcodeFormat.qr : AVMetadataObject.ObjectType.qr,
    BarcodeFormat.upce : AVMetadataObject.ObjectType.upce,
  ]
  
  var delegate: BarcodeScannerViewControllerDelegate?
  
  private var device: AVCaptureDevice? {
    return AVCaptureDevice.default(for: .video)
  }
  
  private var isFlashOn: Bool {
    return device != nil && (device?.flashMode == AVCaptureDevice.FlashMode.on || device?.torchMode == .on)
  }
  
  private var hasTorch: Bool {
    return device?.hasTorch ?? false
  }
  
    
    lazy var handInputBtn:CSButton = { ()->CSButton in
        let btn = CSButton.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.height - 80 - safeAreaEdgeInset().bottom, width: UIScreen.main.bounds.width/2.0, height: 80), imagePositionMode: .top)
        btn.setTitle(config.strings["hand_input"] ?? "手动输入", for: .normal)
        btn.titleLabel?.textColor = .white
        btn.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setImage(imageNamed("hand_input"), for: .normal)
        btn.addTarget(self, action: #selector(handInput), for: .touchUpInside)
        return btn
    }()
    
    lazy var torchBtn:CSButton = { ()->CSButton in
        let btn = CSButton.init(frame: CGRect.init(x: UIScreen.main.bounds.width/2.0, y: UIScreen.main.bounds.height - 80 - safeAreaEdgeInset().bottom, width: UIScreen.main.bounds.width/2.0, height: 80), imagePositionMode: .top)
        btn.setTitle(config.strings["flash_on"] ?? "打开手电筒", for: .normal)
        btn.setTitle(config.strings["flash_off"] ?? "关闭手电筒", for: .selected)
        btn.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setImage(imageNamed("torch"), for: .normal)
        btn.addTarget(self, action: #selector(onToggleFlash), for: .touchUpInside)
        return btn
    }()
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let showHandInput = config.strings["show_hand_input"] == "1"
    
    
    self.navigationController!.navigationBar.isTranslucent = true
    self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController!.navigationBar.clipsToBounds = true

    #if targetEnvironment(simulator)
    view.backgroundColor = .lightGray
    #endif
    
    previewView = UIView(frame: view.bounds)
    if let previewView = previewView {
      previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      view.addSubview(previewView)
    }
    setupScanRect(view.bounds)
    
    let restrictedBarcodeTypes = mapRestrictedBarcodeTypes()
    if restrictedBarcodeTypes.isEmpty {
      scanner = MTBBarcodeScanner(previewView: previewView)
    } else {
      scanner = MTBBarcodeScanner(metadataObjectTypes: restrictedBarcodeTypes,
                                  previewView: previewView
      )
    }
    
    let title = config.strings["title"] ?? "扫一扫"
    let btn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width:title.count * 20 + 30, height: 44))
//    btn.setTitle(type == 0 ?"添加/查询母开关" : "扫一扫", for: .normal)
    btn.setTitle(title, for: .normal)
    btn.titleLabel?.textColor = .white
    btn.setImage(imageNamed("backArrow"), for: .normal)
    btn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: btn)
    view.addSubview(torchBtn)

    if showHandInput{
     view.addSubview(handInputBtn)
    }else{
        torchBtn.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.height - 80 - safeAreaEdgeInset().bottom, width: UIScreen.main.bounds.width, height: 80);
    }
     
    updateToggleFlashButton()
  }
  
    
    func safeAreaEdgeInset()-> UIEdgeInsets{
        if #available(iOS 11, *){
            return UIApplication.shared.windows[0].safeAreaInsets
        }
        return UIEdgeInsets.zero
    }

    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
       restartScan()
  }
  
    func restartScan(){
       if scanner!.isScanning() {
         scanner!.stopScanning()
       }
       
       scanRect?.startAnimating()
       MTBBarcodeScanner.requestCameraPermission(success: { success in
         if success {
           self.startScan()
         } else {
           #if !targetEnvironment(simulator)
           self.errorResult(errorCode: "PERMISSION_NOT_GRANTED")
           #endif
         }
       })
    }
    
    func stopScan(){
        scanner?.stopScanning()
        scanRect?.stopAnimating()
          
          if isFlashOn {
            setFlashState(false)
          }
    }
    
    
    
  override func viewWillDisappear(_ animated: Bool) {
   stopScan()
    
    super.viewWillDisappear(animated)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    setupScanRect(CGRect(origin: CGPoint(x: 0, y:0),
                         size: size
    ))
  }
  
  private func setupScanRect(_ bounds: CGRect) {
    if scanRect != nil {
      scanRect?.stopAnimating()
      scanRect?.removeFromSuperview()
    }
    scanRect = ScannerOverlay(frame: bounds,remain:config.strings["detail"] ?? "请将条码/二维码放入框内")
    if let scanRect = scanRect {
      scanRect.style = .grid
      scanRect.translatesAutoresizingMaskIntoConstraints = false
      scanRect.backgroundColor = UIColor.clear
      view.addSubview(scanRect)
      scanRect.startAnimating()
    }
  }
  
  private func startScan() {
    do {
      try scanner!.startScanning(with: cameraFromConfig, resultBlock: { codes in
        if let code = codes?.first {
          let codeType = self.formatMap.first(where: { $0.value == code.type });
          let scanResult = ScanResult.with {
            $0.type = .barcode
            $0.rawContent = code.stringValue ?? ""
            $0.format = codeType?.key ?? .unknown
            $0.formatNote = codeType == nil ? code.type.rawValue : ""
          }
          self.scanner!.stopScanning()
          self.scanResult(scanResult)
        }
      })
      if(config.autoEnableFlash){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
          self.setFlashState(true)
        }
      }
    } catch {
      self.scanResult(ScanResult.with {
        $0.type = .error
        $0.rawContent = "\(error)"
        $0.format = .unknown
      })
    }
  }
  
  @objc private func cancel() {
    scanResult( ScanResult.with {
      $0.type = .cancelled
      $0.format = .unknown
    });
  }
  
    @objc private func handInput() {
//        testAlert()
//      scanResult( ScanResult.with {
//        $0.type = ResultType.init(rawValue: 3) ?? ResultType.cancelled
//        $0.format = .unknown
//      });
        
        stopScan()
        
        let alertTitle = config.strings["hand_input_dialog_title"] ?? "输入付款码"
        let alert = UIAlertController.init(title: alertTitle, message: nil, preferredStyle: .alert)
           alert.addTextField { (textField) in
            textField.placeholder = "请" + alertTitle
            textField.keyboardType = .phonePad
           }

           let cancel =  UIAlertAction.init(title: "取消", style: .destructive) { [weak self](action) in
            self?.restartScan()

          }
            alert.addAction(cancel)

           let sure =  UIAlertAction.init(title: "确定", style: .default) {[weak self] (action) in
            if let text = alert.textFields?.first?.text,text.count > 5,text.count < 31 {

                let scanResult = ScanResult.with {
                  $0.type = .barcode
                    $0.rawContent = text
                  $0.format =  .unknown
                  $0.formatNote = "handInput"
                }
                self?.scanner!.stopScanning()
                self?.scanResult(scanResult)
            }else{
                self?.showMessage("请输入正确的付款码!")
            }
            self?.restartScan()

           }
           alert.addAction(sure)

        present(alert, animated: true, completion:   {() in
        })
    }
    
       
    func showMessage(_ msg:String){
     let alertController = UIAlertController(title: msg,
                                                message: nil, preferredStyle: .alert)
        //显示提示框
        self.present(alertController, animated: true, completion: nil)
        //两秒钟后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
//
//    func testAlert(){
//
//            let title: String = "您的开奖时间为"
//            let time: String = "2017-10-23 12:23:18"
//            var countdown:Int = 6
//            let timeout: String = "开奖时间已超时,请重新获取"
//
//
//            let alertVc = UIAlertController.init(title: nil, message: title + "\n" + time, preferredStyle: UIAlertController.Style.alert)
//
//            let alertAction0 = UIAlertAction.init(title: "取消", style: .default, handler: { (action) in
//
//            })
//            let alertAction1 = UIAlertAction.init(title: "确定(\(countdown))", style: .default, handler: { (action) in
//                //确定的操作
//            })
//            alertVc.addAction(alertAction1)
//            alertVc.addAction(alertAction0)
//
//           self.present(alertVc, animated: true, completion: {
//
//            })
//
//            if countdown != 0 {
//                let queue: DispatchQueue = DispatchQueue.global()
//                let countdownTimer = DispatchSource.makeTimerSource(flags: [], queue: queue)
//                countdown = countdown + 1
//                countdownTimer.schedule(deadline: .now(), repeating: .seconds(1))
//                countdownTimer.setEventHandler(handler: {
//                    countdown = countdown - 1
//                    if countdown <= 0 {
//                        countdownTimer.cancel()
//                        DispatchQueue.main.async {
//                            alertAction1.setValue("确定(0)", forKey: "title")
//                            alertAction1.setValue(UIColor.gray, forKey: "titleTextColor")
//                            alertAction1.isEnabled = false
//                            // message
//                            let one = "\(title)\n\(time)\n"
//                            let two = "\(timeout)"
//                            let message = "\(title)\n\(time)\n\(timeout)"
//                            let alertControllerMessageStr = NSMutableAttributedString(string: message)
//                            alertControllerMessageStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSMakeRange(one.count, two.count))
//                            alertControllerMessageStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13), range: NSMakeRange(one.count, two.count))
//                            alertVc.setValue(alertControllerMessageStr, forKey: "attributedMessage")
//                        }
//                    }else {
//                        DispatchQueue.main.async {
//                            alertAction1.setValue("确定(\(countdown))", forKey: "title")
//                        }
//                    }
//                })
//                countdownTimer.resume()
//            }
//
//    }
//
    
  @objc private func onToggleFlash() {
    setFlashState(!isFlashOn)
  }
  
  private func updateToggleFlashButton() {
    if !hasTorch {
      return
    }
    
//    let buttonText = isFlashOn ? config.strings["flash_off"] : config.strings["flash_on"]
    torchBtn.isSelected = isFlashOn
//    navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonText,
//                                                        style: .plain,
//                                                        target: self,
//                                                        action: #selector(onToggleFlash)
//    )
  }
  
  private func setFlashState(_ on: Bool) {
    if let device = device {
      guard device.hasFlash && device.hasTorch else {
        return
      }
      
      do {
        try device.lockForConfiguration()
      } catch {
        return
      }
      
      device.flashMode = on ? .on : .off
      device.torchMode = on ? .on : .off
      
      device.unlockForConfiguration()
      updateToggleFlashButton()
    }
  }
  
  private func errorResult(errorCode: String){
    delegate?.didFailWithErrorCode(self, errorCode: errorCode)
    dismiss(animated: false)
  }
  
  private func scanResult(_ scanResult: ScanResult){
    self.delegate?.didScanBarcodeWithResult(self, scanResult: scanResult)
    dismiss(animated: false)
  }
  
  private func mapRestrictedBarcodeTypes() -> [String] {
    var types: [AVMetadataObject.ObjectType] = []
    
    config.restrictFormat.forEach({ format in
      if let mappedFormat = formatMap[format]{
        types.append(mappedFormat)
      }
    })
    
    return types.map({ t in t.rawValue})
  }
  
  private var cameraFromConfig: MTBCamera {
    return config.useCamera == 1 ? .front : .back
  }
}
