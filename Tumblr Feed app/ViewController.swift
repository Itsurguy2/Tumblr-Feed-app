//
//  ViewController.swift
//  Tumblr Feed app
//
//  Created by Jesse Rosenthal on 7/16/25.
//



import Foundation
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var posts: [Post] = []
    private let apiKey = "mu07QNnIbkaqlpUZIepDPeclEhzQDGkURRcFs4AxEZIeNac35n" // Replace with your API key
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchPosts()
    }
    
    private func setupUI() {
        title = "Tumblr Feed"
        view.backgroundColor = .systemBackground
        
        // Configure navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Setup activity indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        // Register the custom cell
//        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
//        tableView.register(nib, forCellReuseIdentifier: "PostCell")
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshPosts() {
        fetchPosts()
    }
    
    private func fetchPosts() {
        activityIndicator.startAnimating()
        
        let urlString = "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            showError("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.tableView.refreshControl?.endRefreshing()
                
                if let error = error {
                    self?.showError("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self?.showError("No data received")
                    return
                }
                
                // Print raw JSON response for debugging
                print("📦 Raw JSON:\n", String(data: data, encoding: .utf8) ?? "Invalid JSON")
                
                do {
                    let tumblrResponse = try JSONDecoder().decode(TumblrResponse.self, from: data)
                    self?.posts = tumblrResponse.response.posts
                    self?.tableView.reloadData()
                } catch {
                    self?.showError("Failed to decode response: \(error.localizedDescription)")
                    print("❌ Decoding error: \(error)\n")
                }
            }
        }.resume()
    }

    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Table View Data Source
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        
        let post = posts[indexPath.row]
        cell.configure(with: post)
        
        return cell
    }
}

// MARK: - Table View Delegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        print("Selected post: \(post.id)")
    }

    // Add spacing between rows
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
    
