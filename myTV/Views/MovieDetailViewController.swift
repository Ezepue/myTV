//
//  MovieDetailViewController.swift
//  myTV
//
//  Created by Ezepue on 5/15/25.
//

import UIKit

class MovieDetailViewController: UIViewController {
    private let movie: Movie

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let genreLabel = UILabel()
    private let overviewLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

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
        // Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .darkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Activity Indicator
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        // Title Label
        titleLabel.text = movie.title
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.numberOfLines = 0

        // Genre Label
        genreLabel.text = movie.genresText
        genreLabel.textColor = .lightGray
        genreLabel.font = .italicSystemFont(ofSize: 14)

        // Overview Label
        overviewLabel.text = movie.overview
        overviewLabel.textColor = .white
        overviewLabel.numberOfLines = 0
        overviewLabel.font = .systemFont(ofSize: 16)

        // Stack View
        let stack = UIStackView(arrangedSubviews: [imageView, activityIndicator, titleLabel, genreLabel, overviewLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 300),

            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func loadImage() {
        guard let url = movie.posterURL else {
            activityIndicator.stopAnimating()
            return
        }

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
}
