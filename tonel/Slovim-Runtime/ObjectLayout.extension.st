Extension { #name : #ObjectLayout }

{ #category : #'*Slovim-Runtime' }
ObjectLayout >> extendSLVMPackedStructure: aScope [
	self hasFields ifTrue: [
		IncompatibleLayoutConflict new
			layout: self;
			subType: #packedStructure;
			signal ].
	^ SLVMPackedStructureLayout new slotScope: aScope
]

{ #category : #'*Slovim-Runtime' }
ObjectLayout >> extendSLVMStructure: aScope [
	self hasFields ifTrue: [
		IncompatibleLayoutConflict new
			layout: self;
			subType: #structure;
			signal ].
	^ SLVMStructureLayout new slotScope: aScope
]

{ #category : #'*Slovim-Runtime' }
ObjectLayout >> extendSLVMUnion: aScope [
	self hasFields ifTrue: [
		IncompatibleLayoutConflict new
			layout: self;
			subType: #union;
			signal ].
	^ SLVMUnionLayout new slotScope: aScope
]
