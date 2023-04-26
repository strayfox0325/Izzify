//
//  Enums.swift
//  Spotify
//
//  Created by Isidora Lazic on 26.4.22..
//

import Foundation

enum APIError: Error {
    case failedToGetData
}

enum BrowseSectionType {
    case newReleases(viewModels:[NewReleasesCellViewModel])
    case featurePlaylists(viewModels:[FeaturedPlaylistCellViewModel])
    case recommendedTracks(viewModels:[RecommendedTrackCellViewModel])
    var title: String{
        switch self{
        case .newReleases:
            return "New Album Releases"
        case .featurePlaylists:
            return "Featured Playlists"
        case .recommendedTracks:
            return "Recommended"
        }
    }
}

enum State {
    case playlist
    case album
}

enum SearchResult {
    case artist(model:Artist)
    case album(model:Album)
    case track(model:AudioTrack)
    case playlist(model:Playlist)
}

enum HTTPMethod: String {
    case GET
    case POST
    case DELETE
    case PUT
}
