//
//  MovieDetailViewController.swift
//  myTV
//
//  Created by Ezepue on 5/15/25.
//

import UIKit

class MovieDetailViewController: UIViewController {
    let movie: Movie

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

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        if let url = movie.posterURL {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }

        let titleLabel = UILabel()
        titleLabel.text = movie.title
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        titleLabel.textColor = .white

        let overviewLabel = UILabel()
        overviewLabel.text = movie.overview
        overviewLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        overviewLabel.textColor = .lightGray
        overviewLabel.numberOfLines = 0

        let ratingLabel = UILabel()
        ratingLabel.text = "Rating: \(String(format: "%.1f", movie.voteAverage))/10"
        ratingLabel.textColor = .white

        let releaseLabel = UILabel()
        releaseLabel.text = "Release Date: \(movie.releaseDate)"
        releaseLabel.textColor = .white

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, overviewLabel, ratingLabel, releaseLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
