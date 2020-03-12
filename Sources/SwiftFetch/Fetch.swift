//
//  Fetch.swift
//  SwiftFetch
//
//  Created by Niek van den Bogaard on 12/03/2020.
//  Copyright © 2020 Niek van den Bogaard. All rights reserved.
//

import Foundation

open class Fetch {
    
    /// A default fetch session to use.
    public static let `default` = Fetch(session: URLSession.shared)
    
    /// The fetch session.
    public let session: URLSession
    
    /// Create a new fetch session.
    /// - Parameter session: The fetch session.
    public init(session: URLSession) {
        
        self.session = session
    }
    
    /// Create a new fetch task.
    /// - Parameters:
    ///   - request: The request.
    ///   - method: The request method. default `.get`
    ///   - query: The request query parameters.
    ///   - body: The request body.
    ///   - headers: The request headers.
    open func request(_ request: URLRequest, method: FetchMethod = .get, query: [String: String?]? = nil, body: FetchRequestBody? = nil, headers: [String: String]? = nil) -> FetchTask {
        
        return FetchTask(session: session, request: request, method: method, query: query, body: body, headers: headers)
    }
    
    /// Create a new fetch task.
    /// - Parameters:
    ///   - url: The request url.
    ///   - method: The request method. default `.get`
    ///   - query: The request query parameters.
    ///   - body: The request body.
    ///   - headers: The request headers.
    open func request(_ url: URL, method: FetchMethod = .get, query: [String: String?]? = nil, body: FetchRequestBody? = nil, headers: [String: String]? = nil) -> FetchTask {
        
        return request(URLRequest(url: url), method: method, query: query, body: body, headers: headers)
    }
}
