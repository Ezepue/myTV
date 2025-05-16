//
//  MovieApiService.swift
//  myTV
//
//  Created by Ezepue on 5/15/25.
//

import Foundation

class MovieApiService {
    static let shared = MovieApiService()
    private let apiKey = "b1a3142e007af3cdca542de5201e9b4d"
    private let baseURL = "https://api.themoviedb.org/3/movie/popular"

    func fetchMovies(completion: @escaping ([Movie]) -> Void) {
        guard let url = URL(string: "\(baseURL)?api_key=\(apiKey)&language=en-US&page=1")
        else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            do {
                let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(movieResponse.results) 
                }
            } catch {
                print("Failed to Decode:", error)
            }
        }.resume()
    }
}
