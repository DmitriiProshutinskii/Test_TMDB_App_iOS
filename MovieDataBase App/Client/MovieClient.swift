//
//  MovieClient.swift
//  MovieDataBase App
//
//  Created by Физтех.Радио on 18.03.2021.
//

import Foundation

class MovieClient {
    static let _S: MovieClient = MovieClient()
    private init() { }
    
    // MARK: - Constants
    
    private var API_KEY = "a36749805672414961acf961120f0871"
    private var MOVIE_API_URL = "https://api.themoviedb.org/3/movie"
    private var urlSession = URLSession.shared
    private var jsonDecoder = fromJSON
    
    
    //MARK: - Get movies
    
    func fetchTopRatedMovies(completion: @escaping (Result<Movies, MovieError>) -> ()) {
        if let url = URL(string: "\(MOVIE_API_URL)/top_rated") {
            self.loadMoivesFromURL(url: url, completion: completion)
        }
        else {completion(.failure(.invalidEndpoint))}
    }
    
    func fetchMovie(id: Int, completion: @escaping (Result<Movie, MovieError>) -> ()) {
        if let url = URL(string: "\(MOVIE_API_URL)/\(id)") {
            self.loadMoivesFromURL(url: url, params: [
                "append_to_response": "videos,credits"
            ], completion: completion)
        }
    }
    
    
    //MARK: - Loader and utils
    
    func loadMoivesFromURL<D>(url: URL, params: [String: String]? = nil, completion: @escaping (Result<D, MovieError>) -> ()) where D: Decodable {
        //Создает URL адрес в соответствии с RFC 3986. Это позволит нам в будущем работать с большим количеством запросов видо QuerryItem
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        //Сами QuerryItem, которые создают пары ключ - значение для url запросов. Если параметр один, то один элемент в массиве
        var queryItems = [URLQueryItem(name: "api_key", value: API_KEY)]
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        
        //Добавляем items в urlComponents
        urlComponents.queryItems = queryItems
        
        //Получаем ссылку на url Звачем?
        guard let finalURL = urlComponents.url else {
            completion(.failure(.invalidEndpoint))
            return
        }
        //
        urlSession.dataTask(with: finalURL) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if error != nil {return}
            guard let data = data else {return}
            
            do {
                let decodedResponse = try self.jsonDecoder.decode(D.self, from: data)
                self.executeCompletionHandlerInMainThread(with: .success(decodedResponse), completion: completion)
            } catch {
                self.executeCompletionHandlerInMainThread(with: .failure(.serializationError), completion: completion)
            }
            
        }.resume()
        
    }
    
    private func executeCompletionHandlerInMainThread<D: Decodable>(with result: Result<D, MovieError>, completion: @escaping (Result<D, MovieError>) -> ()) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
    
    // MARK: - Static funcs and lets
    static let fromJSON: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        return dateFormatter
    }()
    
    
    //MARK: - Custom error realization
    
    enum MovieError: Error, CustomNSError {
        
        case apiError
        case invalidEndpoint
        case invalidResponse
        case noData
        case serializationError
        
        var localizedDescription: String {
            switch self {
            case .apiError: return "Failed to fetch data"
            case .invalidEndpoint: return "Invalid endpoint"
            case .invalidResponse: return "Invalid response"
            case .noData: return "No data"
            case .serializationError: return "Failed to decode data"
            }
        }
        
        var errorUserInfo: [String : Any] {
            [NSLocalizedDescriptionKey: localizedDescription]
        }
        
    }

}
