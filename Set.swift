// Set.swift
// Copyright (c) 2014 Nate Cook, licensed under the MIT License

import Foundation

public struct Set<T: Hashable> : Equatable {
    typealias Element = T
    private var contents: [Element: Bool]

    /// Create an empty Set.
    public init() {
        self.contents = [:]
    }

    /// Create a Set from the given sequence.
    public init<S: SequenceType where S.Generator.Element == Element>(_ sequence: S) {
        self.contents = [:]
        Swift.map(sequence) { self.contents[$0] = true }
    }
    
    /// Create a Set from the given elements.
    public init(elements: Element...) {
        self.init()
        elements.map { self.contents[$0] = true }
    }

    /// Create an empty Set while reserving capacity for at least `minimumCapacity` elements.
    public init(minimumCapacity: Int) {
        self.contents = Dictionary(minimumCapacity: minimumCapacity)    
    }

    /// The number of elements in the Set.
    public var count: Int { return contents.count }

    /// Returns `true` if the Set is empty.
    public var isEmpty: Bool { return contents.isEmpty }

    /// The elements of the Set as an array.
    public var elements: [Element] { return Array(self.contents.keys) }

    /// Returns `true` if the Set contains `element`.
    public func contains(element: Element) -> Bool {
        return contents[element] ?? false
    }

    /// `true` if the Set contains `element`, `false` otherwise.
    public subscript(element: Element) -> Bool {
        return contains(element)
    }

    /// Add a single `newElement` to the Set.
    public mutating func add(newElement: Element) {
        self.contents[newElement] = true
    }
    
    /// Add multiple `newElements` to the Set.
    public mutating func add(newElement: Element, _ anotherNewElement: Element, _ otherNewElements: Element...) {
        add(newElement)
        add(anotherNewElement)
        otherNewElements.map { self.contents[$0] = true }
    }

    /// Remove `element` from the Set.
    public mutating func remove(element: Element) -> Element? {
        return contents.removeValueForKey(element) != nil ? element : nil
    }

    /// Removes all elements from the Set.
    public mutating func removeAll() {
        contents = [Element: Bool]()
    }

    /// Returns a new Set including only those elements `x` where `includeElement(x)` is true.
    public func filter(includeElement: (T) -> Bool) -> Set<T> {
        return Set(self.contents.keys.filter(includeElement))
    }

    /// Returns a new Set where each element `x` is transformed by `transform(x)`.
    public func map<U>(transform: (T) -> U) -> Set<U> {
        return Set<U>(self.contents.keys.map(transform))
    }

    /// Returns a single value by iteratively combining each element of the Set.
    public func reduce<U>(var initial: U, combine: (U, T) -> U) -> U {
        return Swift.reduce(self, initial, combine)
    }
    
    /// Returns an element from the set, likely the first.
    public func anyElement() -> Element? { return elements.first }
}

// MARK: SequenceType

extension Set : SequenceType {
    typealias Generator = GeneratorOf<T>

    /// Creates a generator for the items of the set.
    public func generate() -> Generator {
        var generator = contents.keys.generate()
        return Swift.GeneratorOf {
            return generator.next()
        }
    }
}

// MARK: ArrayLiteralConvertible

extension Set : ArrayLiteralConvertible {
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

// MARK: Set Operations

extension Set {
    /// Returns `true` if the Set has the exact same members as `set`.
    public func isEqualToSet(set: Set<T>) -> Bool {
        return self.contents == set.contents
    }

    /// Returns `true` if the Set shares any members with `set`.
    public func intersectsWithSet(set: Set<T>) -> Bool {
        for elem in self {
            if set.contains(elem) {
                return true
            }
        }
        return false
    }

    /// Returns `true` if all members of the Set are part of `set`.
    public func isSubsetOfSet(set: Set<T>) -> Bool {
        for elem in self {
            if !set.contains(elem) {
                return false
            }
        }
        return true
    }

    /// Returns `true` if all members of `set` are part of the Set.
    public func isSupersetOfSet(set: Set<T>) -> Bool {
        return set.isSubsetOfSet(self)
    }

    /// Modifies the Set to add all members of `set`.
    public mutating func unionSet(set: Set<T>) {
        for elem in set {
            self.add(elem)
        }
    }

    /// Modifies the Set to remove any members also in `set`.
    public mutating func subtractSet(set: Set<T>) {
        for elem in set {
            self.remove(elem)
        }
    }

    /// Modifies the Set to include only members that are also in `set`.
    public mutating func intersectSet(set: Set<T>) {
        self = self.filter { set.contains($0) }
    }

    /// Returns a new Set that contains all the elements of both this set and the set passed in.
    public func setByUnionWithSet(var set: Set<T>) -> Set<T> {
        set.extend(self)
        return set
    }

    /// Returns a new Set that contains only the elements in both this set and the set passed in.
    public func setByIntersectionWithSet(var set: Set<T>) -> Set<T> {
        set.intersectSet(self)
        return set
    }

    /// Returns a new Set that contains only the elements in this set *not* also in the set passed in.
    public func setBySubtractingSet(set: Set<T>) -> Set<T> {
        var newSet = self
        newSet.subtractSet(set)
        return newSet
    }
}

// MARK: ExtensibleCollectionType

extension Set : ExtensibleCollectionType {
    typealias Index = SetIndex<T>
    public var startIndex: Index { return SetIndex(contents.startIndex) }
    public var endIndex: Index { return SetIndex(contents.endIndex) }

    /// Returns the element of the Set at the specified index.
    public subscript(i: Index) -> Element {
        return contents.keys[i.index]
    }

    public mutating func reserveCapacity(n: Int) {
        // can't really do anything with this
    }

    /// Adds newElement to the Set.
    public mutating func append(newElement: Element) {
        self.add(newElement)
    }

    /// Extends the Set by adding all the elements of `seq`.
    public mutating func extend<S : SequenceType where S.Generator.Element == Element>(seq: S) {
        Swift.map(seq) { self.contents[$0] = true }
    }
}

// MARK: Printable

extension Set : Printable, DebugPrintable {
    public var description: String {
        return "Set(\(self.elements))"
    }

    public var debugDescription: String {
        return description
    }
}

// MARK: Operators

public func +=<T>(inout lhs: Set<T>, rhs: T) {
    lhs.add(rhs)
}

public func +=<T>(inout lhs: Set<T>, rhs: Set<T>) {
    lhs.unionSet(rhs)
}

public func +<T>(lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    return lhs.setByUnionWithSet(rhs)
}

public func ==<T>(lhs: Set<T>, rhs: Set<T>) -> Bool {
    return lhs.isEqualToSet(rhs)
}

// MARK: - SetIndex

public struct SetIndex<T: Hashable> : BidirectionalIndexType {
    private var index: DictionaryIndex<T, Bool>
    private init(_ dictionaryIndex: DictionaryIndex<T, Bool>) {
        self.index = dictionaryIndex
    }
    public func predecessor() -> SetIndex<T> {
        return SetIndex(self.index.predecessor())
    }
    public func successor() -> SetIndex<T> {
        return SetIndex(self.index.successor())
    }
}

public func ==<T: Hashable>(lhs: SetIndex<T>, rhs: SetIndex<T>) -> Bool {
    return lhs.index == rhs.index
}
