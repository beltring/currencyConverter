//
//  NetworkService.swift
//  CurrencyConverter
//
//  Created by Pavel Boltromyuk on 2.11.23.
//

import Foundation

class NetworkService {
    
    private var task: URLSessionDataTask?
    private var successCodes: CountableRange<Int> = 200..<299
    private var failureCodes: CountableRange<Int> = 400..<499
    
    enum Method: String {
        case get, post
    }
    
    enum QueryType {
        case path
    }
    
    func makeRequest(for url: URL, method: Method, query type: QueryType,
                     params: [String: String]? = nil,
                     headers: [String: String]? = nil,
                     completion: ((_ data: Data?, _ error: NSError?) -> Void)? = nil) {
        
        
        var mutableRequest = makeQuery(for: url, params: params, type: type)
        
        mutableRequest.allHTTPHeaderFields = headers
        mutableRequest.httpMethod = method.rawValue
        
        let session = URLSession.shared
        
        task = session.dataTask(with: mutableRequest as URLRequest, completionHandler: { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion?(data, error as? NSError)
                return
            }
            
            if let error = error {
                completion?(data, error as NSError)
                return
            }
            
            if self.successCodes.contains(httpResponse.statusCode) {
                completion?(data, nil)
            } else if self.failureCodes.contains(httpResponse.statusCode) {
                completion?(data, error as NSError?)
            } else {
                let info = [
                    NSLocalizedDescriptionKey: "Request failed with code \(httpResponse.statusCode)",
                    NSLocalizedFailureReasonErrorKey: "Wrong handling logic, wrong endpoing mapping or backend bug."
                ]
                let error = NSError(domain: "NetworkService", code: 0, userInfo: info)
                completion?(data, error)
            }
        })
        
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
    }
    
    
    //MARK: Private
    private func makeQuery(for url: URL, params: [String: String]?, type: QueryType) -> URLRequest {
        var queryItems = [URLQueryItem]()
        
        params?.forEach { key, value in
            queryItems.append(.init(name: key, value: value))
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = queryItems
        
        return URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
    }
}
