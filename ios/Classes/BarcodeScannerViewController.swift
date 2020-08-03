//
//  BarcodeScannerViewController.swift
//  barcode_scan
//
//  Created by Julian Finkler on 20.02.20.
//

import Foundation
import MTBBarcodeScanner

class BarcodeScannerViewController: UIViewController {
  private var previewView: UIView?
  private var scanRect: ScannerOverlay?
  private var scanner: MTBBarcodeScanner?
  
  var config: Configuration = Configuration.with {
    $0.strings = [
      "cancel" : "Cancel",
      "flash_on" : "Flash on",
      "flash_off" : "Flash off",
      "hand_input" : "Hand input",
      "type" : "0",
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
        btn.setTitle("手动输入", for: .normal)
        btn.titleLabel?.textColor = .white
        btn.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setImage(UIImage.init(named: "hand_input") ?? UIImage(), for: .normal)
        btn.addTarget(self, action: #selector(handInput), for: .touchUpInside)
        return btn
    }()
    
    lazy var torchBtn:CSButton = { ()->CSButton in
        let btn = CSButton.init(frame: CGRect.init(x: UIScreen.main.bounds.width/2.0, y: UIScreen.main.bounds.height - 80 - safeAreaEdgeInset().bottom, width: UIScreen.main.bounds.width/2.0, height: 80), imagePositionMode: .top)
        btn.setTitle("打开手电筒", for: .normal)
        btn.setTitle("关闭手电筒", for: .selected)
        btn.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setImage(UIImage.init(named: "torch") ?? UIImage(), for: .normal)
        btn.addTarget(self, action: #selector(onToggleFlash), for: .touchUpInside)
        return btn
    }()
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let type = (config.strings["type"] == "0" ? 0 : 1)
    
    
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
    
    let btn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width:type == 0 ? 150 : 90, height: 44))
    btn.setTitle(type == 0 ?"添加/查询母开关" : "扫一扫", for: .normal)
    btn.titleLabel?.textColor = .white
    btn.setImage(UIImage.init(named: "backArrow") ?? UIImage(), for: .normal)
    btn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: btn)
    view.addSubview(torchBtn)

    if type == 0{
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
  
  override func viewWillDisappear(_ animated: Bool) {
    scanner?.stopScanning()
    scanRect?.stopAnimating()
    
    if isFlashOn {
      setFlashState(false)
    }
    
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
    scanRect = ScannerOverlay(frame: bounds)
    if let scanRect = scanRect {
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
      scanResult( ScanResult.with {
        $0.type = ResultType.init(rawValue: 3) ?? ResultType.cancelled
        $0.format = .unknown
      });
    }
    
    
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
