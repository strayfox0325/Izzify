//
//  ViewController.swift
//  Spotify
//
//  Created by Isidora Lazic on 30.1.22..
//

import UIKit

final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var newAlbums: [Album] = []
    private var playlists: [Playlist] = []
    private var tracks: [AudioTrack] = []
    private var sections = [BrowseSectionType]()
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout{sectionIndex, _ -> NSCollectionLayoutSection? in
            return HomeViewController.createSectionLayout(section: sectionIndex)
        }
    )
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .systemTeal
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title="Browse"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .done,
            target: self,
            action: #selector(didTapSettings)
        )
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
        addLongTapGesture()
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: - Actions
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer){
        guard gesture.state == .began else{
            return
        }
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint), indexPath.section == 2 else{
            return
        }
        let model = tracks[indexPath.row]
        let actionSheet = UIAlertController(title: model.name, message: "Add this track to a playlist?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Add to Playlist", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let vc = LibraryPlaylistsViewController()
                vc.selectionHandler = { playlist in
                    APICaller.shared.addTrackToPlaylist(track: model, playlist: playlist, completion: { success in
                        print("Added to Playlist: \(success)")
                    })
                }
                vc.title = "Select a Playlist"
                self?.present(UINavigationController(rootViewController: vc), animated: true)
            }
        }))
        present(actionSheet,animated: true)
    }
    
    @objc func didTapSettings(){
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Helpers
    
    private func addLongTapGesture(){
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(gesture)
    }
    
    private func configureCollectionView(){
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self,
                                forCellWithReuseIdentifier: "cell")
        collectionView.register(NewReleaseCollectionViewCell.self,
                                forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistsCollectionViewCell.self,
                                forCellWithReuseIdentifier: FeaturedPlaylistsCollectionViewCell.identifier)
        collectionView.register(RecommendedTracksCollectionViewCell.self,
                                forCellWithReuseIdentifier: RecommendedTracksCollectionViewCell.identifier)
        collectionView.register(TitleHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
    
    private func fetchData(){
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        var newReleases: NewReleasesResponse?
        var featuredPlaylists: FeaturedPlaylistsResponse?
        var recommendations: RecommendationsResponse?
        //New Releases
        APICaller.shared.getNewReleases{result in
            defer{
                group.leave()
            }
            switch result{
            case .success(let model):
                newReleases=model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        //Featured Playlists
        APICaller.shared.getFeaturedPlaylists{result in
            defer{
                group.leave()
            }
            switch result{
            case .success(let model):
                featuredPlaylists=model
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
        //Recommended Tracks
        APICaller.shared.getRecommendedGenres { result in
            switch result{
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5{
                    if let random = genres.randomElement(){
                        seeds.insert(random)
                    }
                }
                APICaller.shared.getRecommendations(genres: seeds){recommendedResults in
                    defer{
                        group.leave()
                    }
                    
                    switch recommendedResults{
                    case .success(let model):
                        recommendations=model
                    case .failure(let error):
                        print(error.localizedDescription)
                        
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        group.notify(queue: .main){
            guard let newAlbums=newReleases?.albums.items,
                  let playlists=featuredPlaylists?.playlists.items,
                  let tracks=recommendations?.tracks else{
                return
            }
            self.configureModels(newAlbums: newAlbums, playlists: playlists, tracks: tracks)
        }
    }
    
    //Converting model to viewModel
    private func configureModels(newAlbums: [Album], playlists:[Playlist], tracks:[AudioTrack]){
        
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = tracks
        //$0 trenutni element (iterator) petlje
        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewReleasesCellViewModel(name: $0.name, artworkURL: URL(string:$0.images.first?.url ?? "N/A"), numberOfTracks: $0.total_tracks, artistName: $0.artists.first?.name ?? "N/A")
        })))
        sections.append(.featurePlaylists(viewModels: playlists.compactMap({
            return FeaturedPlaylistCellViewModel(playlistName: $0.name, artworkURL: URL(string:$0.images.first?.url ?? "N/A"), ownerName: $0.owner.display_name)
        })))
        sections.append(.recommendedTracks(viewModels: tracks.compactMap({
            return RecommendedTrackCellViewModel(trackName: $0.name, artistName: $0.artists.first?.name ?? "N/A", artworkURL: URL(string: $0.album?.images.first?.url ?? "N/A"))
        })))
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type{
            
        case .newReleases(let viewModels):
            return viewModels.count
        case .featurePlaylists(let viewModels):
            return viewModels.count
        case .recommendedTracks(let viewModels):
            return viewModels.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let type = sections[indexPath.section]
        switch type{
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                for: indexPath
            ) as? NewReleaseCollectionViewCell else{
                return UICollectionViewCell()
            }
            
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
        case .featurePlaylists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeaturedPlaylistsCollectionViewCell.identifier,
                for: indexPath
            ) as? FeaturedPlaylistsCollectionViewCell else{
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedTracksCollectionViewCell.identifier,
                for: indexPath
            ) as? RecommendedTracksCollectionViewCell else{
                return UICollectionViewCell()
            }
            
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        collectionView.deselectItem(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        switch section{
        case .featurePlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlaylistViewController(playlist: playlist)
            vc.title = playlist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .recommendedTracks:
            let track = tracks[indexPath.row]
            PlaybackPresenter.shared.startPlayback(from: self, track: track)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else{
            return UICollectionReusableView()
        }
        let section = indexPath.section
        let title = sections[section].title
        header.configure(with: title)
        return header
    }
    
    static func createSectionLayout(section: Int)->NSCollectionLayoutSection{
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        switch section{
        case 0:
            //Item
            let item = NSCollectionLayoutItem(layoutSize:NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //Group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(390)
                                                  ),
                subitem: item,
                count: 3
            )
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                   heightDimension: .absolute(390)
                                                  ),
                subitem: verticalGroup,
                count: 1
            )
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            return section
        case 1:
            //Item
            let item = NSCollectionLayoutItem(layoutSize:NSCollectionLayoutSize(
                widthDimension: .absolute(200),
                heightDimension: .absolute(200)
            )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //Group
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200),
                                                   heightDimension: .absolute(400)
                                                  ),
                subitem: item,
                count: 2
            )
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200),
                                                   heightDimension: .absolute(400)
                                                  ),
                subitem: verticalGroup,
                count: 1
            )
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            
            return section
        case 2:
            let item = NSCollectionLayoutItem(layoutSize:NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(80)
                                                  ),
                subitem: item,
                count: 1
            )
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        default:
            let item = NSCollectionLayoutItem(layoutSize:NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(390)
                                                  ),
                subitem: item,
                count: 1
            )
            
            //Section
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        }
    }
}
