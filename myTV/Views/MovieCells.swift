import UIKit  // UIKit provides the required UI components like UICollectionViewCell, UIImageView, UILabel, etc.

// MARK: - BaseMovieCell
/// A reusable base cell class for displaying a movie poster and title in a collection view.
class BaseMovieCell: UICollectionViewCell {
    
    // Image view to show the movie poster
    let imageView = UIImageView()
    
    // Label to show the movie title
    let titleLabel = UILabel()

    // Initializer when creating the cell programmatically
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()   // Add subviews and set up constraints
        styleCell()    // Apply styling like corner radius and shadows
    }

    // Required initializer for storyboard/XIB usage (not used here)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Called when a cell is reused. Clears previous content.
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
    }

    /// Configures the cell with a Movie object.
    /// - Parameters:
    ///   - movie: The movie model to display.
    ///   - showTitle: Determines whether to display the title label.
    func configure(with movie: Movie, showTitle: Bool = true) {
        titleLabel.isHidden = !showTitle
        titleLabel.text = showTitle ? movie.title : nil
        
        // Asynchronously load the movie poster image
        if let url = movie.posterURL {
            imageView.loadImage(from: url)
        }
    }

    // Sets up the view hierarchy and Auto Layout constraints
    private func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add views to the contentView
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        // Activate Auto Layout constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    // Applies visual styles to the cell like corner radius and shadows
    private func styleCell() {
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowOffset = CGSize(width: 0, height: 5)
        contentView.layer.shadowRadius = 8
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = .clear
    }
}


// MARK: - MovieCell
class MovieCell: BaseMovieCell {
    static let identifier = "MovieCell"
}

// MARK: - SingleMovieCell
class SingleMovieCell: BaseMovieCell {
    static let identifier = "SingleMovieCell"
}

// MARK: - HorizontalMovieCell
class HorizontalMovieCell: BaseMovieCell {
    static let identifier = "HorizontalMovieCell"

    override func configure(with movie: Movie, showTitle: Bool = false) {
        super.configure(with: movie, showTitle: showTitle)
    }
}

// MARK: - UIImageView Extension
extension UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                return
            }

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
