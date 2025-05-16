import UIKit

// MARK: - Section Header Delegate
protocol SectionHeaderDelegate: AnyObject {
    func didTapSectionHeader(title: String)
}

// MARK: - Section Header View
class SectionHeaderView: UICollectionReusableView {
    static let identifier = "SectionHeaderView"

    weak var delegate: SectionHeaderDelegate?
    private var title: String?

    // MARK: - Subviews
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = UIColor.white.withAlphaComponent(0.7)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        styleHeader()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    func configure(with title: String, delegate: SectionHeaderDelegate?) {
        self.title = title
        self.delegate = delegate
        titleLabel.text = title
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        title = nil
        titleLabel.text = nil
        delegate = nil
    }

    // MARK: - Setup
    private func setupViews() {
        isUserInteractionEnabled = true

        addSubview(titleLabel)
        addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            arrowImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 16),
            arrowImageView.heightAnchor.constraint(equalToConstant: 16)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        addGestureRecognizer(tapGesture)
    }

    private func styleHeader() {
        backgroundColor = UIColor.clear

        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomLine)

        NSLayoutConstraint.activate([
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    // MARK: - Actions
    @objc private func didTapHeader() {
        guard let title = title else { return }
        delegate?.didTapSectionHeader(title: title)

        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0.6
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.alpha = 1.0
            }
        }
    }
}

