//
//   PostTableViewCell.swift
//  Tumblr Feed app
//
//  Created by Jesse Rosenthal on 7/16/25.
//

import Foundation
import UIKit
import Nuke

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
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 8
        
        summaryLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        summaryLabel.numberOfLines = 3
        summaryLabel.textColor = .label
        
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        
        tagsLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        tagsLabel.textColor = .systemBlue
        tagsLabel.numberOfLines = 2
    }
    
    // Update your PostTableViewCell configure method to handle optionals
    func configure(with post: Post) {
            if !post.summary.isEmpty {
                summaryLabel.text = post.summary
            } else if let caption = post.caption, !caption.isEmpty {
                summaryLabel.text = stripHTMLTags(from: caption)
            } else {
                summaryLabel.text = "No description available"
            }
            
            dateLabel.text = formatDate(post.date)
            
            if !post.tags.isEmpty {
                tagsLabel.text = "#" + post.tags.prefix(3).joined(separator: " #")
            } else {
                tagsLabel.text = "No tags"
            }
            
            // Load image using Nuke - handle empty photos array
            if let photo = post.photos.first, let url = URL(string: photo.originalSize.url) {
                let request = ImageRequest(url: url)
                ImagePipeline.shared.loadImage(with: request) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            self?.postImageView.image = response.image
                        case .failure(let error):
                            print("❌ Image loading failed: \(error)")
                            self?.postImageView.image = UIImage(systemName: "photo.fill")
                        }
                    }
                }
            } else {
                postImageView.image = UIImage(systemName: "photo.fill")
            }
        }
    
    private func stripHTMLTags(from string: String) -> String {
        return string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
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
        let keywords = ["people", "story", "love", "city", "family", "street", "newyork"]
        let lowercased = caption.lowercased()
        let matched = keywords.filter { lowercased.contains($0) }
        completion(matched.isEmpty ? ["untagged"] : matched)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset image to placeholder
        postImageView.image = UIImage(systemName: "photo")
        summaryLabel.text = ""
        dateLabel.text = ""
        tagsLabel.text = ""
    }
}
