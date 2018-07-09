
import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var resnetModel = Resnet50()
    var results = [VNClassificationObservation]()
    var imagePicker = UIImagePickerController()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let result = results[indexPath.row]
        let name = result.identifier.prefix(30)
        cell.textLabel?.text = "\(name): \(Int(result.confidence * 100))%"
        return cell
    }
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func folderTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        if let image = imageView.image {
            processImage(image: image)
        }
        
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            processImage(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func processImage(image:UIImage) {
        if let model = try? VNCoreMLModel(for:resnetModel.model) {
            let request = VNCoreMLRequest(model: model) {
                (request, error) in
                if let results = request.results as? [VNClassificationObservation] {
                    self.results = Array(results.prefix(5))
                    self.tableView.reloadData()
                }
            }
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
        }
    }
}

