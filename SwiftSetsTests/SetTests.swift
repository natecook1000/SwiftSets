// SetTests.swift
// Copyright (c) 2014 Nate Cook, licensed under the MIT License

import UIKit
import XCTest

let vowelSet = Set("aeiou")
let alphabetSet : Set<Character> = Set(elements: "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
let emptySet = Set<Int>()

let bigSetSize = 10_000
let bigSet = Set(1...bigSetSize)

// MARK: - Tests
class SetTests : XCTestCase {
    
    func testSetBasics() {
        XCTAssert(vowelSet.isSubsetOfSet(alphabetSet) == true, "vowelSet should be a subset of alphabetSet")
        XCTAssert(vowelSet.isSupersetOfSet(alphabetSet) == false, "vowelSet should not be a superset of alphabetSet")
        XCTAssert(alphabetSet.isSupersetOfSet(vowelSet) == true, "alphabetSet should be a superset of vowelSet")
        XCTAssert(emptySet.isEmpty, "emptySet should be empty")
        XCTAssert(vowelSet.count == 5, "vowelSet should have five elements")
        XCTAssert(vowelSet.contains("b") == false, "vowelSet should not contain 'b'")
    }
    
    func testMutableSet() {
        var mutableVowelSet = vowelSet
        mutableVowelSet.add("a")
        XCTAssert(mutableVowelSet.count == 5, "adding existing member should not increase count")
        mutableVowelSet += "y"
        XCTAssert(mutableVowelSet.count == 6, "adding y should increase count")
        XCTAssert(vowelSet.count == 5, "mutating a copy of immutable vowelSet should not change vowelSet")
    }
    
    func testIntersections() {
        var mutableVowelSet = vowelSet
        mutableVowelSet += Set(elements: "å","á","â","ä","à","é","ê","è","ë","í","î","ï","ì","ø","ó","ô","ö","ò","ú","û","ü","ù","y")
        
        XCTAssert(mutableVowelSet.intersectsWithSet(alphabetSet) == true)
        XCTAssert(mutableVowelSet.isSubsetOfSet(alphabetSet) == false)
        
        var newLetterSet = alphabetSet.setByIntersectionWithSet(mutableVowelSet)
        newLetterSet.remove("y")
        XCTAssert(newLetterSet == vowelSet)
    }
    
    func testMap() {
        let bracketedLetterSet = vowelSet.map { "[\($0)]" }
        XCTAssert(bracketedLetterSet.contains("[a]") == true)
    }
    
    func testSequence() {
        var vowelCount = 0
        var vowelIndex = vowelSet.startIndex
        do {
            ++vowelCount
            vowelIndex = vowelIndex.successor()
        } while vowelIndex != vowelSet.endIndex
        XCTAssert(vowelCount == 5, "should be five vowels by index succession")
        
        vowelCount = 0
        for _ in vowelSet {
            ++vowelCount
        }
        XCTAssert(vowelCount == 5, "should be five vowels by generation")
        
        XCTAssert(emptySet.startIndex == emptySet.endIndex, "empty set is empty")
    }
    
    func testAnyElement() {
        var emptySet : Set<String> = Set<String>()
        XCTAssert(emptySet.anyElement() == nil)
        emptySet += "a"
        XCTAssert(emptySet.anyElement() == "a")
    }

    func testCreationAndLookupPerformance() {
        measureBlock {
            let size: UInt32 = 5_000
            var set = Set(elements: size)
            
            for _ in 1...size {
                set.add(arc4random_uniform(size))
            }

            var matched = 0
            for _ in 1...size {
                if set.contains(arc4random_uniform(size)) {
                    ++matched
                }
            }
        }
    }
    
    func testEqualitySame() {
        measureBlock {
            var anotherBigSet = bigSet
            
            XCTAssert(anotherBigSet == bigSet, "two big sets should be equal")
        }
    }
    
    func testEqualityDifferent() {
        measureBlock {
            var anotherBigSet = bigSet
            anotherBigSet.remove(bigSetSize)
            
            XCTAssert(anotherBigSet != bigSet, "two big sets should not be equal")
        }
    }
    
    func testEqualityDifferentSize() {
        measureBlock {
            var anotherBigSet = bigSet
            anotherBigSet.remove(bigSetSize)
            anotherBigSet.add(bigSetSize + 1)

            XCTAssert(anotherBigSet != bigSet, "two big sets should not be equal")
        }
    }
    
}

