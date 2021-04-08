//
//  Mocker.swift
//  Apod
//
//  Created by Pranith Margam on 08/04/21.
//

import Foundation
import OHHTTPStubs
import OHHTTPStubsSwift

class Mocker {
    class func resetAllStubs() {
        HTTPStubs.removeAllStubs()
    }
    
    static func requestForApodData() {
        stub(condition: isHost("api.nasa.gov")) { (request) -> HTTPStubsResponse in
            return jsonMocker(with: "apod.json")
        }
    }

    static private func jsonMocker(with fileName: String) -> HTTPStubsResponse {
        let bundle = OHResourceBundle("Mocks", Mocker.self)!
        let path = OHPathForFileInBundle(fileName, bundle)!
        return HTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: nil)
        
    }
    
    static func errorRequestForApod() {
        stub(condition: isHost("api.nasa.gov")) { (request) -> HTTPStubsResponse in
            let data = "no data".data(using: .utf8)!
            return HTTPStubsResponse(data: data, statusCode: 500, headers: [:])
        }
    }
    
    static func connectionErrorRequestForApod() {
        stub(condition: isHost("api.nasa.gov")) { (request) -> HTTPStubsResponse in
            let data = "no data".data(using: .utf8)!
            let error = NSError(domain: "No connection", code: 999, userInfo: [:])
            return HTTPStubsResponse(error: error)
        }
    }
}
