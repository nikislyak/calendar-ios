//
//  WhileSequence.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 03.09.2021.
//

import Foundation

struct WhileSequence<SubSequence: Sequence>: Sequence {
	private let sequence: SubSequence
	private let predicate: (SubSequence.Element, SubSequence.Element) -> Bool

	init(sequence: SubSequence, predicate: @escaping (SubSequence.Element, SubSequence.Element) -> Bool) {
		self.sequence = sequence
		self.predicate = predicate
	}

	struct Iterator<SubSequence: Sequence>: IteratorProtocol {
		private let sequence: SubSequence
		private let predicate: (SubSequence.Element, SubSequence.Element) -> Bool

		init(sequence: SubSequence, predicate: @escaping (SubSequence.Element, SubSequence.Element) -> Bool) {
			self.sequence = sequence
			self.predicate = predicate
		}

		private var previous: SubSequence.Element?
		private var iterator: SubSequence.Iterator?

		mutating func next() -> SubSequence.Element? {
			if previous == nil {
				var iterator = sequence.makeIterator()
				previous = iterator.next()
				self.iterator = iterator
				return previous
			} else if let previous = previous,
					  let next = iterator?.next(),
					  predicate(previous, next) {
				self.previous = next
				return next
			} else {
				return nil
			}
		}
	}

	func makeIterator() -> Iterator<SubSequence> {
		Iterator(sequence: sequence, predicate: predicate)
	}
}

extension Sequence {
	func takeWhile(predicate: @escaping (Element, Element) -> Bool) -> WhileSequence<Self> {
		WhileSequence(sequence: self, predicate: predicate)
	}
}
