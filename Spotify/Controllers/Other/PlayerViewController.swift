//
//  PlayerViewController.swift
//  Spotify
//
//  Created by Isidora Lazic on 30.1.22..
//

import UIKit
import SDWebImage

// MARK: - PlayerViewControllerDelegate

protocol PlayerViewControllerDelegate: AnyObject{
    func didTapPlayPause()
    func didTapNext()
    func didTapBack()
    func didSlideSlider(_ value: Float)
    func closePlayer()
}

final class PlayerViewController: UIViewController{
    
    // MARK: - Properties
    
    weak var dataSource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let controlsView = PlayerControlView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
        controlsView.delegate = self
        configureBarButtons()
        configure()
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame=CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        controlsView.frame = CGRect(x: 10, y: imageView.bottom+10, width: view.width-20, height: view.height-imageView.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-15)
    }
    
    // MARK: - Helpers
    
    private func configure(){
        imageView.sd_setImage(with: dataSource?.imageURL, completed: nil)
        controlsView.configure(with: PlayerControlsViewViewModel(title: dataSource?.songName, subtitle: dataSource?.subtitle))
    }
    
    private func configureBarButtons(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector( didTapClose))
    }
    
    func refreshUI(){
        configure()
    }
    
    func notifyUser(title: String, message: String) {
        let alert = UIAlertController(title: "Action Unavailable",
                                      message: "You must be a Premium member to play previous tracks",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))        
        present(alert,animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func didTapClose(){
        delegate?.closePlayer()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - PlayerControlsViewDelegate

extension PlayerViewController: PlayerControlsViewDelegate {
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlView) {
        delegate?.didTapPlayPause()
    }
    
    func playerControlsViewDidTapBackButton(_ playerControlsView: PlayerControlView) {
        delegate?.didTapBack()
        notifyUser(title: "Action Unavailable", message: "You need Premium Account to play previous tracks")
    }
    
    func playerControlsViewDidTapNextButton(_ playerControlsView: PlayerControlView) {
        delegate?.didTapNext() 
    }
    func PlayerControlsView(_ playerControlsView: PlayerControlView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
    func PlayerControlsViewDidTapClose(_ playerControlsView: PlayerControlView) {
        delegate?.closePlayer()
    }
}
