//
//  FetchTask.swift
//  SwiftFetch
//
//  Created by Niek van den Bogaard on 12/03/2020.
//  Copyright © 2020 Niek van den Bogaard. All rights reserved.
//

import Foundation

open class FetchTask {
    
    public var session: URLSession
    public var urlRequest: URLRequest
    public var queryParameters: [String: String?]?
    public var requestBody: FetchRequestBody?
    
    public init(session: URLSession, request: URLRequest, method: FetchMethod, query: [String: String?]?, body: FetchRequestBody?, headers: [String: String]?) {
        
        self.session = session
        urlRequest = request
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers ?? [:]
        queryParameters = query
        requestBody = body
    }
    
    private func execute(adaptor: ((URLRequest) -> URLRequest)?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        var urlRequest = self.urlRequest
        
        if let queryParameters = queryParameters, let url = urlRequest.url, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            
            var queryItems = queryParameters.map { URLQueryItem(name: $0, value: $1) }
            
            if let existing = urlComponents.queryItems {
                queryItems = existing + queryItems
            }
            
            urlComponents.queryItems = queryItems
            
            if let url = urlComponents.url {
                urlRequest.url = url
            }
        }
        
        if let requestBody = requestBody {
            do {
                
                urlRequest = try requestBody.adapt(urlRequest)
                
            } catch(let error) {
                
                completionHandler(nil, nil, error)
                return
            }
        }
        
        if let adaptor = adaptor {
            
            urlRequest = adaptor(urlRequest)
        }
        
        session.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
    }
    
    open func response(queue: DispatchQueue = .main, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            self.execute(adaptor: nil) { (data, response, error) in
                
                queue.async {
                    completionHandler(data, response, error)
                }
            }
        }
    }
    
    open func response<T>(body responseBody: FetchResponseBody<T>, queue: DispatchQueue = .main, completionHandler: @escaping (Result<T, Error>, URLResponse?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            self.execute(adaptor: responseBody.adapt) { (data, response, error) in
                
                let result: Result<T, Error>
                
                if let error = error {
                    result = .failure(error)
                } else if let data = data, let response = response {
                    do {
                        
                        let body = try responseBody.decode(response, data)
                        result = .success(body)
                        
                    } catch(let error) {
                        
                        result = .failure(error)
                    }
                } else {
                    result = .failure(NSError())
                }
                
                queue.async {
                    completionHandler(result, response)
                }
            }
        }
    }
}

