import UIKit

// MARK: - Section Header Delegate
/// Protocol defining communication from header to its parent view/controller
protocol SectionHeaderDelegate: AnyObject {
    /// Notifies delegate when header is tapped
    /// - Parameter title: The section title that was tapped
    func didTapSectionHeader(title: String)
}

// MARK: - Section Header View
/// Reusable header view for collection view sections with title and chevron
class SectionHeaderView: UICollectionReusableView {
    // Reuse identifier for collection view registration
    static let identifier = "SectionHeaderView"

    // Weak reference to delegate to avoid retain cycles
    weak var delegate: SectionHeaderDelegate?
    private var title: String?  // Stores the current section title

    // MARK: - Subviews
    
    /// Primary title label for the section
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .heavy)  // Bold header text
        label.textColor = UIColor.white  // Light color for dark backgrounds
        label.translatesAutoresizingMaskIntoConstraints = false  // Enable AutoLayout
        // Content priority settings prevent truncation
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    /// Chevron icon indicating tappable/toggleable header
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = UIColor.white.withAlphaComponent(0.7)  // Semi-transparent white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit  // Maintain aspect ratio
        return imageView
    }()

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()  // Create and layout subviews
        styleHeader()  // Additional visual styling
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")  // Not supporting storyboards
    }

    // MARK: - Configuration
    
    /// Sets up the header content and delegate
    func configure(with title: String, delegate: SectionHeaderDelegate?) {
        self.title = title
        self.delegate = delegate
        titleLabel.text = title  // Display the section title
    }

    /// Cleans up before reuse in collection view
    override func prepareForReuse() {
        super.prepareForReuse()
        title = nil
        titleLabel.text = nil
        delegate = nil  // Important to avoid stale delegates
    }

    // MARK: - Setup
    
    /// Creates and arranges all subviews with constraints
    private func setupViews() {
        isUserInteractionEnabled = true  // Required for tap gestures

        // Add subviews to hierarchy
        addSubview(titleLabel)
        addSubview(arrowImageView)

        // Layout constraints:
        // - Title left-aligned with standard padding
        // - Chevron right-aligned with standard padding
        // - Chevron maintains fixed size
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            arrowImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 16),
            arrowImageView.heightAnchor.constraint(equalToConstant: 16)
        ])

        // Add tap gesture recognizer for header interaction
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        addGestureRecognizer(tapGesture)
    }

    /// Additional visual styling (separator line)
    private func styleHeader() {
        backgroundColor = UIColor.clear  // Transparent background

        // Create subtle bottom separator line
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.white.withAlphaComponent(0.1)  // Very faint line
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomLine)

        // Layout separator to span width with standard left padding
        NSLayoutConstraint.activate([
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 0.5)  // Hairline thickness
        ])
    }

    // MARK: - User Interaction
    
    /// Handles tap gesture with visual feedback and delegate notification
    @objc private func didTapHeader() {
        guard let title = title else { return }
        
        // Notify delegate about the tap
        delegate?.didTapSectionHeader(title: title)

        // Visual feedback: quick fade animation
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0.6  // Partially fade
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.alpha = 1.0  // Return to full opacity
            }
        }
    }
}
