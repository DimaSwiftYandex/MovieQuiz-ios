//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Dmitry Dmitry on 12.11.2023.
//

import Foundation
import XCTest

@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func TestGetValueInRange() throws {
        //Given
        let array = [1,1,2,3,5]
        
        //When
        let value = array[safe: 2]
        
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        //Given
        let array = [1,1,2,3,5]
        
        //When
        let value = array[safe: 20]
        
        //Then
        XCTAssertNil(value)
    }
}
