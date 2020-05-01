Class {
	#name : #SLVMMessagePackCodecTest,
	#superclass : #TestCase,
	#category : #'Slovim-MessagePack-Test'
}

{ #category : #tests }
SLVMMessagePackCodecTest >> testEncodeAndDecode [
	(#(
		0 1 2 3 4 127 128 256 1024 65536 4294967296 18446744073709551615
		-1 -2 -3 -4 -127 -128 -256 -1024 -65536 -4294967296 -9223372036854775808
		1.5 3.75
		()
		(1 2)
		(1 2 3 4 5)
		
		$H
		$L
		
		''
		'H'
		'Hello World'
		#''
		#'H'
		#'Hello World'
	) , {
		(1 to: 14) asArray.
		(1 to: 128) asArray.
		(1 to: 1024) asArray.
		(1 to: 123456) asArray.
		
		(1 to: 14) asArray asString.
		(1 to: 128) asArray asString.
		(1 to: 1024) asArray asString.

		Dictionary newFrom: ((1 to: 14) collect: [:v | v -> (v*2)]).
		Dictionary newFrom: ((1 to: 128) collect: [:v | v -> (v*2)]).
		Dictionary newFrom: ((1 to: 1024) collect: [:v | v -> (v*2)]).
		Dictionary newFrom: ((1 to: 123456) collect: [:v | v -> (v*2)]).

		OrderedDictionary newFrom: ((1 to: 14) collect: [:v | v -> (v*2)]).
		OrderedDictionary newFrom: ((1 to: 128) collect: [:v | v -> (v*2)]).
		OrderedDictionary newFrom: ((1 to: 1024) collect: [:v | v -> (v*2)]).
		OrderedDictionary newFrom: ((1 to: 123456) collect: [:v | v -> (v*2)]).
	})do: [ :each |
		| encoded decoded|
		encoded := SLVMMessagePackEncoder encodeObject: each.
		decoded := SLVMMessagePackDecoder decode: encoded.
		(each class = Dictionary and: [ decoded class == OrderedDictionary ]) ifTrue: [ 
			decoded := decoded asDictionary
		].
		self assert: decoded equals: each
	]
]
