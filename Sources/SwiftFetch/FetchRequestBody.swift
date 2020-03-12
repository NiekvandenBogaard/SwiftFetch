//
//  FetchRequestBody.swift
//  SwiftFetch
//
//  Created by Niek van den Bogaard on 12/03/2020.
//  Copyright © 2020 Niek van den Bogaard. All rights reserved.
//

import Foundation

open class FetchRequestBody {
    
    public typealias Adapter = (URLRequest) throws -> URLRequest
    
    public let adapt: Adapter
    
    public init(adapter: @escaping Adapter) {
        
        adapt = adapter
    }
    
    /// Raw data request body.
    /// - Parameter data: The data for the request body.
    public static func data(_ data: Data) -> FetchRequestBody {
        
        return FetchRequestBody { urlRequest in
            
            var urlRequest = urlRequest
            urlRequest.httpBody = data
            return urlRequest
        }
    }
    
    /// Text request body.
    /// - Parameters:
    ///   - text: The string for the request body.
    ///   - encoding: Encoding to use.
    public static func text(_ text: String, encoding: String.Encoding = .utf8) -> FetchRequestBody {
        
        return FetchRequestBody { urlRequest in
            
            let data = text.data(using: encoding)
            
            var urlRequest = urlRequest
            urlRequest.httpBody = data
            return urlRequest
        }
    }
    
    /// Json request body. Using encodable instance.
    /// - Parameters:
    ///   - value: Encodable instance.
    ///   - encoder: Encoder to use.
    public static func json<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) -> FetchRequestBody {
        
        return FetchRequestBody { urlRequest in
            
            let data = try encoder.encode(value)

            var urlRequest = urlRequest
            urlRequest.httpBody = data
            
            // Set Content-Type header without overriding existing header.
            if nil == urlRequest.value(forHTTPHeaderField: "Content-Type") {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            return urlRequest
        }
    }
    
    /// Json request body. Using dictionary.
    /// - Parameter value: Dictionary with key/value pairs.
    public static func json(_ value: [String: Any]) -> FetchRequestBody {
        
        return FetchRequestBody { urlRequest in
            
            let data = try JSONSerialization.data(withJSONObject: value, options: [])
            
            var urlRequest = urlRequest
            urlRequest.httpBody = data
            
            // Set Content-Type header without overriding existing header.
            if nil == urlRequest.value(forHTTPHeaderField: "Content-Type") {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            return urlRequest
        }
    }
    
    /// Urlencoded request body. Using dictionary. Recommended.
    /// - Parameters:
    ///   - values: Dictionary with key/value pairs.
    ///   - encoding: Encoding to use.
    public static func urlEncoded(_ values: [String: String?], encoding: String.Encoding = .utf8) -> FetchRequestBody {
        
        return FetchRequestBody { urlRequest in
            
            var urlComponents = URLComponents()
            urlComponents.queryItems = values.map { URLQueryItem(name: $0, value: $1) }

            let allowed = CharacterSet(charactersIn: "+").inverted
            let query = urlComponents.percentEncodedQuery?.addingPercentEncoding(withAllowedCharacters: allowed)
            guard let data = query?.data(using: encoding) else {
                return urlRequest
            }
            
            var urlRequest = urlRequest
            urlRequest.httpBody = data
            
            // Set Content-Type header without overriding existing header.
            if nil == urlRequest.value(forHTTPHeaderField: "Content-Type") {
                urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
            
            return urlRequest
        }
    }
}
