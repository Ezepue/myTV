//
//  Movie.swift
//  myTV
//
//  Created by Ezepue on 5/15/25.
//

import Foundation

struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let genreIDs: [Int]?
    

    var sectionName: String?  

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    var genresText: String {
        GenreManager.shared.getGenres(for: genreIDs ?? []).joined(separator: ", ")
    }

    var formattedDate: String {
        guard let releaseDate = releaseDate else { return "N/A" }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium

        if let date = inputFormatter.date(from: releaseDate) {
            return outputFormatter.string(from: date)
        } else {
            return releaseDate
        }
    }

    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case genreIDs = "genre_ids"
        }
}

struct MovieResponse: Decodable {
    let results: [Movie]
}
