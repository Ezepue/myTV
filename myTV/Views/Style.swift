import UIKit

// Extension to add custom font styles that can be used throughout the app
extension UIFont {
    // Title style - large and semi-bold, typically for main headings
    static let titleFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    
    // Subtitle style - medium size and weight, for secondary headings
    static let subtitleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    
    // Body style - standard reading size for most text content
    static let bodyFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    // Caption style - small and light, for supplementary text or footnotes
    static let captionFont = UIFont.systemFont(ofSize: 12, weight: .light)
}


