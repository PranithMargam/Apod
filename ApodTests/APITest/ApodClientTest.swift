//
//  ApodClientTest.swift
//  ApodTests
//
//  Created by Pranith Margam on 08/04/21.
//

import XCTest

import OHHTTPStubs

@testable import Apod

extension ApodClient {
    func testFetchApodDataResponse(file: StaticString = #file, line: UInt = #line , _ resultBlock: @escaping APICompletionBlock<APOD>) {
        let exp = XCTestExpectation(description: "Received apod expectation")
        self.fetchAPODData { (result) in
            exp.fulfill()
            resultBlock(result)
        }
        let result = XCTWaiter.wait(for: [exp], timeout: 3.0)
        switch result {
        case .timedOut:
            XCTFail("Timed out error for apod response",file: file,line: line)
        default:
            break
        }
    }
}


class ApodClientTest: XCTestCase {
    var client: ApodClient!
    override func setUp() {
        super.setUp()
        client = ApodClient(session: URLSession.shared)
        HTTPStubs.onStubMissing { (request) in
            XCTFail("missing stub for \(request)")
        }
        Mocker.requestForApodData()
    }
    
    override class func tearDown() {
        super.tearDown()
        Mocker.resetAllStubs()
    }
    
    func testFetchApodResponse() {
        let exp = expectation(description: "Call Back")
        client.testFetchApodDataResponse { result in
            exp.fulfill()
            switch result {
            case .sucesss(let apod):
                print("asa",apod.title)
                XCTAssertEqual(apod.date, "2021-04-08")
            case .failure( _):
                XCTFail("Error in apod ")
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchApodResponseOnMainThread() {
        let exp = expectation(description: "Call Back")
        client.testFetchApodDataResponse { result in
            exp.fulfill()
            XCTAssertTrue(Thread.isMainThread, "must be on main thread")
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        
    }
    
    func testFetchApodError() {
        Mocker.errorRequestForApod()
        let exp = expectation(description: "Call Back")
        client.testFetchApodDataResponse { result in
            exp.fulfill()
            switch result {
            case .sucesss( _):
                XCTFail("unexpected sucesss")
            case .failure(let error):
                if case APIError.serverError(let statusCode) = error {
                    XCTAssertEqual(statusCode, 500)

                }
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testFetchApodConnectionError() {
        Mocker.connectionErrorRequestForApod()
        let exp = expectation(description: "Call Back")
        client.fetchAPODData { result in
            exp.fulfill()
            switch result {
            case .sucesss( _):
                XCTFail("unexpected sucesss")
            case .failure(let error):
                if case APIError.connectionError(let error) = error {
                    let e = error as NSError
                    XCTAssertEqual(e.code, 999)
                } else {
                    XCTFail("failed with other error")
                }
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
        
        
    }
    
    func testFetchapod() {
        let exp = expectation(description: "Call Back")
        client.fetchAPODData { result in
            exp.fulfill()
            switch result {
            case .sucesss(let apod):
                XCTAssertEqual(apod.date, "2021-04-08")
            case .failure( _):
                XCTFail("Error in apod")
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testgetLastSavedApodData() {
        UserDefaults.standard.removeObject(forKey: APOD.lastSavedApodKey)
        XCTAssertNil(APOD.lastSavedApod(), "Has to return nil if no store data")
        
    }
    
    func testLastSavedApodData() {
        let apodData = APOD(date: "2021-04-08", url: "url", title: "title", explanation: "explanation", hdurl: "hdurl")
        APOD.savelastViewedAPOD(apodData)
        let apod = APOD.lastSavedApod()
        XCTAssertEqual(apod?.title, "title")
    }
    
    func testIsinTodayDate() {
        XCTAssertTrue(ApodClient.isDateInToday(dateString: "2021-04-08"), "")
        XCTAssertFalse(ApodClient.isDateInToday(dateString: "2021-04-09"))
        XCTAssertFalse(ApodClient.isDateInToday(dateString: "2020-04-08"))
        XCTAssertFalse(ApodClient.isDateInToday(dateString: "2021-05-09"))
    }

    
}
