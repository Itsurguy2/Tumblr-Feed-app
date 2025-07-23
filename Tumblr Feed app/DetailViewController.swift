//
//  DetailViewController.swift
//  Tumblr Feed app
//
//  Created by Jesse Rosenthal on 7/23/25.
//

import UIKit
import Nuke // Assuming Nuke is used for image loading, as in your PostTableViewCell

class DetailViewController: UIViewController {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!

    // Property to store the passed in Post object
    var post: Post!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure post object is set before configuring UI
        if post != nil {
            configureUI()
        } else {
            // Handle error or show a placeholder if post is nil
            print("Error: Post object not passed to DetailViewController.")
            // Optionally, display an alert or go back
        }
    }

    private func configureUI() {
        // Set navigation bar title
        title = "Post Details"
        
        // Configure image view
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        
        // Load image using Nuke
        if let photo = post.photos.first {
            let url = URL(string: photo.originalSize.url)!
            Nuke.loadImage(with: url, into: postImageView) // Using Nuke for image loading
        } else {
            postImageView.image = UIImage(systemName: "photo.fill")
        }
        
        // Configure caption text view
        // Remove HTML tags from the caption string
        if let caption = post.caption {
            captionTextView.text = caption.trimHTMLTags()
        } else {
            captionTextView.text = "No caption available."
        }
        
        // Ensure text view is not editable
        captionTextView.isEditable = false
        captionTextView.isSelectable = false // Optional: prevent text selection
    }
}

// NOTE: This extension should be in its own file (e.g., Strings+Extensions.swift)
// or within the DetailViewController file if you prefer for this project setup.
// Assuming it's already provided in your starter project as mentioned in the hint.
extension String {
    func trimHTMLTags() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
