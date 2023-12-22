//
//  MovieAPIController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 11/1/22.
//

import Foundation


class MovieAPIController {
    
    let baseURL = URL(string: "http://www.omdbapi.com/")!
    let apiKey = "28ea6f95"
    
    struct SearchResponse: Codable {
        let movies: [APIMovie]
        
        enum CodingKeys: String, CodingKey {
            case movies = "Search"
        }
        
        init(movies: [APIMovie]) {
            self.movies = movies
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            movies = try container.decode([APIMovie].self, forKey: .movies)
            
        }
    }

    
    func fetchMovies(with searchTerm: String) async throws -> [APIMovie] {
        var searchURL = baseURL
        let searchItem = URLQueryItem(name: "s", value: searchTerm)
        let apiKeyItem = URLQueryItem(name: "apiKey", value: apiKey)
        searchURL.append(queryItems: [searchItem, apiKeyItem])
        
        let (data, _) = try await URLSession.shared.data(from: searchURL)
        
        let jsonDecoder = JSONDecoder()
        let searchResponse = try jsonDecoder.decode(SearchResponse.self, from: data)
        
        return searchResponse.movies
    }
}
