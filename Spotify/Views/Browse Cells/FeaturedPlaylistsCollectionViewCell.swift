//
//  FeaturedPlaylistsCollectionViewCell.swift
//  Spotify
//
//  Created by Isidora Lazic on 1.2.22..
//

import UIKit

class FeaturedPlaylistsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "FeaturedPlaylistsCollectionViewCell"
    
    private let playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let ownerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .thin)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(ownerNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        ownerNameLabel.frame = CGRect(x: 3, y: contentView.height-30, width: contentView.width-6, height: 30)
        playlistNameLabel.frame = CGRect(x: 3, y: contentView.height-60, width: contentView.width-6, height: 30)
        let imageSize = contentView.height-70
        playlistCoverImageView.frame = CGRect(x: (contentView.width-imageSize)/2, y: 3, width: imageSize, height: imageSize)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistNameLabel.text = nil
        ownerNameLabel.text=nil
        playlistCoverImageView.image=nil
    }
    
    // MARK: - Helpers
    
    func configure(with viewModel:FeaturedPlaylistCellViewModel){
        playlistNameLabel.text = viewModel.playlistName
        ownerNameLabel.text=viewModel.ownerName
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}