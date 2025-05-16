//
//  MovieApiService.swift
//  myTV
//
//  Created by Ezepue on 5/15/25.
//

import Foundation

/* Implements the singleton pattern with shared instance, stores TMDB API key and base URL, maintains a private dictionary to cache genre ID-name mappings */
class MovieService {
    static let shared = MovieService()
    private let apiKey = "b1a3142e007af3cdca542de5201e9b4d"
    private let baseURL = "https://api.themoviedb.org/3"
    
    private var genres: [Int: String] = [:]

    private init() {}

    // Fetch Movies from multiple endpoints
    func fetchAllMovies(completion: @escaping ([Movie]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var allMovies: [Movie] = []

        fetchGenres() {
            let endpoints = [
                ("/movie/popular", "Popular"),
                ("/movie/top_rated", "Top Chart"),
                ("/movie/now_playing", "Featured")
            ]
            
            /* Makes parallel requests to each endpoint, marks section for each movie, accumulates results in allMovies */
            for (path, section) in endpoints {
                dispatchGroup.enter()
                self.fetchMovies(from: path) { movies in
                    var updatedMovies = movies
                    for i in 0..<updatedMovies.count {
                        updatedMovies[i].sectionName = section
                    }
                    allMovies += updatedMovies
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(allMovies)
            }
        }
    }

    // Fetch Movies from a specific endpoint
    private func fetchMovies(from path: String, completion: @escaping ([Movie]) -> Void) {
        guard let url = URL(string: "\(baseURL)\(path)?api_key=\(apiKey)&language=en-US&page=1") else {
            completion([])
            return
        }
        
        // Performs network request and handles errors by returning empty array
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print("Error fetching movies: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            do {
                let movies = try JSONDecoder().decode(MovieResponse.self, from: data).results
                completion(movies)
            } catch {
                print("Failed to Decode:", error)
                completion([])
            }
        }.resume()
    }

    // Fetch Genre Mapping
    private func fetchGenres(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(baseURL)/genre/movie/list?api_key=\(apiKey)&language=en-US") else {
            completion()
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion()
                return
            }

            do {
                let genreResponse = try JSONDecoder().decode(GenreResponse.self, from: data)
                for genre in genreResponse.genres {
                    self.genres[genre.id] = genre.name
                }
                completion()
            } catch {
                print("Error decoding genre list:", error)
                completion()
            }
        }.resume()
    }
}

// Genre Models
struct GenreResponse: Decodable {
    let genres: [Genre]
}

struct Genre: Decodable {
    let id: Int
    let name: String
}
