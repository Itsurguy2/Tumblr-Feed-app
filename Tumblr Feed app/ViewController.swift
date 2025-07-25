//
//  ViewController.swift
//  Tumblr Feed app
//
//  Created by Jesse Rosenthal on 7/16/25.
//



import Foundation
import UIKit
import Nuke

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var posts: [Post] = []
    private let apiKey = "mu07QNnIbkaqlpUZIepDPeclEhzQDGkURRcFs4AxEZIeNac35n"
    private var currentOffset: Int = 0 // For pagination
    private var isLoadingNewPosts = false
    private var allFetchedPosts: [Post] = [] // Store all posts we've fetched
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🚀 ViewController viewDidLoad called")
        setupUI()
        setupTableView()
        fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("📱 View did appear - tableView frame: \(tableView.frame)")
        print("📊 Posts count: \(posts.count)")
    }
    
    private func setupUI() {
        print("🎨 Setting up UI")
        title = "Tumblr Feed"
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        
        // Ensure tableView exists
        if tableView == nil {
            print("❌ ERROR: tableView is nil! Check storyboard connections.")
        } else {
            print("✅ tableView is connected")
        }
    }
    
    private func setupTableView() {
        print("📋 Setting up table view")
        
        guard tableView != nil else {
            print("❌ Cannot setup tableView - it's nil!")
            return
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        // Add refresh control with custom styling
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh posts...")
        refreshControl.tintColor = .systemBlue
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        print("✅ Table view setup complete")
    }
    
    @objc private func refreshPosts() {
        print("🔄 User pulled to refresh - fetching different posts")
        fetchPosts(isRefresh: true)
    }
    
    private func fetchPosts(isRefresh: Bool = false) {
        guard !isLoadingNewPosts else {
            print("⏳ Already loading posts, skipping request")
            return
        }
        
        isLoadingNewPosts = true
        print("🌐 Starting to fetch posts... (isRefresh: \(isRefresh))")
        
        if !isRefresh {
            activityIndicator.startAnimating()
        }
        
        // Build URL with different strategies for refresh vs initial load
        var urlString = "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=\(apiKey)&limit=20"
        
        if isRefresh {
            // For refresh, get posts from a different offset to show different content
            let randomOffset = Int.random(in: 0...100) // Random offset for variety
            urlString += "&offset=\(randomOffset)"
            print("🎲 Using random offset: \(randomOffset) for variety")
        } else {
            // For initial load, use current offset
            urlString += "&offset=\(currentOffset)"
        }
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            showError("Invalid URL")
            isLoadingNewPosts = false
            return
        }
        
        print("📡 Making request to: \(urlString)")
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoadingNewPosts = false
                self?.activityIndicator.stopAnimating()
                self?.tableView.refreshControl?.endRefreshing()
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self?.showError("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    self?.showError("No data received")
                    return
                }
                
                print("📦 Received data: \(data.count) bytes")
                
                do {
                    let tumblrResponse = try JSONDecoder().decode(TumblrResponse.self, from: data)
                    let newPosts = tumblrResponse.response.posts
                    print("✅ Successfully decoded \(newPosts.count) posts")
                    
                    if isRefresh {
                        // For refresh, show different posts
                        self?.posts = newPosts
                        print("🔄 Refreshed with \(newPosts.count) different posts")
                        
                        // Add to our collection of all fetched posts
                        self?.allFetchedPosts.append(contentsOf: newPosts)
                        
                        // Show success message
                        self?.showRefreshSuccess(count: newPosts.count)
                    } else {
                        // For initial load
                        self?.posts = newPosts
                        self?.allFetchedPosts = newPosts
                        self?.currentOffset += newPosts.count
                    }
                    
                    self?.tableView.reloadData()
                    print("🔄 Table view reloaded with \(self?.posts.count ?? 0) posts")
                    
                } catch {
                    print("❌ Decoding error: \(error)")
                    
                    // More detailed error information
                    if let decodingError = error as? DecodingError {
                        self?.printDecodingError(decodingError)
                    }
                    
                    self?.showError("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    // Add this helper method to get more detailed decoding error info
    private func printDecodingError(_ error: DecodingError) {
        switch error {
        case .dataCorrupted(let context):
            print("🔍 Data corrupted: \(context.debugDescription)")
            print("🔍 Coding path: \(context.codingPath)")
            
        case .keyNotFound(let key, let context):
            print("🔍 Key '\(key.stringValue)' not found: \(context.debugDescription)")
            print("🔍 Coding path: \(context.codingPath)")
            
        case .typeMismatch(let type, let context):
            print("🔍 Type mismatch for type \(type): \(context.debugDescription)")
            print("🔍 Coding path: \(context.codingPath)")
            
        case .valueNotFound(let type, let context):
            print("🔍 Value not found for type \(type): \(context.debugDescription)")
            print("🔍 Coding path: \(context.codingPath)")
            
        @unknown default:
            print("🔍 Unknown decoding error: \(error)")
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showRefreshSuccess(count: Int) {
        // Create a subtle success indicator
        let successView = UIView()
        successView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        successView.layer.cornerRadius = 20
        successView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "✅ Loaded \(count) different posts"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        successView.addSubview(label)
        view.addSubview(successView)
        
        NSLayoutConstraint.activate([
            successView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            successView.heightAnchor.constraint(equalToConstant: 40),
            successView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            label.centerXAnchor.constraint(equalTo: successView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: successView.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: successView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: successView.trailingAnchor, constant: -16)
        ])
        
        // Animate the success message
        successView.alpha = 0
        successView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, animations: {
            successView.alpha = 1
            successView.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, animations: {
                successView.alpha = 0
                successView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                successView.removeFromSuperview()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let detailVC = segue.destination as? DetailViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let selectedPost = posts[indexPath.row]
                    detailVC.post = selectedPost
                }
            }
        }
    }
}

// MARK: - Table View Data Source
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("📊 numberOfRowsInSection called, returning: \(posts.count)")
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("🔧 cellForRowAt called for row: \(indexPath.row)")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell else {
            print("❌ Failed to dequeue PostTableViewCell")
            return UITableViewCell()
        }
        
        let post = posts[indexPath.row]
        cell.configure(with: post)
        print("✅ Configured cell for row: \(indexPath.row)")
        
        return cell
    }
}

// MARK: - Table View Delegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        print("Selected post: \(post.id)")
        performSegue(withIdentifier: "showDetail", sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }
}   
