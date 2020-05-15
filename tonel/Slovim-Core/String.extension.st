Extension { #name : #String }

{ #category : #'*Slovim-Core' }
String >> encodeGraphForMessagePackWith: encoder [
	^ self
]

{ #category : #'*Slovim-Core' }
String >> slvmEncodeAsSExpression [
	^ self
]

{ #category : #'*Slovim-Core' }
String >> slvmUTF16Encoded [
	^ Array streamContents: [ :out |
		self do: [ :each |
			| codePoint highBits lowBits |
			codePoint := each asInteger.
			codePoint <= 16rffff ifTrue: [ 
				out nextPut: codePoint
			] ifFalse: [
				"https://en.wikipedia.org/wiki/UTF-16"
				codePoint := codePoint - 16r10000.
				highBits := (codePoint >> 10) & 16r3FF.
				out nextPut: 16rD800 + highBits.

				lowBits := codePoint & 16r3FF.
				out nextPut: 16rDC00 + lowBits.
			]
		]
	]
]

{ #category : #'*Slovim-Core' }
String >> slvmUTF16EncodedSize [
	^ self slvmUTF16Encoded size
]

{ #category : #'*Slovim-Core' }
String >> slvmUTF32Encoded [
	^ self asWideString asArray collect: [ :each | each asInteger ]
]

{ #category : #'*Slovim-Core' }
String >> slvmUTF32EncodedSize [
	^ self slvmUTF32Encoded size
]

{ #category : #'*Slovim-Core' }
String >> slvmUTF8Encoded [
	^ self utf8Encoded
]

{ #category : #'*Slovim-Core' }
String >> slvmUTF8EncodedSize [
	^ self utf8Encoded size
]
