//
//  SearchResult.swift
//  Spotify
//
//  Created by Isidora Lazic on 4.2.22..
//

import Foundation

enum SearchResult{
    case artist(model:Artist)
    case album(model:Album)
    case track(model:AudioTrack)
    case playlist(model:Playlist)
}
