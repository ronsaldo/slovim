Extension { #name : #AbstractFileReference }

{ #category : #'*Slovim-Core' }
AbstractFileReference >> slvmAtomicWriteStreamDo: aBlock [
	| stream |
	stream := self writeStream.
	^ [
			stream truncate.
			aBlock value: stream.
			stream close
	] on: Error do: [ :exception |
		stream close.
		self isFile ifTrue: [ self delete ].
		exception signal
	]
]
