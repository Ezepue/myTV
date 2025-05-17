import UIKit

class MovieTableViewCell: UITableViewCell {
    static let identifier = "MovieTableViewCell" // Cell reuse identifier

    // MARK: - UI Elements

    // Card-style container for content with rounded corners and shadow
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1) // Dark gray background
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Poster image
    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true // Prevents image overflow
        iv.layer.cornerRadius = 10
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // Movie title
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Release year
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Genre label
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        contentView.backgroundColor = .black
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Called before a cell is reused — reset image and labels to avoid flickering
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = UIImage(named: "placeholder")
        titleLabel.text = nil
        yearLabel.text = nil
        genreLabel.text = nil
        imageURL = nil
    }

    // MARK: - Setup Views

    private func setupViews() {
        // Add and layout subviews
        contentView.addSubview(cardView)
        cardView.addSubview(posterImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(yearLabel)
        cardView.addSubview(genreLabel)

        // Apply constraints for layout
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            posterImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            posterImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 80),
            posterImageView.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            yearLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            yearLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            genreLabel.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 4),
            genreLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            genreLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            genreLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Configure

    private var imageURL: URL? // Used to prevent loading wrong image after reuse

    // Configure the cell with movie data
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        yearLabel.text = movie.releaseDate?.prefix(4).description ?? "N/A"
        genreLabel.text = movie.genres.joined(separator: " • ")
        posterImageView.image = UIImage(named: "placeholder") // Placeholder before image loads

        // Load poster image asynchronously
        guard let posterPath = movie.posterPath,
              let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") else {
            return
        }

        imageURL = url // Track current URL to avoid mismatch if cell reused

        // Fetch image on a background thread
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  self.imageURL == url else { return }

            // Update UI on main thread
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}

