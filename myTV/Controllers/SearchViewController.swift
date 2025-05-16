//
//  SearchViewController.swift
//  myTV
//
//  Created by Ezepue on 5/16/25.
//

import Foundation
import UIKit

class SearchViewController: UIViewController {

    private var movies: [Movie] = []
    private var collectionView: UICollectionView!
    private let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupSearchBar()
        setupCollectionView()
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search Movies"
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        navigationItem.titleView = searchBar
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 2.5, height: 220)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)

        view.addSubview(collectionView)

        // Auto Layout for better sizing on all devices
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - Search Handling
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        guard let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !query.isEmpty else { return }

        MovieService.shared.searchMovies(query: query) { results in
            DispatchQueue.main.async {
                self.movies = results
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - CollectionView Handling
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.identifier, for: indexPath) as? MovieCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: movies[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.item]
        let vc = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(vc, animated: true)
    }
}

