//
//  DetailViewController.swift
//  Tumblr Feed app
//
//  Created by Jesse Rosenthal on 7/23/25.
//


import UIKit
import Nuke

class DetailViewController: UIViewController {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if post != nil {
            configureUI()
        } else {
            print("Error: Post object not passed to DetailViewController.")
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func configureUI() {
        title = "Post Details"
        
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        
        // Load image using Nuke
        if let photo = post.photos.first, let url = URL(string: photo.originalSize.url) {
            let request = ImageRequest(url: url)
            ImagePipeline.shared.loadImage(with: request) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        self?.postImageView.image = response.image
                    case .failure(_):
                        self?.postImageView.image = UIImage(systemName: "photo.fill")
                    }
                }
            }
        } else {
            postImageView.image = UIImage(systemName: "photo.fill")
        }
        
        // Configure caption text view
        if let caption = post.caption {
            captionTextView.text = caption.trimHTMLTags()
        } else {
            captionTextView.text = "No caption available."
        }
        
        captionTextView.isEditable = false
        captionTextView.isSelectable = false
    }
}

// MARK: - String Extensions
extension String {
    func trimHTMLTags() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
