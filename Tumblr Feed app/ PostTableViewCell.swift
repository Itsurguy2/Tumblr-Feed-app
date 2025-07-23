//
//   PostTableViewCell.swift
//  Tumblr Feed app
//
//  Created by Jesse Rosenthal on 7/16/25.
//

import Foundation
import UIKit
import Nuke // Import Nuke

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Configure image view
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 8
        
        // Configure labels
        summaryLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        summaryLabel.numberOfLines = 3
        summaryLabel.textColor = .label
        
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        
        tagsLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        tagsLabel.textColor = .systemBlue
        tagsLabel.numberOfLines = 2
    }
    
    func configure(with post: Post) {
        // Set summary text - use caption if summary is empty
        if !post.summary.isEmpty {
            summaryLabel.text = post.summary
        } else if let caption = post.caption, !caption.isEmpty {
            summaryLabel.text = stripHTMLTags(from: caption)
        } else {
            summaryLabel.text = "No description available"
        }
        
        // Set date
        dateLabel.text = formatDate(post.date)
        
        // Set tags
        if !post.tags.isEmpty {
            tagsLabel.text = "#" + post.tags.joined(separator: " #")
        } else if let caption = post.caption, !caption.isEmpty {
            generateTags(from: caption) { [weak self] tags in
                DispatchQueue.main.async {
                    self?.tagsLabel.text = "#" + tags.joined(separator: " #")
                }
            }
        } else {
            tagsLabel.text = ""
        }
        
        // Load image using Nuke
        print("📸 Post ID \(post.id) has \(post.photos.count) photos")

        if let photo = post.photos.first {
            let url = photo.originalSize.url
            print("🔗 Attempting to load image from URL: \(url)")
            // Use Nuke for image loading
            Nuke.loadImage(with: URL(string: url)!, into: postImageView)
        } else {
            print("🚫 No photos found for Post ID \(post.id)")
            postImageView.image = UIImage(systemName: "photo.fill") // fallback icon
        }
    }
    
    private func stripHTMLTags(from string: String) -> String {
        return string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    // Remove the manual loadImage function if you're now using Nuke.
    // private func loadImage(from urlString: String) {
    //     postImageView.image = UIImage(systemName: "photo") // Reset
    //
    //     guard let url = URL(string: urlString) else {
    //         print("❌ Invalid URL: \(urlString)")
    //         return
    //     }
    //
    //     URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
    //         if let error = error {
    //             print("❌ Error loading image: \(error.localizedDescription)")
    //             return
    //         }
    //
    //         guard let data = data, let image = UIImage(data: data) else {
    //             print("⚠️ No image data received or failed to convert to UIImage.")
    //             return
    //         }
    //
    //         DispatchQueue.main.async {
    //             self?.postImageView.image = image
    //         }
    //     }.resume()
    // }

    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss 'GMT'"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        
        return dateString
    }
    
    private func generateTags(from caption: String, completion: @escaping ([String]) -> Void) {
        // This is a placeholder — you'd replace this with a real AI call
        // Simulate tag generation based on keywords in caption
        let keywords = ["people", "story", "love", "city", "family"]
        let lowercased = caption.lowercased()
        
        let matched = keywords.filter { lowercased.contains($0) }
        completion(matched.isEmpty ? ["untagged"] : matched)
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = UIImage(systemName: "photo")
        summaryLabel.text = ""
        dateLabel.text = ""
        tagsLabel.text = ""
    }
}
