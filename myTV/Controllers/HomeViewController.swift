import UIKit

// Enum representing sections in the home screen
enum MovieSection: Int, CaseIterable {
    case featured
    case topCharts
    case regular

    // Title to be displayed in the section header
    var title: String {
        switch self {
        case .featured: return "Featured"
        case .topCharts: return "Top Chart"
        case .regular: return "Popular"
        }
    }
}

// Main view controller displaying the home screen of the app
class HomeViewController: UIViewController {
    private var collectionView: UICollectionView!

    // Separate movie arrays for each section
    private var featuredMovies: [Movie] = []
    private var topChartMovies: [Movie] = []
    private var regularMovies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "myTV"  // Title displayed in the navigation bar
        configureCollectionView()
        fetchData()
    }

    // Setup and configure the collection view with custom layout
    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Register cell and header view classes
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier
        )
        
        // Set delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        view.addSubview(collectionView)
    }

    // Create a compositional layout for different section types
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            // Define item size
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)

            // Set different sizes for featured vs regular items
            let isFeatured = sectionIndex == MovieSection.featured.rawValue
            let height: CGFloat = isFeatured ? 320 : 180
            let width: NSCollectionLayoutDimension = isFeatured ? .fractionalWidth(0.92) : .absolute(150)

            // Define group of items
            let groupSize = NSCollectionLayoutSize(
                widthDimension: width,
                heightDimension: .absolute(height)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            // Define the section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16)
            section.interGroupSpacing = 12

            // Add header to each section
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

    // Fetch movie data and divide it into sections based on their tags
    private func fetchData() {
        MovieService.shared.fetchAllMovies { movies in
            // Categorize movies by section
            self.featuredMovies = movies.filter { $0.sectionName == MovieSection.featured.title }
            self.topChartMovies = movies.filter { $0.sectionName == MovieSection.topCharts.title }
            self.regularMovies = movies.filter { $0.sectionName == MovieSection.regular.title }

            // Reload the collection view on the main thread
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    // Helper function to get movies for a given section
    private func movies(for section: MovieSection) -> [Movie] {
        switch section {
        case .featured: return featuredMovies
        case .topCharts: return topChartMovies
        case .regular: return regularMovies
        }
    }
}

// MARK: - SectionHeaderDelegate (Handles taps on section headers)
extension HomeViewController: SectionHeaderDelegate {
    func didTapSectionHeader(title: String) {
        // Match the title to the correct section
        guard let section = MovieSection.allCases.first(where: { $0.title == title }) else { return }

        // Navigate to a full movie list screen
        let listVC = MovieListViewController(movies: movies(for: section), title: section.title)
        navigationController?.pushViewController(listVC, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate
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
        // Dequeue reusable MovieCell and configure it
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieCell.identifier,
            for: indexPath
        ) as? MovieCell,
        let section = MovieSection(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }

        let movie = movies(for: section)[indexPath.item]
        cell.configure(with: movie)
        return cell
    }

    // Handle taps on movie cells to show movie details
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = MovieSection(rawValue: indexPath.section) else { return }
        let movie = movies(for: section)[indexPath.item]
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // Provide header view for each section
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

        // Configure header with title and delegate
        header.configure(with: section.title, delegate: self)
        return header
    }
}
