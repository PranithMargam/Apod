//
//  ApodClient.swift
//  Apod
//
//  Created by Pranith Margam on 08/04/21.
//

import Foundation

import Foundation


enum APIResult<T: Decodable> {
    case sucesss(T)
    case failure(APIError)
}

enum APIError: Error {
    case connectionError(Error)
    case responseFormateInvalid(String)
    case serverError(Int)
}

typealias APICompletionBlock<T: Decodable> = (APIResult<T>) -> Void

class ApodClient {
    let session: URLSession
    init(session: URLSession) {
        self.session = session
    }
    
    func fetchAPODData(complition:@escaping APICompletionBlock<APOD>) {
        let apiURLString =  "https://api.nasa.gov/planetary/apod"
        let apiKey = "QSeLng6T8u2WjVCcRIGUC9TJe8ctKpqsPl6Hq4rH"
        let urlString = apiURLString + "?api_key=" + apiKey
        let url = URL(string: urlString)!
        let req = URLRequest(url: url)
        
        let task = session.dataTask(with: req) { (data, response, error) in
            if let e = error {
                self.resultOnMainThread(result: APIResult.failure(.connectionError(e)), completion: complition)
            } else if let http = response as? HTTPURLResponse {
                switch http.statusCode {
                case 200:
                    //sucess
                    let jsonDecoder = JSONDecoder()
                    do {
                        let apod = try jsonDecoder.decode(APOD.self, from: data!)
                        self.resultOnMainThread(result: APIResult.sucesss(apod), completion: complition)
                        APOD.savelastViewedAPOD(apod)
                    } catch let err {
                        print(err)
                        let bodyString = String(data: data!, encoding: .utf8)
                        self.resultOnMainThread(result: APIResult.failure(.responseFormateInvalid(bodyString ?? "nobody found")), completion: complition)
                    }
                default:
                    self.resultOnMainThread(result: APIResult.failure(.serverError(http.statusCode)), completion: complition)
                }
            }
        }
        task.resume()
    }
    
    func resultOnMainThread<T>(result: APIResult<T>, completion: @escaping APICompletionBlock<T>) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
    static func isDateInToday(dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString),Calendar.current.isDateInToday(date) {
            return true
        }
        return false
    }
    
}
