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
    
    // MARK: Encoders
    
    public static func data(_ data: Data) -> FetchRequestBody {
        
        return FetchRequestBody { urlRequest in
            
            var urlRequest = urlRequest
            urlRequest.httpBody = data
            return urlRequest
        }
    }
    
    public static func text(_ text: String, encoding: String.Encoding = .utf8) -> FetchRequestBody {
        
        return FetchRequestBody { urlRequest in
            
            let data = text.data(using: encoding)
            
            var urlRequest = urlRequest
            urlRequest.httpBody = data
            return urlRequest
        }
    }
    
    public static func json<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) -> FetchRequestBody {
        
        return FetchRequestBody { urlRequest in
            
            let data = try encoder.encode(value)

            var urlRequest = urlRequest
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return urlRequest
        }
    }
    
    public static func json(_ value: [String: Any], encoder: JSONEncoder = JSONEncoder()) -> FetchRequestBody {
        
        return FetchRequestBody { urlRequest in
            
            let data = try JSONSerialization.data(withJSONObject: value, options: [])
            
            var urlRequest = urlRequest
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return urlRequest
        }
    }
    
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
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            return urlRequest
        }
    }
    
    public static func urlEncoded<T: Encodable>(_ value: T, encoding: String.Encoding = .utf8, encoder: JSONEncoder = JSONEncoder()) -> FetchRequestBody {
        
        return FetchRequestBody { urlRequest in
            
            let data = try encoder.encode(value)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            guard let values = json as? [String: String?] else {
                return urlRequest
            }
            
            return try urlEncoded(values, encoding: encoding).adapt(urlRequest)
        }
    }
}
