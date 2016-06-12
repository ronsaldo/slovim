Extension { #name : #String }

{ #category : #'*Slovim-SpirV' }
String >> asSpirVStringLiteral [
	| utf8 wordCount wordArray shift word wordIndex |
	utf8 := self asUTF8Bytes.
	wordCount := utf8 size + 1 + 3 // 4.
	wordArray := (1 to: wordCount) collect: [:i | 0 ].
	1 to: utf8 size do: [ :i |
		shift := (i - 1 \\ 4) * 8.
		wordIndex := (i -1) // 4 + 1.
		word := wordArray at: wordIndex.
		word := word bitOr: ((utf8 at: i) bitShift: shift).
		wordArray at: wordIndex put: word.
	].
	^ wordArray
]
