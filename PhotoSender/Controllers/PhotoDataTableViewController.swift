import UIKit
import Photos
import PhotosUI

class PhotoDataTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhotos(page: 0)
    }
    
    private func loadPhotos(page: Int) {
        Task {
            currentPhotoType = await photoService.loadPhoto(page: page)
            photos.append(contentsOf: currentPhotoType?.content ?? [])
            self.tableView.reloadData()
        }
    }
    
    private func sendPhoto(sendData: SendPhoto) {
        Task {
            await photoService.sendPhoto(sendData: sendData)
        }
    }
    
    // MARK: - private properties
    private var photos: [Photo] = []
    private var currentPhotoType: PhotoType!
    private var photoService = PhotoService()
    private var selectedPhoto: Photo!

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoTableViewCell
        
        cell.configure(with: photos[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if currentPhotoType.page < currentPhotoType.totalPages &&
            indexPath.row == photos.count - 1 {
            loadPhotos(page: currentPhotoType.page + 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(photos[indexPath.row])
        selectedPhoto = photos[indexPath.row]
        #if targetEnvironment(simulator)
            print("Simulator")
        #else
            showCamera()
        #endif
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

}

extension PhotoDataTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showCamera() {        
        let picker =  UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let sendData = SendPhoto(developer: developerName,
                                 image: image,
                                 id: selectedPhoto.id)
        
        sendPhoto(sendData: sendData)
        print(image)
    }
}

