import Foundation

/*
 Singleton class that handles all movie-related API calls.
 Uses TMDB API to fetch movies and genres.
 */
class MovieService {
    static let shared = MovieService()  // Singleton instance
    private let apiKey = "b1a3142e007af3cdca542de5201e9b4d"  // Your TMDB API key
    private let baseURL = "https://api.themoviedb.org/3"     // Base URL for TMDB requests
    
    private var genres: [Int: String] = [:]  // Optional local genre cache (not used in GenreManager right now)

    private init() {}  // Private constructor ensures only one instance is created

    // Fetch movies from multiple TMDB endpoints (Popular, Top Chart, Featured)
    func fetchAllMovies(completion: @escaping ([Movie]) -> Void) {
        let dispatchGroup = DispatchGroup()   // Helps sync multiple async calls
        var allMovies: [Movie] = []           // Store all fetched movies

        // First fetch genres so they’re ready before fetching movies
        fetchGenres() {
            let endpoints = [
                ("/movie/popular", "Popular"),
                ("/movie/top_rated", "Top Chart"),
                ("/movie/now_playing", "Featured")
            ]
            
            // For each endpoint, fetch its movies and tag them with a section
            for (path, section) in endpoints {
                dispatchGroup.enter()  // Start waiting on this task
                self.fetchMovies(from: path) { movies in
                    var updatedMovies = movies
                    for i in 0..<updatedMovies.count {
                        updatedMovies[i].sectionName = section  // Assign the section label
                    }
                    allMovies += updatedMovies
                    dispatchGroup.leave()  // Mark this task as done
                }
            }

            // When all fetches are done, return the complete movie list
            dispatchGroup.notify(queue: .main) {
                completion(allMovies)
            }
        }
    }

    // Fetch movies from a single TMDB endpoint (e.g., /movie/popular)
    private func fetchMovies(from path: String, completion: @escaping ([Movie]) -> Void) {
        guard let url = URL(string: "\(baseURL)\(path)?api_key=\(apiKey)&language=en-US&page=1") else {
            completion([])  // Invalid URL, return empty list
            return
        }
        
        // Start a network request
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print("Error fetching movies: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            do {
                // Try decoding the response into Movie objects
                let movies = try JSONDecoder().decode(MovieResponse.self, from: data).results
                completion(movies)
            } catch {
                print("Failed to Decode:", error)
                completion([])  // Return empty list on failure
            }
        }.resume()  // Important: starts the network call
    }

    // Fetches genre list from TMDB and stores it in local dictionary
    private func fetchGenres(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(baseURL)/genre/movie/list?api_key=\(apiKey)&language=en-US") else {
            completion()
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion()  // No data? Just move on
                return
            }

            do {
                // Decode the genre list
                let genreResponse = try JSONDecoder().decode(GenreResponse.self, from: data)
                for genre in genreResponse.genres {
                    self.genres[genre.id] = genre.name  // Save each genre in local cache
                }
                completion()
            } catch {
                print("Error decoding genre list:", error)
                completion()
            }
        }.resume()
    }
}

// Models for decoding genre JSON responses
struct GenreResponse: Decodable {
    let genres: [Genre]
}

struct Genre: Decodable {
    let id: Int         // Genre ID (e.g., 28)
    let name: String    // Genre name (e.g., "Action")
}
