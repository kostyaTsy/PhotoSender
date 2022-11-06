import UIKit

class PhotoTableViewCell: UITableViewCell {
    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var imageTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with photo: Photo) {
        if let photoStringUrl = photo.image {
            photoImageView.urlImage(url: URL(string: photoStringUrl)!)
        } else {
            photoImageView.image = UIImage(systemName: "photo")
            photoImageView.tintColor = UIColor.gray
        }
        imageTitle.text = photo.name
    }

}
