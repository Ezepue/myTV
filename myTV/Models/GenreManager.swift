import UIKit

// Singleton class used to map genre IDs (from TMDB API) to readable names
class GenreManager {
    // Shared instance for global access (singleton pattern)
    static let shared = GenreManager()
    
    // Dictionary mapping TMDB genre IDs to human-readable genre names
    private let genreMap: [Int: String] = [
        28: "Action",
        12: "Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        14: "Fantasy",
        36: "History",
        27: "Horror",
        10402: "Music",
        9648: "Mystery",
        10749: "Romance",
        878: "Sci-Fi",
        10770: "TV Movie",
        53: "Thriller",
        10752: "War",
        37: "Western"
    ]
    
    // Converts an array of genre IDs into their corresponding names
    func getGenres(for ids: [Int]) -> [String] {
        // Uses compactMap to ignore any IDs not found in the map
        return ids.compactMap { genreMap[$0] }
    }
}

// Extension on Movie struct to expose genres as an array of strings
extension Movie {
    // Computed property: returns genre names from the genre IDs
    var genres: [String] {
        return genreIDs != nil
            ? GenreManager.shared.getGenres(for: genreIDs!)  // Force unwrapped because you check for nil
            : [] // Returns empty array if genreIDs is nil
    }
}
