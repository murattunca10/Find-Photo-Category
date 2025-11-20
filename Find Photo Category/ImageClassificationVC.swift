import UIKit

class ImageClassificationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.lightGray.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let selectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Select Image", for: .normal)
        btn.backgroundColor = UIColor.systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.layer.cornerRadius = 10
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.layer.shadowRadius = 5
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let resultLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        lbl.numberOfLines = 0
        lbl.textColor = .darkGray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let viewModel = ImageClassificationVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(selectButton)
        view.addSubview(resultLabel)
        
        selectButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            selectButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            selectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectButton.widthAnchor.constraint(equalToConstant: 200),
            selectButton.heightAnchor.constraint(equalToConstant: 50),
            
            resultLabel.topAnchor.constraint(equalTo: selectButton.bottomAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onResult = { [weak self] text in
            DispatchQueue.main.async {
                self?.resultLabel.text = "Prediction: \(text)"
            }
        }
        
        viewModel.onError = { [weak self] text in
            DispatchQueue.main.async {
                self?.resultLabel.text = "Error: \(text)"
            }
        }
    }
    
    @objc private func selectImage() {
        print("Image picker opened.")
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            print("Image selected. Running prediction...")
            
            if let cg = image.cgImage {
                viewModel.predict(cgImage: cg)
            } else {
                resultLabel.text = "Failed to convert image to CGImage."
            }
        }
    }
}
