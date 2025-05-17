import UIKit

// This ViewController displays a vertical list of movies for a selected section (e.g. "Top Charts")
class MovieListViewController: UIViewController {
    private let movies: [Movie] // Array of movies to display
    private let sectionTitle: String // Title shown in the navigation bar

    // TableView to show the list of movies
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .black
        tv.separatorStyle = .none // Removes default cell separator lines
        return tv
    }()

    // Custom initializer to pass movies and section title
    init(movies: [Movie], title: String) {
        self.movies = movies
        self.sectionTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    // Required for using UIViewController subclasses with storyboards (not used here)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Called when the view has loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        title = sectionTitle // Set the nav bar title
        view.backgroundColor = .black
        setupTableView()
    }

    // Sets up tableView layout and registers cell class
    private func setupTableView() {
        view.addSubview(tableView)

        // Pin tableView to all edges of the screen
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Set tableView data source and delegate to self
        tableView.dataSource = self
        tableView.delegate = self

        // Register custom cell class for reuse
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MovieListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Number of rows = number of movies in the array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    // Dequeue and configure a cell for each movie
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Safely dequeue a reusable MovieTableViewCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell() // fallback cell if dequeuing fails
        }

        // Configure the cell with the movie at this index
        cell.configure(with: movies[indexPath.row])
        return cell
    }

    // Handle row selection (navigate to MovieDetailViewController)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect for visual feedback

        let movie = movies[indexPath.row]
        let detailVC = MovieDetailViewController(movie: movie)

        // Push the detail view controller onto the navigation stack
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // Set a consistent row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
