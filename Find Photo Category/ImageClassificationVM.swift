import Foundation
import CoreML
import Vision

class ImageClassificationVM {
    
    private var visionModel: VNCoreMLModel?
    
    var onResult: ((String) -> Void)?
    var onError: ((String) -> Void)?
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        do {
            let wrapper = try ResNet18(configuration: MLModelConfiguration())
            let vnModel = try VNCoreMLModel(for: wrapper.model)
            self.visionModel = vnModel
            
            if let predName = wrapper.model.modelDescription.predictedFeatureName {
                print("Predicted feature:", predName)
            }
            if let probName = wrapper.model.modelDescription.predictedProbabilitiesName {
                print("Probabilities feature:", probName)
            }
            
            print("Model loaded.")
            
        } catch {
            let msg = "Unable to load model: \(error.localizedDescription)"
            print(msg)
            onError?(msg)
        }
    }
    
    func predict(cgImage: CGImage) {
        guard let model = visionModel else {
            onError?("Model is not loaded.")
            return
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] req, err in
            if let err = err {
                self?.onError?("Prediction error: \(err.localizedDescription)")
                return
            }
            
            guard let results = req.results as? [VNClassificationObservation],
                  let first = results.first else {
                self?.onError?("No classification result.")
                return
            }
            
            let percent = first.confidence * 100
            let resultText = "\(first.identifier) (\(String(format: "%.2f", percent))%)"
            print("Prediction:", resultText)
            self?.onResult?(resultText)
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                self.onError?("Handler error: \(error.localizedDescription)")
            }
        }
    }
}
