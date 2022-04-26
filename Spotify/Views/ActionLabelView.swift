//
//  ActionLabelView.swift
//  Spotify
//
//  Created by Isidora Lazic on 7.2.22..
//

import UIKit

// MARK: - ActionLabelViewDelegate

protocol ActionLabelViewDelegate: AnyObject{
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView)
}

class ActionLabelView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: ActionLabelViewDelegate?
    
    private let label:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        isHidden = true
        addSubview(button)
        addSubview(label)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: 0, y: height-40, width: width, height: 40)
        label.frame = CGRect(x: 0, y: 0, width: width, height: height-45)
    }
    
    // MARK: - Actions
    
    @objc func didTapButton(){
        delegate?.actionLabelViewDidTapButton(self)
    }
    
    // MARK: - Helpers
    
    func configure(with viewModel: ActionLabelViewViewModel){
        label.text = viewModel.text
        button.setTitle(viewModel.actionTitle, for: .normal)
    }
}


