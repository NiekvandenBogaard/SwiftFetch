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
    
    /// Internal function to get the apdapted request.
    private func request(adaptor: ((URLRequest) -> URLRequest)? = nil) throws -> URLRequest {
        
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
            
            urlRequest = try requestBody.adapt(urlRequest)
        }
        
        if let adaptor = adaptor {
            
            urlRequest = adaptor(urlRequest)
        }
        
        return urlRequest
    }
    
    /// Internal function to get the data response result.
    /// - Parameters:
    ///   - data: The response data
    ///   - error: The response error.
    private func result<T>(data: T?, error: Error?) -> Result<T?, Error> {
        
        if let error = error {
            
            return .failure(error)
            
        } else {
            
            return .success(data)
        }
    }
    
    /// Internal function to get the decoded response result.
    /// - Parameters:
    ///   - data: The response data.
    ///   - response: The response object.
    ///   - error: The response error.
    ///   - decoder: A decoder to use.
    private func result<T>(data: Data?, response: URLResponse?, error: Error?, decoder: FetchResponseBody<T>.Decoder) -> Result<T, Error> {
        
        if let error = error {
            
            return .failure(error)
            
        } else if let data = data, let response = response {
            
            do {
                
                return .success(try decoder(response, data))
                
            } catch(let error) {
                
                return .failure(error)
            }
            
        } else {
            
            return .failure(NSError())
        }
    }
    
    // MARK: Data response
    
    /// Execute the request receiving the desired response body.
    /// - Parameters:
    ///   - responseBody: The response body.
    ///   - queue: The queue on which the completion handler is dispatched.
    ///   - completionHandler: The completion handler.
    open func response<T>(body responseBody: FetchResponseBody<T>, queue: DispatchQueue? = nil, completionHandler: @escaping (Result<T, Error>, URLResponse?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            let request: URLRequest
            
            do {
                
                request = try self.request(adaptor: responseBody.adapt)
                
            } catch {
                
                completionHandler(.failure(error), nil)
                return
            }
            
            let task = self.session.dataTask(with: request) { (data, response, error) in
                
                let result = self.result(data: data, response: response, error: error, decoder: responseBody.decode)
                
                (queue ?? DispatchQueue.main).async {
                    completionHandler(result, response)
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: Data response (raw)
    
    /// Execute the request receiving a data response body.
    /// - Parameters:
    ///   - queue: The queue on which the completion handler is dispatched.
    ///   - completionHandler: The completion handler.
    open func response(queue: DispatchQueue? = nil, completionHandler: @escaping (Result<Data?, Error>, URLResponse?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            let request: URLRequest
            
            do {
                
                request = try self.request()
                
            } catch {
                
                completionHandler(.failure(error), nil)
                return
            }
            
            let task = self.session.dataTask(with: request) { (data, response, error) in
                
                let result = self.result(data: data, error: error)
                
                (queue ?? DispatchQueue.main).async {
                    completionHandler(result, response)
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: Download response
    
    /// Execute a download request that receives the contents of a URL, saves the results to a file, and calls a handler upon completion.
    /// - Parameters:
    ///   - queue: The queue on which the completion handler is dispatched.
    ///   - completionHandler: The completion handler.
    open func download(queue: DispatchQueue? = nil, completionHandler: @escaping (Result<URL?, Error>, URLResponse?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            let request: URLRequest
            
            do {
                
                request = try self.request()
                
            } catch {
                
                completionHandler(.failure(error), nil)
                return
            }
            
            let task = self.session.downloadTask(with: request) { (url, response, error) in
                
                let result = self.result(data: url, error: error)
                
                (queue ?? DispatchQueue.main).async {
                    completionHandler(result, response)
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: Upload response
    
    /// Execute a upload request.
    /// - Parameters:
    ///   - data: The data to upload.
    ///   - responseBody: The response body.
    ///   - queue: The queue on which the completion handler is dispatched.
    ///   - completionHandler: The completion handler.
    open func upload<T>(from data: Data, body responseBody: FetchResponseBody<T>, queue: DispatchQueue? = nil, completionHandler: @escaping (Result<T, Error>, URLResponse?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            let request: URLRequest
            
            do {
                
                request = try self.request(adaptor: responseBody.adapt)
                
            } catch {
                
                completionHandler(.failure(error), nil)
                return
            }
            
            let task = self.session.uploadTask(with: request, from: data) { (data, response, error) in
                
                let result = self.result(data: data, response: response, error: error, decoder: responseBody.decode)
                
                (queue ?? DispatchQueue.main).async {
                    completionHandler(result, response)
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: Upload response (raw)
    
    /// Execute a upload request.
    /// - Parameters:
    ///   - data: The data to upload.
    ///   - queue: The queue on which the completion handler is dispatched.
    ///   - completionHandler: The completion handler.
    open func upload(from data: Data, queue: DispatchQueue? = nil, completionHandler: @escaping (Result<Data?, Error>, URLResponse?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            let request: URLRequest
            
            do {
                
                request = try self.request()
                
            } catch {
                
                completionHandler(.failure(error), nil)
                return
            }
            
            let task = self.session.uploadTask(with: request, from: data) { (data, response, error) in
                
                let result = self.result(data: data, error: error)
                
                (queue ?? DispatchQueue.main).async {
                    completionHandler(result, response)
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: File upload response
    
    /// Execute a file upload request.
    /// - Parameters:
    ///   - fileURL: The URL of the file to upload.
    ///   - responseBody: The response body.
    ///   - queue: The queue on which the completion handler is dispatched.
    ///   - completionHandler: The completion handler.
    open func upload<T>(fromFile fileURL: URL, body responseBody: FetchResponseBody<T>, queue: DispatchQueue? = nil, completionHandler: @escaping (Result<T, Error>, URLResponse?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            let request: URLRequest
            
            do {
                
                request = try self.request(adaptor: responseBody.adapt)
                
            } catch {
                
                completionHandler(.failure(error), nil)
                return
            }
            
            let task = self.session.uploadTask(with: request, fromFile: fileURL) { (data, response, error) in
                
                let result = self.result(data: data, response: response, error: error, decoder: responseBody.decode)
                
                (queue ?? DispatchQueue.main).async {
                    completionHandler(result, response)
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: File upload response (raw)
    
    /// Execute a file upload request.
    /// - Parameters:
    ///   - fileURL: The URL of the file to upload.
    ///   - queue: The queue on which the completion handler is dispatched.
    ///   - completionHandler: The completion handler.
    open func upload(fromFile fileURL: URL, queue: DispatchQueue? = nil, completionHandler: @escaping (Result<Data?, Error>, URLResponse?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            let request: URLRequest
            
            do {
                
                request = try self.request()
                
            } catch {
                
                completionHandler(.failure(error), nil)
                return
            }
            
            let task = self.session.uploadTask(with: request, fromFile: fileURL) { (data, response, error) in
                
                let result = self.result(data: data, error: error)
                
                (queue ?? DispatchQueue.main).async {
                    completionHandler(result, response)
                }
            }
            
            task.resume()
        }
    }
}
