import UIKit

class MovieDetailViewController: UIViewController {
    private let movie: Movie

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let genreLabel = UILabel()
    private let overviewLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        loadImage()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

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

        // Configure views
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .darkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true

        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])

        titleLabel.text = movie.title
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.numberOfLines = 0

        genreLabel.text = movie.genresText
        genreLabel.textColor = .systemGray2
        genreLabel.font = .systemFont(ofSize: 14)

        overviewLabel.text = movie.overview
        overviewLabel.textColor = .white
        overviewLabel.numberOfLines = 0
        overviewLabel.font = .systemFont(ofSize: 16)

        let buttonStack = UIStackView(arrangedSubviews: [buyButton, rentButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

    
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


    private func loadImage() {
        guard let url = movie.posterURL else {
            activityIndicator.stopAnimating()
            return
        }

        activityIndicator.startAnimating()

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let data = data {
                    self.imageView.image = UIImage(data: data)
                }
                self.activityIndicator.stopAnimating()
            }
        }.resume()
    }
    
    
    @objc private func buyTapped() {
        openAppleTVLink(type: "buy")
    }

    @objc private func rentTapped() {
        openAppleTVLink(type: "rent")
    }

    private func openAppleTVLink(type: String) {
        // Sample Apple TV link (you'd replace this with a real one from your data model or API)
        guard let url = URL(string: "https://tv.apple.com/us/movie/\(movie.title.replacingOccurrences(of: " ", with: "-").lowercased())") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }


    // Buy Button
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

    // Rent Button
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
