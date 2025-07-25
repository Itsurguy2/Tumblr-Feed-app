//
//  Posts.swift
//  Tumblr Feed app
//
//  Created by Jesse Rosenthal on 7/16/25.
//

import Foundation

// MARK: - TumblrResponse
struct TumblrResponse: Codable {
    let response: Response
}

// MARK: - Response
struct Response: Codable {
    let blog: Blog?
    let posts: [Post]
    let totalPosts: Int?
    
    enum CodingKeys: String, CodingKey {
        case blog, posts
        case totalPosts = "total_posts"
    }
}

// MARK: - Blog
struct Blog: Codable {
    let name: String?
    let title: String?
    let url: String?
    let updated: Int?
    let description: String?
    let isNsfw: Bool?
    let ask: Bool?
    let askAnon: Bool?
    let submissionPosts: Int?
    let uuid: String?
    let tumblrURL: String?
    let avatarURL: String?
    let isPaywallOn: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name, title, url, updated, description
        case isNsfw = "is_nsfw"
        case ask
        case askAnon = "ask_anon"
        case submissionPosts = "submission_posts"
        case uuid
        case tumblrURL = "tumblr_url"
        case avatarURL = "avatar_url"
        case isPaywallOn = "is_paywall_on"
    }
}

// MARK: - Post
struct Post: Codable {
    let blogName: String?
    let id: Int
    let postURL: String?
    let slug: String?
    let timestamp: Int?
    let date: String
    let format: String?
    let reblogKey: String?
    let tags: [String]
    let bookmarklet: Bool?
    let mobile: Bool?
    let sourceURL: String?
    let sourceTitle: String?
    let liked: Bool?
    let state: String?
    let reblog: Reblog?
    let trail: [Trail]?
    let canReply: Bool?
    let displayAvatar: Bool?
    let isTumblrPost: Bool?
    let imagePermalink: String?
    let photos: [Photo]
    let caption: String?
    let summary: String
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case blogName = "blog_name"
        case id
        case postURL = "post_url"
        case slug, timestamp, date, format
        case reblogKey = "reblog_key"
        case tags, bookmarklet, mobile
        case sourceURL = "source_url"
        case sourceTitle = "source_title"
        case liked, state, reblog, trail
        case canReply = "can_reply"
        case displayAvatar = "display_avatar"
        case isTumblrPost = "is_tumblr_post"
        case imagePermalink = "image_permalink"
        case photos, caption, summary, type
    }
    
    // Custom init to handle decoding failures gracefully
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        blogName = try container.decodeIfPresent(String.self, forKey: .blogName)
        id = try container.decode(Int.self, forKey: .id)
        postURL = try container.decodeIfPresent(String.self, forKey: .postURL)
        slug = try container.decodeIfPresent(String.self, forKey: .slug)
        timestamp = try container.decodeIfPresent(Int.self, forKey: .timestamp)
        date = try container.decode(String.self, forKey: .date)
        format = try container.decodeIfPresent(String.self, forKey: .format)
        reblogKey = try container.decodeIfPresent(String.self, forKey: .reblogKey)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        bookmarklet = try container.decodeIfPresent(Bool.self, forKey: .bookmarklet)
        mobile = try container.decodeIfPresent(Bool.self, forKey: .mobile)
        sourceURL = try container.decodeIfPresent(String.self, forKey: .sourceURL)
        sourceTitle = try container.decodeIfPresent(String.self, forKey: .sourceTitle)
        liked = try container.decodeIfPresent(Bool.self, forKey: .liked)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        reblog = try container.decodeIfPresent(Reblog.self, forKey: .reblog)
        trail = try container.decodeIfPresent([Trail].self, forKey: .trail)
        canReply = try container.decodeIfPresent(Bool.self, forKey: .canReply)
        displayAvatar = try container.decodeIfPresent(Bool.self, forKey: .displayAvatar)
        isTumblrPost = try container.decodeIfPresent(Bool.self, forKey: .isTumblrPost)
        imagePermalink = try container.decodeIfPresent(String.self, forKey: .imagePermalink)
        photos = try container.decodeIfPresent([Photo].self, forKey: .photos) ?? []
        caption = try container.decodeIfPresent(String.self, forKey: .caption)
        summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? ""
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }
}

// MARK: - Photo
struct Photo: Codable {
    let caption: String?
    let originalSize: Size
    let altSizes: [Size]?
    
    enum CodingKeys: String, CodingKey {
        case caption
        case originalSize = "original_size"
        case altSizes = "alt_sizes"
    }
}

// MARK: - Size
struct Size: Codable {
    let url: String
    let width, height: Int
}

// MARK: - Reblog
struct Reblog: Codable {
    let treeHTML: String?
    let comment: String?
    
    enum CodingKeys: String, CodingKey {
        case treeHTML = "tree_html"
        case comment
    }
}

// MARK: - Trail
struct Trail: Codable {
    let blog: Blog?
    let post: PostElement?
    let blogName: String?
    let contentRaw: String?
    let content: String?
    let isCurrentItem: Bool?
    let isRootItem: Bool?
    
    enum CodingKeys: String, CodingKey {
        case blog, post
        case blogName = "blog_name"
        case contentRaw = "content_raw"
        case content
        case isCurrentItem = "is_current_item"
        case isRootItem = "is_root_item"
    }
}

// MARK: - PostElement
struct PostElement: Codable {
    let id: String?
}
