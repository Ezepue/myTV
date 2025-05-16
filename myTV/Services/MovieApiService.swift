//
//  MovieApiService.swift
//  myTV
//
//  Created by Ezepue on 5/15/25.
//

import Foundation

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

    func searchMovies(query: String, completion: @escaping ([Movie]) -> Void) {
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(queryEncoded)"
        
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.results)
                }
            } catch {
                print("Search failed: \(error)")
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

