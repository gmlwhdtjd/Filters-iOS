//
//  CameraController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 7. 10..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class CameraController: NSObject {
    private let ciContext = CIContext(options: [kCIImageColorSpace: NSNull()])
    private var captureSession: AVCaptureSession?
    
    private var frontCamera: AVCaptureDevice?
    private var rearCamera: AVCaptureDevice?
    
    private var frontCameraInput: AVCaptureDeviceInput?
    private var rearCameraInput: AVCaptureDeviceInput?
    
    private var captureLock: DispatchSemaphore = DispatchSemaphore.init(value: 1)
    
    private var convertedPointOfInterest = CGPoint(x: 0.5, y: 0.5)
    
    private weak var preview: UIView?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var filteredPreviewLayer: CALayer?
    
    private var photoOutput: AVCapturePhotoOutput?
    private var previewVideoOutput: AVCaptureVideoDataOutput?
    
    private var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    private let cmMotionManager = CMMotionManager()
    private var currentDeviceOrientation: UIDeviceOrientation {
        get {
            guard self.cmMotionManager.isAccelerometerActive,
                let accelerometerData = cmMotionManager.accelerometerData else {
                return .unknown
            }
            
            let currentAcceleration = accelerometerData.acceleration
            
            if abs(currentAcceleration.x) > abs(currentAcceleration.y) {
                return currentAcceleration.x > 0 ? .landscapeRight : .landscapeLeft
            }
            else {
                return currentAcceleration.y > 0 ? .portraitUpsideDown : .portrait
            }
        }
    }
    
    // For camera settings
    private var currentCameraPosition: CameraPosition?
    public var flashMode = AVCaptureDevice.FlashMode.off
    public var timerMode = TimerMode.none
    public var aspectRatioMode = AspectRatioMode.normal
    
    // For camera animation
    public weak var timerCountLable: UILabel?
    public weak var focusAreaDefaultImage: UIImageView?
    public weak var focusAreaImage: UIImageView?
    public weak var captureEffectView: UIView?
    
    let filterController = FilterController.shared
}

extension CameraController  {
    @objc private func resetCurrentCameraDevice() {
        guard let captureSession = self.captureSession,
            let currentCameraPosition = self.currentCameraPosition,
            let currentCameraDevice = (currentCameraPosition == .front ? self.frontCamera : self.rearCamera),
            captureSession.isRunning else {
                return
        }
        do {
            try currentCameraDevice.lockForConfiguration()
            
            self.convertedPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            
            // Focus
            if currentCameraDevice.isFocusPointOfInterestSupported {
                currentCameraDevice.focusPointOfInterest = self.convertedPointOfInterest
            }
            if currentCameraDevice.isFocusModeSupported(.continuousAutoFocus) {
                currentCameraDevice.focusMode = .continuousAutoFocus
            }
            
            // Exposure
            if currentCameraDevice.isExposurePointOfInterestSupported {
                currentCameraDevice.exposurePointOfInterest = self.convertedPointOfInterest
            }
            if currentCameraDevice.isExposureModeSupported(.continuousAutoExposure) {
                currentCameraDevice.exposureMode = .continuousAutoExposure
            }
            
            stopFocusAnimation()
            resetFocusAnimation()
            defaultFocusAnimation()
            
            //Subject Area Change Monitoring
            currentCameraDevice.isSubjectAreaChangeMonitoringEnabled = false
            NotificationCenter.default.removeObserver(self,
                                                      name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                                      object: nil)
            
            currentCameraDevice.unlockForConfiguration()
        }
        catch {
            print(error)
        }
    }
}

// MARK: - Public Functions
extension CameraController {
    public func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
            self.captureSession?.sessionPreset = .photo
        }
        func configureCaptureDevices() throws {
            // Get Camera divices
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            let cameras = session.devices.compactMap { $0 }
            guard !cameras.isEmpty else {
                throw CameraControllerError.noCamerasAvailable
            }
            
            // Set Member
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                }
            }
            
        }
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            if let rearCamera = self.rearCamera {   // rearCamera를 이용해서 세션을 시작하기 위해 먼저 rearCamera로 시도
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) {
                    captureSession.addInput(self.rearCameraInput!)
                }
                
                self.currentCameraPosition = .rear
            }
            else if let frontCamera = self.frontCamera {    // 만약에 rearCamera가 없으면 frontCamera로 시도
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) {
                    captureSession.addInput(self.frontCameraInput!)
                }
                
                self.currentCameraPosition = .front
            }
            else {
                throw CameraControllerError.noCamerasAvailable
            }
        }
        func configurePreviewVideoOutput() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            self.previewVideoOutput = AVCaptureVideoDataOutput()
            self.previewVideoOutput?.alwaysDiscardsLateVideoFrames = true
            self.previewVideoOutput?.setSampleBufferDelegate(self, queue:  DispatchQueue(label: "Sample Buffer Delegate"))
            if captureSession.canAddOutput(self.previewVideoOutput!) {
                captureSession.addOutput(self.previewVideoOutput!)
            }
            
            guard let currentCameraPosition = self.currentCameraPosition,
                let previewVideoOutput = self.previewVideoOutput,
                previewVideoOutput.connections.count > 0 else {
                throw CameraControllerError.noCamerasAvailable
            }
            
            let connection = previewVideoOutput.connections[0]
            connection.videoOrientation = .portrait
            switch currentCameraPosition {
            case .front:
                connection.isVideoMirrored = true
            case .rear:
                connection.isVideoMirrored = false
            }
        }
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            if captureSession.canAddOutput(self.photoOutput!) {
                captureSession.addOutput(self.photoOutput!)
            }
            
            captureSession.startRunning()
            cmMotionManager.accelerometerUpdateInterval = 0.2
            cmMotionManager.startAccelerometerUpdates()
        }
        
        func dispatchCompletionHandler(_ errer: Error?) {
            DispatchQueue.main.async {
                completionHandler(errer)
            }
        }
        func startPrepare() {
            DispatchQueue(label: "prepare").async {
                do {
                    createCaptureSession()
                    try configureCaptureDevices()
                    try configureDeviceInputs()
                    try configurePreviewVideoOutput()
                    try configurePhotoOutput()
                }
                catch {
                    dispatchCompletionHandler(error)
                    return
                }
                
                dispatchCompletionHandler(nil)
            }
        }
        
        // For Camera Premission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startPrepare()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    startPrepare()
                }
                else {
                    dispatchCompletionHandler(CameraControllerError.permissionDenied)
                }
            }
            
        case .denied, .restricted:
            dispatchCompletionHandler(CameraControllerError.permissionDenied)
        }
    }
    public func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession,
            captureSession.isRunning else {
                throw CameraControllerError.captureSessionIsMissing
        }
        
        if let preview = self.preview,
            let previewLayer = self.previewLayer,
            let filteredPreviewLayer = self.filteredPreviewLayer {
            if view == preview {
                previewLayer.frame = view.bounds
                filteredPreviewLayer.frame = view.bounds
                return
            }
            else {
                previewLayer.removeFromSuperlayer()
                filteredPreviewLayer.removeFromSuperlayer()
            }
        }
        
        self.preview = view
        
        // FIXME: How can I remove previewLayer?
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        self.previewLayer?.sublayers?[0].contents = nil
        self.previewLayer?.frame = view.bounds
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
   
        self.filteredPreviewLayer = CALayer()
        self.filteredPreviewLayer?.masksToBounds = true
        self.filteredPreviewLayer?.contentsGravity = "resizeAspectFill"
        self.filteredPreviewLayer?.frame = view.bounds
        
        view.layer.insertSublayer(self.filteredPreviewLayer!, at: 1)
    }
    
    public func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition,
            let captureSession = self.captureSession,
            captureSession.isRunning else {
                throw CameraControllerError.captureSessionIsMissing
        }
        
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            guard let rearCameraInput = self.rearCameraInput,
                captureSession.inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else {
                    throw CameraControllerError.invalidOperation
            }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
            }
            else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        func switchToRearCamera() throws {
            guard let frontCameraInput = self.frontCameraInput,
                captureSession.inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else {
                    throw CameraControllerError.invalidOperation
            }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
            }
            else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        var videoMirrored = false
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
        case .rear:
            try switchToFrontCamera()
            videoMirrored = true
        }
        
        // For filterd preview orientation
        if let previewVideoOutput = self.previewVideoOutput,
            previewVideoOutput.connections.count > 0 {
            let connection = previewVideoOutput.connections[0]
            connection.videoOrientation = .portrait
            connection.isVideoMirrored = videoMirrored
        }
        
        captureSession.commitConfiguration()
        
        resetCurrentCameraDevice()
    }
    public func setPointOfInterest(point: CGPoint) throws {
        guard let captureSession = self.captureSession,
            let currentCameraPosition = self.currentCameraPosition,
            let currentCameraDevice = (currentCameraPosition == .front ? self.frontCamera : self.rearCamera),
            let previewLayer = self.previewLayer,
            captureSession.isRunning else {
                throw CameraControllerError.captureSessionIsMissing
        }
        
        func checkAdjusting() {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                guard let captureSession = self.captureSession,
                    let currentCameraPosition = self.currentCameraPosition,
                    let currentCameraDevice = (currentCameraPosition == .front ? self.frontCamera : self.rearCamera),
                    captureSession.isRunning else {
                        return
                }
                
                if currentCameraDevice.isAdjustingFocus || currentCameraDevice.isAdjustingExposure {
                    checkAdjusting()
                }
                else {
                    self.stopFocusAnimation()
                }
            }
        }
        
        try currentCameraDevice.lockForConfiguration()
        
        var focusPointOfInterestSeted = false
        var exposurePointOfInterestSeted = false
        // FIXME: Becouse of this, I can't remove previewLayer!
        let convertedPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
        
        // Focus
        if currentCameraDevice.isFocusPointOfInterestSupported {
            currentCameraDevice.focusPointOfInterest = convertedPoint
            currentCameraDevice.focusMode = .autoFocus
            focusPointOfInterestSeted = true
        }
        
        //Exposure
        if currentCameraDevice.isExposurePointOfInterestSupported {
            currentCameraDevice.exposurePointOfInterest = convertedPoint
            currentCameraDevice.exposureMode = .autoExpose
            exposurePointOfInterestSeted = true
        }
        
        if (focusPointOfInterestSeted || exposurePointOfInterestSeted) {
            // Subject Area Change Monitoring
            currentCameraDevice.isSubjectAreaChangeMonitoringEnabled = true
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(resetCurrentCameraDevice),
                                                   name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                                   object: nil)
            
            self.convertedPointOfInterest = convertedPoint
            
            self.resetFocusAnimation()
            self.startFocusAnimation(point: point)
            
            checkAdjusting()
        }
        
        currentCameraDevice.unlockForConfiguration()
    }
    public func resetPointOfInterest() throws {
        guard let captureSession = self.captureSession,
            let currentCameraPosition = self.currentCameraPosition,
            let _ = (currentCameraPosition == .front ? self.frontCamera : self.rearCamera),
            captureSession.isRunning else {
                throw CameraControllerError.captureSessionIsMissing
        }
        
        resetCurrentCameraDevice()
    }
    
    public func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        func captureCountdown(leftTime: Int) {
            self.captureCountdownAnimation(leftTime: leftTime)
            
            if leftTime == 0 {
                guard let captureSession = captureSession, captureSession.isRunning else {
                    completion(nil, CameraControllerError.captureSessionIsMissing);
                    self.captureLock.signal()
                    return
                }
                
                let settings = AVCapturePhotoSettings()
                settings.flashMode = self.flashMode
                
                self.captureAnimation()
                
                self.photoOutput?.capturePhoto(with: settings, delegate: self)
                self.photoCaptureCompletionBlock = completion
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    captureCountdown(leftTime: leftTime - 1)
                }
            }
        }
        
        switch self.captureLock.wait(timeout: .now()) {
        case .success:
            captureCountdown(leftTime: self.timerMode.rawValue)
        case .timedOut:
            completion(nil, CameraControllerError.captureIsRunning);
        }
    }

    public func stop() throws {
        guard let captureSession = self.captureSession,
            let previewLayer = self.previewLayer,
            let filteredPreviewLayer = self.filteredPreviewLayer,
            captureSession.isRunning else {
                throw CameraControllerError.captureSessionIsMissing
        }
        captureSession.stopRunning()
        previewLayer.removeFromSuperlayer()
        filteredPreviewLayer.removeFromSuperlayer()
        
        self.frontCamera = nil
        self.rearCamera = nil
        
        self.frontCameraInput = nil
        self.rearCameraInput = nil
        
        self.photoOutput = nil
        self.previewVideoOutput = nil
        
        self.previewLayer = nil
        self.filteredPreviewLayer = nil
        self.captureSession = nil
        
        self.timerCountLable?.layer.removeAllAnimations()
        self.focusAreaDefaultImage?.layer.removeAllAnimations()
        self.focusAreaImage?.layer.removeAllAnimations()
        self.captureEffectView?.layer.removeAllAnimations()
        
        self.cmMotionManager.stopAccelerometerUpdates()
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput,
                            didFinishProcessingPhoto photo: AVCapturePhoto,
                            error: Error?) {
        DispatchQueue(label: "Capture").async {
            if let error = error {
                self.photoCaptureCompletionBlock?(nil, error)
            }
            else if let data = photo.fileDataRepresentation(),
                let image = UIImage(data: data),
                let ciImage = CIImage(data: data) {

                func calculateCGRect(withAspectRatio aspectRatio: CGFloat, imageSize: CGSize) -> CGRect {
                    let width = imageSize.width
                    let height = imageSize.height

                    // FIXME: 들어오는 이미지가 시계방향으로 90도 돌아가 있어 가로 세로가 바뀜 -> 처리해줘야되나?
                    if width <= height * aspectRatio {
                        return CGRect(x: (height - width / aspectRatio) / 2,
                                      y: 0.0,
                                      width: width / aspectRatio,
                                      height: width)
                    }
                    else {
                        return CGRect(x: 0.0,
                                      y: (width - height * aspectRatio) / 2,
                                      width: height,
                                      height: height * aspectRatio)
                    }
                }
                func calculateFixedImageOrientation(from imageOrientation: UIImageOrientation) -> UIImageOrientation {
                    guard let currentCameraPosition = self.currentCameraPosition else {
                        return imageOrientation
                    }
                    
                    var fixedImageOrientation = imageOrientation
                    
                    if currentCameraPosition == .front {
                        fixedImageOrientation = fixedImageOrientation.mirrored()
                        
                        // FIXME: 이 부분 조건을 좀더 깔끔하게 만들 수 있을까?
                        switch imageOrientation {
                        case .up, .down, .upMirrored, .downMirrored:
                            if self.currentDeviceOrientation == .landscapeLeft || self.currentDeviceOrientation == .landscapeRight {
                                fixedImageOrientation = fixedImageOrientation.rotate(degree: 180)
                            }
                        case .left, .right, .leftMirrored, .rightMirrored:
                            if self.currentDeviceOrientation == .portrait || self.currentDeviceOrientation == .portraitUpsideDown {
                                fixedImageOrientation = fixedImageOrientation.rotate(degree: 180)
                            }
                        }
                    }
                    
                    switch self.currentDeviceOrientation {
                    case .portrait:
                        fixedImageOrientation = fixedImageOrientation.rotate(degree: 0)
                    case .portraitUpsideDown:
                        fixedImageOrientation = fixedImageOrientation.rotate(degree: 180)
                    case .landscapeLeft:
                        fixedImageOrientation = fixedImageOrientation.rotate(degree: -90)
                    case .landscapeRight:
                        fixedImageOrientation = fixedImageOrientation.rotate(degree: 90)
                    default:
                        break
                    }
                    
                    return fixedImageOrientation
                }
                
                // blur position
                let filterPoint: CGPoint!
                filterPoint = CGPoint(x: self.convertedPointOfInterest.x, y: 1 - self.convertedPointOfInterest.y)

                // Filter
                let filterChain = self.filterController.currentFilterChain.copy() as! CIFilter
//                filterChain.setValueOfLastFilter(filterPoint, forKey: "inputPosition")
                filterChain.setValue(ciImage, forKey: "inputImage")
                let filteredCIImage = filterChain.outputImage!

                // Crop
                let imageRectangle = calculateCGRect(withAspectRatio: self.aspectRatioMode.rawValue, imageSize: image.size)

                // make bitmap
                let filteredCGImage = self.ciContext.createCGImage(filteredCIImage, from: imageRectangle)

                // Orientation
                let fixedImageOrientation = calculateFixedImageOrientation(from: image.imageOrientation)

                // Make UIIamge
                let filteredUIImage = UIImage(cgImage: filteredCGImage!, scale: image.scale, orientation: fixedImageOrientation)

                self.photoCaptureCompletionBlock?(filteredUIImage, nil)
            }
            else {
                self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
            }
        }
        self.captureLock.signal()
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        // blur position
        let filterPoint: CGPoint!
        if currentCameraPosition == .front {
            filterPoint = CGPoint(x: convertedPointOfInterest.y, y: 1 - convertedPointOfInterest.x)
        }
        else {
           filterPoint = CGPoint(x: 1 - convertedPointOfInterest.y, y: 1 - convertedPointOfInterest.x)
        }

        // Filter
        let filterChain = self.filterController.currentFilterChain
//        filterChain.setValueOfLastFilter(filterPoint, forKey: "inputPosition")
        filterChain.setValue(ciImage, forKey: "inputImage")

        let filteredCIImage = filterChain.outputImage!
        let filteredCGImage = ciContext.createCGImage(filteredCIImage, from: filteredCIImage.extent)

        DispatchQueue.main.async {
            self.filteredPreviewLayer?.contents = filteredCGImage
        }
    }
}

// MARK: - Enums
extension CameraController {
    public enum CameraControllerError: Swift.Error {
        case permissionDenied
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case captureIsRunning
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
    
    public enum TimerMode: Int {
        case none = 0
        case threeSecond = 3
        case fiveSecond = 5
        case tenSecond = 10
    }
    
    public enum AspectRatioMode: CGFloat {
        case normal = 0.7500    // 3:4
        case wide = 0.5625      // 9:16
        case square = 1.0000    // 1:1
    }
}

// MARK: - Camera Animations
extension CameraController {
    open func startFocusAnimation(point: CGPoint) {
        if let focusAreaImage = self.focusAreaImage {
            focusAreaImage.center = point
            focusAreaImage.alpha = 0.1
            focusAreaImage.transform = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
            UIView.animate(withDuration: 0.3) {
                focusAreaImage.alpha = 1.0
                focusAreaImage.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            }
            UIView.animate(withDuration: 0.15, delay: 0.0,
                           options: [UIViewAnimationOptions.repeat, UIViewAnimationOptions.autoreverse],
                           animations: { focusAreaImage.alpha = 0.3 }, completion: nil)
        }
    }
    open func stopFocusAnimation() {
        if let focusAreaImage = self.focusAreaImage {
            focusAreaImage.layer.removeAllAnimations();
        }
    }
    open func resetFocusAnimation() {
        if let focusAreaImage = self.focusAreaImage {
            focusAreaImage.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            focusAreaImage.alpha = 0.0
        }
    }
    open func defaultFocusAnimation() {
        if let focusAreaDefaultImage = self.focusAreaDefaultImage {
            focusAreaDefaultImage.alpha = 1.0
            focusAreaDefaultImage.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
            UIView.animate(withDuration: 0.4) {
                focusAreaDefaultImage.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            }
            UIView.animate(withDuration: 0.2, delay: 0.8, animations: {
                focusAreaDefaultImage.alpha = 0.0
            } , completion: nil)
        }
    }
    open func captureAnimation() {
        if let captureEffectView = self.captureEffectView {
            captureEffectView.alpha = 0.7
            UIView.animate(withDuration: 0.2) {
                captureEffectView.alpha = 0.0
            }
        }
    }
    open func captureCountdownAnimation(leftTime: Int) {
        if let timerCountLable = self.timerCountLable {
            if leftTime == 0 {
                timerCountLable.text = nil
            }
            else {
                timerCountLable.text = String(leftTime)
                timerCountLable.alpha = 1.0
                UIView.animate(withDuration: 0.9) {
                    timerCountLable.alpha = 0.0
                }
            }
        }
    }
}
