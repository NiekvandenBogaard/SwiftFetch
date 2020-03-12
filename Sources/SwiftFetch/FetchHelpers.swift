//
//  FetchHelpers.swift
//  SwiftFetch
//
//  Created by Niek van den Bogaard on 12/03/2020.
//  Copyright © 2020 Niek van den Bogaard. All rights reserved.
//

import Foundation

/// Create a new fetch task.
/// - Parameters:
///   - request: The request.
///   - method: The request method. default `.get`
///   - query: The request query parameters.
///   - body: The request body.
///   - headers: The request headers.
public func fetch(_ request: URLRequest, method: FetchMethod = .get, query: [String: String?]? = nil, body: FetchRequestBody? = nil, headers: [String: String]? = nil) -> FetchTask {
    
    return Fetch.default.request(request, method: method, query: query, body: body, headers: headers)
}


/// Create a new fetch task.
/// - Parameters:
///   - url: The request url.
///   - method: The request method. default `.get`
///   - query: The request query parameters.
///   - body: The request body.
///   - headers: The request headers.
public func fetch(_ url: URL, method: FetchMethod = .get, query: [String: String?]? = nil, body: FetchRequestBody? = nil, headers: [String: String]? = nil) -> FetchTask {
    
    return Fetch.default.request(url, method: method, query: query, body: body, headers: headers)
}
