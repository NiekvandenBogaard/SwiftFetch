//
//  Fetch.swift
//  SwiftFetch
//
//  Created by Niek van den Bogaard on 12/03/2020.
//  Copyright © 2020 Niek van den Bogaard. All rights reserved.
//

import Foundation

open class Fetch {
    
    public static let `default` = Fetch(session: URLSession.shared)
    
    public let session: URLSession
    
    public init(session: URLSession) {
        
        self.session = session
    }
    
    open func request(_ request: URLRequest, method: FetchMethod = .get, query: [String: String?]? = nil, body: FetchRequestBody? = nil, headers: [String: String]? = nil) -> FetchTask {
        
        return FetchTask(session: session, request: request, method: method, query: query, body: body, headers: headers)
    }
    
    open func request(_ url: URL, method: FetchMethod = .get, query: [String: String?]? = nil, body: FetchRequestBody? = nil, headers: [String: String]? = nil) -> FetchTask {
        
        return request(URLRequest(url: url), method: method, query: query, body: body, headers: headers)
    }
}
