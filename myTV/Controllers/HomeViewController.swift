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
        title = "myTV"
        configureCollectionView()
        fetchData()
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        collectionView.register(SectionHeaderView.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: SectionHeaderView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)

            let isFeatured = sectionIndex == MovieSection.featured.rawValue
            let height: CGFloat = isFeatured ? 220 : 180
            let width: NSCollectionLayoutDimension = isFeatured ? .fractionalWidth(0.85) : .absolute(150)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: width,
                heightDimension: .absolute(height)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16)
            section.interGroupSpacing = 12

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: -10, trailing: 0)
            section.boundarySupplementaryItems = [header]

            return section
        }
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

    private func movies(for section: MovieSection) -> [Movie] {
        switch section {
        case .featured: return featuredMovies
        case .topCharts: return topChartMovies
        case .regular: return regularMovies
        }
    }
}

// MARK: - SectionHeaderDelegate
extension HomeViewController: SectionHeaderDelegate {
    func didTapSectionHeader(title: String) {
        guard let section = MovieSection.allCases.first(where: { $0.title == title }) else { return }
        let listVC = MovieListViewController(movies: movies(for: section), title: section.title)
        navigationController?.pushViewController(listVC, animated: true)
    }
}

// MARK: - CollectionView DataSource & Delegate
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return MovieSection.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = MovieSection(rawValue: section) else { return 0 }
        return movies(for: section).count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieCell.identifier,
            for: indexPath
        ) as? MovieCell,
        let section = MovieSection(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }

        cell.configure(with: movies(for: section)[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = MovieSection(rawValue: indexPath.section) else { return }
        let movie = movies(for: section)[indexPath.item]
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.identifier,
                for: indexPath
              ) as? SectionHeaderView,
              let section = MovieSection(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }

        header.configure(with: section.title, delegate: self)
        return header
    }
}

