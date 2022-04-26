//
//  Settings.swift
//  Spotify
//
//  Created by Isidora Lazic on 31.1.22..
//

import Foundation

struct Section{
    let title: String
    let options: [Option]
}

struct Option{
    let title: String
    let handler: () -> Void
}
