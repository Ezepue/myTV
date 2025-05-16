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
    let releaseDate: String
    let voteAverage: Double

    var posterURL: URL? {
        guard let path = posterPath else {
            return nil
        }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    enum CodingKeys: String, CodingKey {
            case id
            case title
            case overview
            case posterPath = "poster_path"
            case releaseDate = "release_date"
            case voteAverage = "vote_average"
        }
    }

struct MovieResponse: Decodable {
    let results: [Movie]
}
