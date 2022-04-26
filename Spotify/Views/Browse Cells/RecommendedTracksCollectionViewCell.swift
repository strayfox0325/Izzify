//
//  RecommendedTracksCollectionViewCell.swift
//  Spotify
//
//  Created by Isidora Lazic on 1.2.22..
//

import UIKit

class RecommendedTracksCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "RecommendedTracksCollectionViewCell"
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .thin)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        albumCoverImageView.frame = CGRect(x: 5, y: 2, width: contentView.height-4, height: contentView.height-4)
        trackNameLabel.frame = CGRect(x: albumCoverImageView.right+10, y: 0, width: contentView.width-albumCoverImageView.right-15, height: contentView.height/2)
        artistNameLabel.frame = CGRect(x: albumCoverImageView.right+10, y: contentView.height/2, width: contentView.width-albumCoverImageView.right-15, height: contentView.height/2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLabel.text=nil
        albumCoverImageView.image=nil
    }
    
    // MARK: - Helpers
    
    func configure(with viewModel:RecommendedTrackCellViewModel){
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text=viewModel.artistName
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}