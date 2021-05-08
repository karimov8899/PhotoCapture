//
//  CustomCameraController.swift
//  CameraApp
//
//  Created by Admin on 4/1/21.
//


import UIKit
import AVFoundation
import TOCropViewController
import SnapKit
import CoreMotion

class CustomCameraController: UIViewController {
    
    // MARK: - Variables
    lazy private var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    lazy private var takePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "capture_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleTakePhoto), for: .touchUpInside)
        return button
    }()
    
    lazy private var gridButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "gridBtn"), for: .normal)
        button.addTarget(self, action: #selector(handleGridLayout), for: .touchUpInside)
        button.tintColor = .clear
        button.isSelected = false
        return button
    }()
    
    lazy private var levelButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "levelBtn"), for: .normal)
        button.addTarget(self, action: #selector(handleLevelBtn), for: .touchUpInside)
        button.tintColor = .clear
        button.isSelected = false
        return button
    }()
    
    lazy private var gridLayout: UIImageView = {
        let view  = UIImageView()
        view.image = #imageLiteral(resourceName: "grid")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy private var levelIcon: UIImageView = {
        let view  = UIImageView()
        view.image = #imageLiteral(resourceName: "centerIcon")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let photoOutput = AVCapturePhotoOutput()
    let motionManager = CMMotionManager()
    var timer: Timer!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        openCamera()
        setUpRotation()
        gridLayout.isHidden = true
        levelIcon.isHidden = true
    }
    
    
    // MARK: - Private Methods
    private func setupUI() {
        view.addSubview(gridLayout)
        view.addSubview(levelIcon)
        view.addSubview(backButton)
        view.addSubview(takePhotoButton)
        view.addSubview(gridButton)
        view.addSubview(levelButton)
        
        gridLayout.snp.makeConstraints { (make) in
            make.right.left.bottom.top.equalToSuperview()
        }
        
        levelIcon.snp.makeConstraints { (make) in
            make.width.height.equalTo(80)
            make.centerX.equalTo(gridLayout.snp.centerX)
            make.centerY.equalTo(gridLayout.snp.centerY)
        }
        
        takePhotoButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaInsets.bottom).inset(25)
            make.height.width.equalTo(80)
            make.centerX.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaInsets.top).offset(15)
            make.right.equalTo(view.safeAreaInsets.right).inset(10)
            make.height.width.equalTo(50)
        }
        
        gridButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        
        levelButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
            make.top.equalTo(gridButton.snp.bottom).offset(20)
        }
        
    }
    
    private func setUpRotation() {
        motionManager.deviceMotionUpdateInterval = 0.01
        motionManager.startGyroUpdates()
        motionManager.startDeviceMotionUpdates(to: .main) {
            [weak self] (data, error) in
            
            guard let data = data, error == nil else {
                return
            }
            
            let rotation = atan2(data.gravity.x,
                                 data.gravity.y) - .pi
            self?.levelIcon.transform =
                CGAffineTransform(rotationAngle: CGFloat(rotation))
             
        }
    }
    
    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // the user has already authorized to access the camera.
            self.setupCaptureSession()
            
        case .notDetermined: // the user has not yet asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // if user has granted to access the camera.
                    print("the user has granted to access the camera")
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                } else {
                    print("the user has not granted to access the camera")
                    self.handleDismiss()
                }
            }
            
        default:
            print("something has wrong due to we can't access the camera.")
            self.handleDismiss()
        }
    }
    
    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraLayer.frame = self.view.frame
            cameraLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(cameraLayer)
            
            captureSession.startRunning()
            self.setupUI()
        }
    }
    
    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleTakePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    @objc private func handleGridLayout() {
        if gridButton.isSelected {
            gridButton.setImage(#imageLiteral(resourceName: "gridBtn"), for: .normal)
            gridButton.isSelected = false
            gridLayout.isHidden = true
        } else {
            gridButton.setImage(#imageLiteral(resourceName: "gridBtnSelected"), for: .normal)
            gridButton.isSelected = true
            gridLayout.isHidden = false
        }
    }
    
    @objc private func handleLevelBtn() {
        if levelButton.isSelected {
            levelButton.setImage(#imageLiteral(resourceName: "levelBtn"), for: .normal)
            levelButton.isSelected = false
            levelIcon.isHidden = true
        } else {
            levelButton.setImage(#imageLiteral(resourceName: "levelBtnSelected"), for: .normal)
            levelButton.isSelected = true
            levelIcon.isHidden = false
        }
    }
}

extension CustomCameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        let cropViewController = TOCropViewController(image: image)
        //        images.append(image)
        cropViewController.delegate = self
        cropViewController.aspectRatioPreset = .presetCustom
        cropViewController.customAspectRatio = CGSize(width: 9, height: 16)
        self.present(cropViewController, animated: false, completion: nil)
        
    }
}

extension CustomCameraController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        
    }
}
