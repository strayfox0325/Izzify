//
//  FeaturedPlaylistsResponse.swift
//  Spotify
//
//  Created by Isidora Lazic on 31.1.22..
//

import Foundation

struct FeaturedPlaylistsResponse: Codable{
    let playlists: PlaylistResponse
}

struct CategoryPlaylistsResponse: Codable{
    let playlists: PlaylistResponse
}

struct PlaylistResponse: Codable{
    let items: [Playlist]
}

struct User: Codable{
    let display_name: String
    let external_urls: [String: String]
    let id: String
}

