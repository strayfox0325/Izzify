//
//  LibraryToggleView.swift
//  Spotify
//
//  Created by Isidora Lazic on 6.2.22..
//

import UIKit

// MARK: - LibraryToggleViewDelegate

protocol LibraryToggleViewDelegate: AnyObject{
    func LibraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView)
    func LibraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView)
}

class LibraryToggleView: UIView {
    
    // MARK: - Properties
    
    var state: State = .playlist
    weak var delegate: LibraryToggleViewDelegate?
    
    private let playlistsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemTeal , for: .normal)
        button.setTitle("Playlists", for: .normal)
        return button
    }()
    
    private let albumsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemTeal, for: .normal)
        button.setTitle("Albums", for: .normal)
        return button
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemMint
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(playlistsButton)
        addSubview(albumsButton)
        addSubview(indicatorView)
        
        playlistsButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Actions
    
    @objc private func didTapPlaylists(){
        state = .playlist
        UIView.animate(withDuration: 0.2){
            self.layoutIndicator()
        }
        delegate?.LibraryToggleViewDidTapPlaylists(self)
    }
    
    @objc private func didTapAlbums(){
        state = .album
        UIView.animate(withDuration: 0.2){
            self.layoutIndicator()
        }
        delegate?.LibraryToggleViewDidTapAlbums(self)
    }
    
   // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistsButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        albumsButton.frame = CGRect(x: playlistsButton.right, y: 0, width: 100, height: 40)
        layoutIndicator()
    }
    
    // MARK: - Helpers
    
    func layoutIndicator(){
        switch state {
        case .playlist:
            indicatorView.frame = CGRect(x: 0, y: playlistsButton.bottom, width: 100, height: 3)
        case .album:
            indicatorView.frame = CGRect(x: 100, y: playlistsButton.bottom, width: 100, height: 3)
        }
    }
    
    func update(for state: State){
        self.state = state
        UIView.animate(withDuration: 0.2){
            self.layoutIndicator()
        }
    }
}
