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
        
        // ONLY register programmatic cell - NO XIB LOADING
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        print("✅ Registered programmatic cell only")
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        print("✅ Table view setup complete")
    }
    
    @objc private func refreshPosts() {
        fetchPosts()
    }
    
    private func fetchPosts() {
        print("🌐 Starting to fetch posts...")
        activityIndicator.startAnimating()
        
        let urlString = "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            showError("Invalid URL")
            return
        }
        
        print("📡 Making request to: \(urlString)")
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
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
                
                // DEBUG: Print the raw JSON response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Raw JSON response (first 1000 chars): \(String(jsonString.prefix(1000)))")
                }
                
                do {
                    let tumblrResponse = try JSONDecoder().decode(TumblrResponse.self, from: data)
                    print("✅ Successfully decoded \(tumblrResponse.response.posts.count) posts")
                    self?.posts = tumblrResponse.response.posts
                    self?.tableView.reloadData()
                    print("🔄 Table view reloaded")
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
        performSegue(withIdentifier: "showDetail", sender: nil)
        let post = posts[indexPath.row]
        print("Selected post: \(post.id)")
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
