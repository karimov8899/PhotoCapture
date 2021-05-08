//
//  HomeController.swift
//  CameraApp
//
//  Created by Admin on 4/1/21.
//


import UIKit

class HomeController: UIViewController {
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    
    // MARK: - Private Methods
    private func initialSetup() {
        view.backgroundColor = .white
        title = "CameraApp"
        
        let takePhotoButton = UIButton(type: .system)
        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        takePhotoButton.setTitle("Take Photo", for: .normal)
        takePhotoButton.setTitleColor(.white, for: .normal)
        takePhotoButton.backgroundColor = UIColor.darkGray
        takePhotoButton.layer.cornerRadius = 5
        takePhotoButton.addTarget(self, action: #selector(handleTakePhoto), for: .touchUpInside)
        view.addSubview(takePhotoButton)
       
        takePhotoButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(45)
        }
    }
    
    @objc private func handleTakePhoto() {
        let controller = CustomCameraController()
        self.present(controller, animated: true, completion: nil)
    }
}
