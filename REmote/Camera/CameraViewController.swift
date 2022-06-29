//
//  ViewController.swift
//  REmote
//
//  Created by Dmytro Hetman on 22.06.2022.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController{

    //MARK: - IBOutlets
    @IBOutlet private weak var chooseEmotionButton: UIButton!
    
    //MARK: - IBActions
    
    //MARK: - Properties
    var captureSession: AVCaptureSession?
    var photoOutput = AVCapturePhotoOutput()
    var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    var newCamera: AVCaptureDevice?
    private var currentCameraInput: AVCaptureInput?
    
    
    
    private let takePhotoButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        button.layer.cornerRadius = 37.5
        button.layer.borderWidth = 7.5
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    private let switchCameraMode: UIButton = {
       let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        button.imageView?.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        button.tintColor = .white
        
        return button
    }()
    
    private let lastPhotoInGallery: UIImageView = {
       let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width/20.0
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .white
        
        return imageView
    }()
    

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.layer.addSublayer(videoPreviewLayer)
        self.view.addSubview(takePhotoButton)
        self.view.addSubview(switchCameraMode)
        self.view.addSubview(lastPhotoInGallery)
        self.chooseEmotionButton.imageView?.layer.transform = CATransform3DMakeScale(1.25, 1.25, 1.25)
        self.view.addSubview(self.chooseEmotionButton)
        self.newCamera = cameraWithPosition(position: .back)
        askCameraPermission()
        
        takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        switchCameraMode.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        self.lastPhotoInGallery.addGestureRecognizer(tapGR)
        self.lastPhotoInGallery.isUserInteractionEnabled = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.videoPreviewLayer.frame = view.bounds
        let horizontalLine = view.frame.size.height-100
        self.takePhotoButton.center = CGPoint(x: view.frame.size.width/2, y: horizontalLine)
        self.switchCameraMode.center = CGPoint(x: view.frame.size.width*0.9, y: horizontalLine)
        self.lastPhotoInGallery.center = CGPoint(x: view.frame.size.width*0.1, y: horizontalLine/10)
        self.chooseEmotionButton.center = CGPoint(x: view.frame.size.width*0.1, y: horizontalLine)
    }

    @objc
    private func imageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            print("img tapped")
        }
    }

}

extension CameraViewController: AVCapturePhotoCaptureDelegate  {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: data) else { return }
        
        captureSession?.stopRunning()
        
        if let camera = self.newCamera {
            if camera.position == AVCaptureDevice.Position.front {
                guard let cgImg = image.cgImage else { return }
                let imageFromFrontCamera = UIImage(cgImage: cgImg, scale: image.scale, orientation: .leftMirrored)
                self.lastPhotoInGallery.image = imageFromFrontCamera

            } else {
                self.lastPhotoInGallery.image = image
            }
        }
               
        captureSession?.startRunning()
    }
    
    private func askCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    guard granted else { return }
                    DispatchQueue.main.async {
                        self?.setUpCamera()
                    }
                }
            case .restricted, .denied:
                break
            case .authorized:
                self.setUpCamera()
            @unknown default:
                break
        }
    
    }
    
    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let photoInput = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(photoInput) {
                    session.addInput(photoInput)
                }
                
                if session.canAddOutput(photoOutput) {
                    session.addOutput(photoOutput)
                }
                
                videoPreviewLayer.videoGravity = .resizeAspectFill
                videoPreviewLayer.session = session
                
                session.startRunning()
                self.captureSession = session
            }
            catch {
                print(error)
            }
        }
    }
    
    @objc
    private func takePhoto() {
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    @objc
    private func switchCamera() {
        
        if let session = captureSession {
                //Remove existing input
                guard let currentCameraInput: AVCaptureInput = session.inputs.first else {
                    return
                }

                //Indicate that some changes will be made to the session
                session.beginConfiguration()
                session.removeInput(currentCameraInput)

                //Get new input
                
                if let input = currentCameraInput as? AVCaptureDeviceInput {
                    if (input.device.position == .back) {
                        self.newCamera = cameraWithPosition(position: .front)
                        
                    } else {
                        self.newCamera = cameraWithPosition(position: .back)
                    }
                }

                //Add input to session
                var err: NSError?
                var newVideoInput: AVCaptureDeviceInput!
                do {
                    guard let camera = self.newCamera else { return }
                    newVideoInput = try AVCaptureDeviceInput(device: camera)
                } catch let err1 as NSError {
                    err = err1
                    newVideoInput = nil
                }

                if newVideoInput == nil || err != nil {
                    print("Error creating capture device input: \(err?.localizedDescription ?? "")")
                } else {
                    session.addInput(newVideoInput)
                }

                //Commit all the configuration changes at once
                session.commitConfiguration()
            }
    }

    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
}

