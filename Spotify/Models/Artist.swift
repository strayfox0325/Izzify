//
//  Artist.swift
//  Spotify
//
//  Created by Isidora Lazic on 30.1.22..
//

import Foundation

struct Artist: Codable{
    let id: String
    let name: String
    let type: String
    let external_urls: [String:String]
    let images: [APIImage]?
}
