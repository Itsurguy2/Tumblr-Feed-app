//
//  Posts.swift
//  Tumblr Feed app
//
//  Created by Jesse Rosenthal on 7/16/25.
//

import Foundation

struct TumblrResponse: Codable {
    let meta: Meta
    let response: ResponseData
}

struct Meta: Codable {
    let status: Int
    let msg: String
}

struct ResponseData: Codable {
    let posts: [Post]
}


struct Post: Codable {
    let id: Int
    let summary: String
    let photos: [Photo]
    let caption: String?
    let date: String
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, summary, photos, caption, date, tags
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? ""
        photos = try container.decodeIfPresent([Photo].self, forKey: .photos) ?? []
        caption = try container.decodeIfPresent(String.self, forKey: .caption)
        date = try container.decode(String.self, forKey: .date)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }
}

struct Photo: Codable {
    let caption: String?
    let originalSize: PhotoSize
    
    enum CodingKeys: String, CodingKey {
        case caption
        case originalSize = "original_size"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        caption = try container.decodeIfPresent(String.self, forKey: .caption)
        originalSize = try container.decode(PhotoSize.self, forKey: .originalSize)
    }
}

struct PhotoSize: Codable {
    let url: String
    let width: Int
    let height: Int
}
