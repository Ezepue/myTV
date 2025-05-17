import UIKit

class MovieDetailViewController: UIViewController {
    private let movie: Movie // Movie passed from previous screen

    // UI Elements
    private let imageView = UIImageView() // Displays movie poster
    private let titleLabel = UILabel() // Shows movie title
    private let genreLabel = UILabel() // Displays genres as text
    private let overviewLabel = UILabel() // Shows the movie description
    private let activityIndicator = UIActivityIndicatorView(style: .large) // Spinner while loading poster image
    private let scrollView = UIScrollView() // Allows vertical scrolling
    private let contentView = UIView() // Holds all UI inside scrollView

    // Custom initializer (used to pass in the movie)
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }

    // Required when not using storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Called after the view loads into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI() // Build and lay out all UI elements
        loadImage() // Download and show the movie poster image
    }

    // Set up UI layout and hierarchy
    private func setupUI() {
        // Enable auto layout for scrollView and contentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Add scrollView to main view, then contentView inside scrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Pin scrollView and contentView to their parent views
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Configure movie poster appearance
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .darkGray // Placeholder color
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true

        // Add and center loading spinner inside poster
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])

        // Set movie info on labels
        titleLabel.text = movie.title
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.numberOfLines = 0 // Allow multiple lines

        genreLabel.text = movie.genresText // Should be a computed property like "Action, Adventure"
        genreLabel.textColor = .systemGray2
        genreLabel.font = .systemFont(ofSize: 14)

        overviewLabel.text = movie.overview
        overviewLabel.textColor = .white
        overviewLabel.numberOfLines = 0
        overviewLabel.font = .systemFont(ofSize: 16)

        // Button stack (Buy + Rent side-by-side)
        let buttonStack = UIStackView(arrangedSubviews: [buyButton, rentButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        // Stack for entire layout (vertically)
        let stack = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            genreLabel,
            overviewLabel,
            buttonStack
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // Asynchronously load the poster image from a URL
    private func loadImage() {
        guard let url = movie.posterURL else {
            activityIndicator.stopAnimating()
            return
        }

        activityIndicator.startAnimating() // Show spinner

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let data = data {
                    self.imageView.image = UIImage(data: data) // Set image if download succeeded
                }
                self.activityIndicator.stopAnimating() // Hide spinner
            }
        }.resume()
    }

    // Action when "Buy" button is tapped
    @objc private func buyTapped() {
        openAppleTVLink(type: "buy")
    }

    // Action when "Rent" button is tapped
    @objc private func rentTapped() {
        openAppleTVLink(type: "rent")
    }

    // Opens a placeholder Apple TV URL based on movie title
    private func openAppleTVLink(type: String) {
        // Replace spaces with hyphens and lowercase the title
        guard let url = URL(string: "https://tv.apple.com/us/movie/\(movie.title.replacingOccurrences(of: " ", with: "-").lowercased())") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    // Button for "Buy" action
    private lazy var buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Buy", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(buyTapped), for: .touchUpInside)
        return button
    }()

    // Button for "Rent" action
    private lazy var rentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Rent", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(rentTapped), for: .touchUpInside)
        return button
    }()
}
