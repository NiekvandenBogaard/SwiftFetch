//
//  FetchResponseBody.swift
//  SwiftFetch
//
//  Created by Niek van den Bogaard on 12/03/2020.
//  Copyright © 2020 Niek van den Bogaard. All rights reserved.
//

import Foundation

open class FetchResponseBody<T> {
    
    public typealias Adapter = (URLRequest) -> URLRequest
    public typealias Decoder = (URLResponse, Data) throws -> T
    
    public let decode: Decoder
    public let adapt: Adapter
    
    public init(decoder: @escaping Decoder, adapter: @escaping Adapter = ({ $0 })) {
        
        decode = decoder
        adapt = adapter
    }

    /// Raw data response body.
    public static func data() -> FetchResponseBody<Data> {
        
        return FetchResponseBody<Data>(decoder: { _, data in
            
            return data
        })
    }
    
    /// Text response body.
    /// - Parameter encoding: Encoding to use.
    public static func text(encoding: String.Encoding = .utf8) -> FetchResponseBody<String> {
        
        return FetchResponseBody<String>(decoder: { _, data in
            
            return String(data: data, encoding: encoding) ?? ""
        })
    }
    
    
    /// Json response body.
    /// - Parameters:
    ///   - type: Indicated type to decoded.
    ///   - decoder: Decoder to use.
    public static func json<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> FetchResponseBody<T> {
        
        return FetchResponseBody<T>(decoder: { _, data in
            
            return try decoder.decode(T.self, from: data)
            
        }, adapter: { urlRequest in
            
            var urlRequest = urlRequest
            
            // Set Accept header without overriding existing header.
            if nil == urlRequest.value(forHTTPHeaderField: "Accept") {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            }
            
            return urlRequest
        })
    }

    /// Json response body.
    public static func json() -> FetchResponseBody<[String: Any]> {
        
        return FetchResponseBody<[String: Any]>(decoder: { _, data in
            
            return ((try JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]) ?? [:]
            
        }, adapter: { urlRequest in
            
            var urlRequest = urlRequest
            
            // Set Accept header without overriding existing header.
            if nil == urlRequest.value(forHTTPHeaderField: "Accept") {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            }
            
            return urlRequest
        })
    }
    
    /// Urlencoded body.
    /// - Parameter encoding: Encoding to use.
    public static func urlEncoded(encoding: String.Encoding = .utf8) -> FetchResponseBody<[String: String?]?> {
        
        return FetchResponseBody<[String: String?]?>(decoder: { request, data in
            
            let query = try text(encoding: encoding).decode(request, data)
            
            var urlComponents = URLComponents()
            urlComponents.percentEncodedQuery = query
            
            return urlComponents.queryItems?.reduce(into: [String: String?](), { (values, item) in
                values[item.name] = item.value
            })
            
        }, adapter: { urlRequest in
            
            var urlRequest = urlRequest
            
            // Set Accept header without overriding existing header.
            if nil == urlRequest.value(forHTTPHeaderField: "Accept") {
                urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
            }
            
            return urlRequest
        })
    }
}
