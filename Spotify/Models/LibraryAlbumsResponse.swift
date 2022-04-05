//
//  LibraryAlbumsResponse.swift
//  Spotify
//
//  Created by Isidora Lazic on 9.2.22..
//

import Foundation

struct LibraryAlbumsResponse: Codable{
    let items: [SavedAlbum]
}

struct SavedAlbum: Codable{
    let added_at: String
    let album: Album
}
