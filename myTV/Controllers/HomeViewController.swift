//
//  HomeViewController.swift
//  myTV
//
//  Created by Ezepue on 5/15/25.
//
import UIKit

enum MovieSection: Int, CaseIterable {
    case featured
    case topCharts
    case regular

    var title: String {
        switch self {
        case .featured: return "Featured"
        case .topCharts: return "Top Chart"
        case .regular: return "Popular"
        }
    }
}

class HomeViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var featuredMovies: [Movie] = []
    private var topChartMovies: [Movie] = []
    private var regularMovies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Apple TV Clone"

        configureCollectionView()
        fetchData()
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let sectionType = MovieSection(rawValue: sectionIndex) ?? .regular
            switch sectionType {
            case .featured:
                return self.createFeaturedLayout()
            case .topCharts:
                return self.createHorizontalLayout()
            case .regular:
                return self.createGridLayout()
            }
        }
    }

    private func createFeaturedLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85), heightDimension: .absolute(250)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }

    private func createHorizontalLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(140), heightDimension: .absolute(200))
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(140), heightDimension: .absolute(200)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }

    private func createGridLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(220))
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(220)),
            subitems: [item, item]
        )
        return NSCollectionLayoutSection(group: group)
    }

    private func fetchData() {
        MovieService.shared.fetchAllMovies { movies in
            self.featuredMovies = movies.filter { $0.sectionName == MovieSection.featured.title }
            self.topChartMovies = movies.filter { $0.sectionName == MovieSection.topCharts.title }
            self.regularMovies = movies.filter { $0.sectionName == MovieSection.regular.title }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return MovieSection.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = MovieSection(rawValue: section) else { return 0 }
        switch section {
        case .featured:
            return featuredMovies.count
        case .topCharts:
            return topChartMovies.count
        case .regular:
            return regularMovies.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.identifier, for: indexPath) as? MovieCell else {
            return UICollectionViewCell()
        }

        guard let section = MovieSection(rawValue: indexPath.section) else { return cell }

        let movie: Movie
        switch section {
        case .featured:
            movie = featuredMovies[indexPath.item]
        case .topCharts:
            movie = topChartMovies[indexPath.item]
        case .regular:
            movie = regularMovies[indexPath.item]
        }

        cell.configure(with: movie)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = MovieSection(rawValue: indexPath.section) else { return }
        let movie: Movie
        switch section {
        case .featured:
            movie = featuredMovies[indexPath.item]
        case .topCharts:
            movie = topChartMovies[indexPath.item]
        case .regular:
            movie = regularMovies[indexPath.item]
        }

        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

