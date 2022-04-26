//
//  WelcomeViewController.swift
//  Spotify
//
//  Created by Isidora Lazic on 30.1.22..
//

import UIKit

final class WelcomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In with Izzify", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(red: 192/255, green: 244/255, blue: 233/255, alpha: 1.0)
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let bgImageView: UIImageView = {
        let bgImageView = UIImageView()
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.image = UIImage(named: "albums_background")
        return bgImageView
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.alpha = 0.7
        view.backgroundColor = .black
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "logo")
        logoImageView.layer.cornerRadius = 80
        logoImageView.clipsToBounds = true
        return logoImageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.text = "Listen to\n millions of songs\n on the go"
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(bgImageView)
        view.addSubview(overlayView)
        view.backgroundColor = .black
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        view.addSubview(logoImageView)
        view.addSubview(label)
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgImageView.frame = view.bounds
        overlayView.frame = view.bounds
        signInButton.frame=CGRect(
            x: 20,
            y: view.height-150-view.safeAreaInsets.bottom,
            width: view.width-40,
            height: 50
        )
        logoImageView.frame = CGRect(x: (view.width-120)/2, y: (view.height-350)/2, width: 120, height: 120)
        label.frame = CGRect(x: 30, y: logoImageView.bottom+30, width: view.width-60, height: 150)
    }
    
    // MARK: - Actions
    
    @objc func didTapSignIn(){
        let vc = AuthViewController()
        vc.completionHandler={[weak self] success in
            DispatchQueue.main.async{
                self?.handleSignIn(success: success)
            }
            
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Helpers
    private func handleSignIn(success:Bool){
        // log in or show error
        guard success else{
            let alert = UIAlertController(title: "Oops!",
                                          message: "Something went wrong.",
                                          preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            return
        }
        let mainAppTabBarVC = TabBarViewController()
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC,animated: true)
    }
}
