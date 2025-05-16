//
//  HorizontalMovieCell.swift
//  myTV
//
//  Created by Ezepue on 5/16/25.
//

import UIKit

class HorizontalMovieCell: UICollectionViewCell {
    static let identifier = "HorizontalMovieCell"
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func configure(with movie: Movie) {
        if let url = movie.posterURL {
            loadImage(from: url)
        }
    }

    // MARK: - Private Helpers

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        contentView.addSubview(imageView)
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self?.imageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
