import Foundation

struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let genreIDs: [Int]?

    // Mutable field to assign section later
    var sectionName: String?

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var genresText: String {
        GenreManager.shared.getGenres(for: genreIDs ?? []).joined(separator: ", ")
    }

    var formattedDate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        if let releaseDate = releaseDate,
           let date = inputFormatter.date(from: releaseDate) {
            return outputFormatter.string(from: date)
        }
        return releaseDate ?? "Unknown"
    }

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case genreIDs = "genre_ids"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decode(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage)
        genreIDs = try container.decodeIfPresent([Int].self, forKey: .genreIDs)
        sectionName = nil
    }
}

struct MovieResponse: Decodable {
    let results: [Movie]
}
