/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the object recognition view controller for the Breakfast Finder.
MeThinks: CoreML model filter for Camera Video Feed Layer
*/

import UIKit
import AVFoundation
import Vision

class VisionObjectRecognitionViewController: ViewController, ObservableObject {
    
    private var detectionOverlay: CALayer! = nil
    
    // Vision parts
    private var requests = [VNRequest]()

    @Published var isRecognized: Bool = false
    @Published private var objectLabel: String = String()
    private var savedIdentifier: String = String()
    private var identifierCounter: Int = 0
    
    public func hasRecognized() -> Bool { return self.isRecognized }
    public func getIdentifier() -> String { return self.objectLabel }
    public func setIsRecognized(_ isRecognized: Bool) {
        self.previewLayer
    }
//    public func pauseCamera() {
//
//    }
    
    /**
     *  MeThinks: Takes the Core ML model and puts it in the "objectRecognition" to then put in the "requests" list or stack
     */
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil
/**/
 //            MeThinks: I just change that "ObjectDetector" keyword OR...
 //        guard let modelURL = Bundle.main.url(forResource: "LandmarkDetector_1", withExtension: "mlmodelc") else {
        guard let modelURL = Bundle.main.url(forResource: "ObjectDetector", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
 /**/
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        if !self.isRecognized {
                            self.drawVisionRequestResults(results)
                        }
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    /**
     *  MeThinks: This should be private
     */
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let identifier = topLabelObservation.identifier
            let confidence: Float = round(topLabelObservation.confidence*10000)/100
            
            if self.hasIdentified(identifier: identifier, confidence: confidence) {
                break
            }
            
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
//            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            let equaireShapeLayer = self.createFocusRectLayerWithBounds(objectBounds)
            
//            let textLayer = self.createTextSubLayerInBounds(objectBounds,
//                                                            identifier: topLabelObservation.identifier,
//                                                            confidence: topLabelObservation.confidence)
//            shapeLayer.addSublayer(textLayer)
//            detectionOverlay.addSublayer(shapeLayer)
            detectionOverlay.addSublayer(equaireShapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    func hasIdentified(identifier: String, confidence: Float) -> Bool {
        let confidenceMinimum: Float = 90.00
        
////          if   the confidence is 100.00 on the same tag 5 times in a row,
////          then pause the detection and display the about popup for that tag
        if ((identifier != self.savedIdentifier) && (confidence >= confidenceMinimum)) {
            print("Switched to different Identifier\n")
            self.savedIdentifier = identifier
            self.identifierCounter = 0
        }
        else if ((identifier == self.savedIdentifier) && (confidence >= confidenceMinimum)) {
            print("\(identifierCounter) => \(identifier): \(String(confidence))")
            self.identifierCounter += 1
            if self.identifierCounter >= 5 {
                print("Identified as \"\(identifier)\"\n")
                self.identifierCounter = 0
                self.objectLabel = identifier
                self.isRecognized = true
//                break
            }
        }
        return self.isRecognized
    }
    
    /**
     *  MeThinks: This is where the images from the camera get processed through the model in the "self.requests"
     */
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        
        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        setupVision()
        
        // start the capture
        startCaptureSession()
    }
    
    /**
     *  MeThinks: This should be private
     */
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
//        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
//        rootLayer.addSublayer(detectionOverlay)
        detectionOverlay.position = CGPoint(x: view.layer.bounds.midX, y: view.layer.bounds.midY)
        view.layer.addSublayer(detectionOverlay)
    }
    
    /**
     *  MeThinks: This should be private
     */
    func updateLayerGeometry() {
//        let bounds = rootLayer.bounds
        let bounds = view.layer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint (x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
    /**
     *  MeThinks: This should be private
     *  TODO: remove text
     */
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
/*        TODO: change font color (just out of curiosity) */
        let formattedString = NSMutableAttributedString(string: "\(identifier)\n\(String(round(confidence*10000)/100)) % sure")
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    /**
     *  MeThinks: This should be private
     */
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.2, 1.0, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }

    /**
     *  Build the focus squares around the point of focus
     */
    func createFocusRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.name = "Found Object"
        
        shapeLayer.addSublayer(createEquaire(
            name:     "Top Left Equaire",
            bounds:   bounds,
            point:    CGPoint(x: bounds.minX, y: bounds.maxY),
            rotation: 0
        ))
        shapeLayer.addSublayer(createEquaire(
            name:     "Top Right Equaire",
            bounds:   bounds,
            point:    CGPoint(x: bounds.maxX, y: bounds.maxY),
            rotation: 3 * .pi / 2
        ))
        shapeLayer.addSublayer(createEquaire(
            name:     "Bottom Right Equaire",
            bounds:   bounds,
            point:    CGPoint(x: bounds.maxX, y: bounds.minY),
            rotation: .pi
        ))
        shapeLayer.addSublayer(createEquaire(
            name:     "Bottom Left Equaire",
            bounds:   bounds,
            point:    CGPoint(x: bounds.minX, y: bounds.minY),
            rotation: .pi / 2
        ))
        shapeLayer.addSublayer(createCircle(bounds))

        return shapeLayer
    }

    func createEquaire(name: String, bounds: CGRect, point: CGPoint, rotation: CGFloat) -> CALayer {
        let shapeLayer = self.createEquaireShape(bounds)
        shapeLayer.transform = CATransform3DMakeRotation(rotation, 0.0, 0.0, 1.0)
        shapeLayer.bounds = bounds
        shapeLayer.position = point
        shapeLayer.name = name
        return shapeLayer
    }
    
    /**
     *  Build the focus point circle
     */
    func createCircle(_ bounds: CGRect) -> CALayer {
        let hollowCircleLayer = CALayer()
        let shapeLayer = CAShapeLayer()
        
        let startingPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let bezierPath = UIBezierPath()
        bezierPath.addArc(withCenter: startingPoint, radius: 6.0, startAngle: 0.0, endAngle: 2 * .pi, clockwise: false)
        
        shapeLayer.path = bezierPath.cgPath
//        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.fillColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.0])
        shapeLayer.strokeColor = UIColor.red.cgColor
        
        hollowCircleLayer.addSublayer(shapeLayer)

        return hollowCircleLayer
    }
    
    /**
     *  Build the Square (i.e. "equaire" is french for square) Shape
     */
    func createEquaireShape(_ bounds: CGRect) -> CALayer {
        let equaireLayer = CALayer()
        let shapeLayer = CAShapeLayer()
        
        let bezierPath = UIBezierPath()
        
        let startingPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let longLine: CGFloat = 40.0
        let shortLine: CGFloat = 12.0
        
        bezierPath.move(to: startingPoint)
        bezierPath.addLine(to: CGPoint(x: startingPoint.x + longLine, y: startingPoint.y))
        bezierPath.addLine(to: CGPoint(x: startingPoint.x + longLine, y: startingPoint.y - shortLine))
        bezierPath.addLine(to: CGPoint(x: startingPoint.x + shortLine, y: startingPoint.y - shortLine))
        bezierPath.addLine(to: CGPoint(x: startingPoint.x + shortLine, y: startingPoint.y - longLine))
        bezierPath.addLine(to: CGPoint(x: startingPoint.x, y: startingPoint.y - longLine))
        bezierPath.addLine(to: startingPoint)
        bezierPath.close()
        
        shapeLayer.path = bezierPath.cgPath
//        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.fillColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.2, 1.0, 0.4])
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        equaireLayer.addSublayer(shapeLayer)

        return equaireLayer
    }
    
}
