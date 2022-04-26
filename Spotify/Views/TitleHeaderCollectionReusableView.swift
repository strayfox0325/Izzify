//
//  TitleHeaderCollectionReusableView.swift
//  Spotify
//
//  Created by Isidora Lazic on 3.2.22..
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
   
    // MARK: - Properties
    
    static let identifier = "TitleHeaderCollectionReusableView"
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .regular)
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 15, y: 0, width: width-30, height: height)
    }
    
    // MARK: - Helpers
    
    func configure(with title: String){
        label.text = title
    }
}
