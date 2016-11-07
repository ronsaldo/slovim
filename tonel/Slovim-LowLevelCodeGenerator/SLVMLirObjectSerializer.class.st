Class {
	#name : #SLVMLirObjectSerializer,
	#superclass : #Object,
	#instVars : [
		'dictionary',
		'relocationList',
		'stream',
		'pointerSize'
	],
	#classVars : [
		'KernelClassMapping',
		'SpecialObjectSymbols'
	],
	#category : #'Slovim-LowLevelCodeGenerator-Image'
}

{ #category : #'class initialization' }
SLVMLirObjectSerializer class >> initialize [
	super initialize.
	
	self initializeKernelClassMapping.
	
	SpecialObjectSymbols := IdentityDictionary newFromPairs: #(
		nil slvm_nil
		true slvm_true
		false slvm_false
	).
]

{ #category : #'class initialization' }
SLVMLirObjectSerializer class >> initializeKernelClassMapping [
	KernelClassMapping := IdentityDictionary new.
	#(
		" Immediate class indices "
		SmallInteger 1
		Character 2
		SmallFloat64 4

		" Compact class indices "
		LargeNegativeInteger 32
		LargePositiveInteger 33
		Float 34
		Message 35
		MethodContext 36
		BlockClosure 37

		Semaphore 48
		Mutex 49
		ByteArray 50
		Array 51
		String 52
		Bitmap 53
		Point 54

		" Squeak FFI classes "
		ExternalAddress 128
		ExternalData 129
		ExternalFunction 130
		ExternalLibrary 131
		ExternalStructure 132
		Alien 133
		UnsafeAlien 134

		" Extra classes for bootstraping "
		ProtoObject 150
		Object 151
		Behavior 152
		ClassDescription 153
		Class 154
		Metaclass 155

		UndefinedObject 156
		Boolean 157
		True 158
		False 159

		Collection 160
		HashedCollection 161
		Dictionary 162
		IdentityDictionary 163
		MethodDictionary 164
		SequenceableCollection 165
		ArrayedCollection 166
		FloatArray 167
		IntegerArray 168
		WordArray 169
		ByteString 170
		WideString 171
		Symbol 172
		ByteSymbol 173
		WideSymbol 174
		OrderedCollection 175

		Magnitude 176
		Number 177
		Fraction 178
		Integer 179
		LargeInteger 180
		LookupKey 181
		Association 182
		BoxedFloat64 183

		ExternalObject 184

		Set 185
		IdentitySet 186
		WeakSet 187
		WeakArray 188

		SystemDictionary 189
		SLVMLirCompiledMethod 190
		
		LiteralVariable 192
		ClassVariable 193
		GlobalVariable 194
		WorkspaceVariable 195
	) pairsDo: [ :className :index |
		Smalltalk globals at: className ifPresent: [ :class |
			KernelClassMapping at: class put: index
		]
	]
]

{ #category : #adding }
SLVMLirObjectSerializer >> addAlignmentPadding [
	| targetSize |
	targetSize := stream size alignedTo: 16.
	stream position: stream size.
	[ stream size < targetSize ] whileTrue: [ stream nextPut: 0 ].
]

{ #category : #adding }
SLVMLirObjectSerializer >> addInnerObject: anObject [
	| oldPosition pointer |
	oldPosition := stream position.
	pointer := self addObject: anObject.
	stream position: oldPosition.
	self recordRelocationFor: anObject to: pointer.
	
]

{ #category : #adding }
SLVMLirObjectSerializer >> addObject: anObject [
	| startPosition elementCount class elementSize bodySize slotCount actualBodySize bodyPosition header format extraBits headerPosition slotsToStore |
	(self isImmediate: anObject) ifTrue: [
		^ self encodeImmediate: anObject
	].
	(self isSpecialObject: anObject) ifTrue: [
		^ self encodeSpecialObject: anObject
	].
	anObject isLirInstructionOperand ifTrue: [ 
		anObject isModuleElement ifTrue: [ 
			^ 1
		].
	
		self halt.
	].

	dictionary at: anObject ifPresent: [ :pointer | ^ pointer ].

	"Align the objects to 16 bytes boundaries."
	stream position: stream size.
	startPosition := stream size alignedTo: 16.
	[ stream size < startPosition ] whileTrue: [ stream nextPut: 0 ].

	elementCount := self objectElementCount: anObject.
	
	"Compute the size of the body"
	class := anObject class.
	elementSize := self objectElementSizeFor: class instSpec.
	bodySize := elementCount * elementSize.
	actualBodySize := bodySize alignedTo: pointerSize.
	slotCount := actualBodySize // pointerSize.
	
	"Write the object header"	
	slotCount >= 255 ifTrue: [
		self
			writeInt64: 1;
			writeInt64: 0;
			writeInt64: slotCount.
	] ifFalse: [ 
		self writeInt64: 0.
	].

	"Record the actual object position."
	headerPosition := stream position.
	dictionary at: anObject put: headerPosition.

	"Start writing the header"
	format := class instSpec.
	extraBits := (pointerSize - (elementCount % pointerSize)) % pointerSize.
	format := format + extraBits.
	
	header := self classIndexFor: class.
	header := header | (format << 24).
	header := header | (anObject identityHash << 32 bitAnd: 4194303).
	header := header | ((slotCount min: 255) << 56).
	self writeInt64: header.

	class isPointers ifTrue: [
		bodyPosition := stream position.
		1 to: bodySize do: [ :i |
			stream nextPut: 0
		].
	
		stream position: bodyPosition.
		slotsToStore := elementCount.
		(anObject isKindOf: LiteralVariable) ifTrue: [
			slotsToStore := 1. "Do not store recursively the value of the variables."
		].
		
		1 to: slotsToStore do: [ :slot |
			self addInnerObject: (anObject instVarAt: slot)
		].
	
		slotsToStore + 1 to: elementCount do: [ :slot |
			self addInnerObject: nil
		].
	] ifFalse: [
		elementSize = 8 ifTrue: [
			self halt
		].
		elementSize = 4 ifTrue: [
			self halt
		].
		elementSize = 2 ifTrue: [
			self halt
		].
		elementSize = 1 ifTrue: [
			1 to: bodySize do: [ :i |
				stream nextPut: (anObject byteAt: i)
			].
		
			bodySize + 1 to: actualBodySize do: [ :i |
				stream nextPut: 0
			]
		].
	].

	^ headerPosition
]

{ #category : #converting }
SLVMLirObjectSerializer >> asBlobWithModuleMapping: moduleMaping [
	^ SLVMLirBlob new
		content: self contents;
		relocations: (self blobRelocationsWithModuleMapping: moduleMaping);
		yourself
]

{ #category : #converting }
SLVMLirObjectSerializer >> blobRelocationsWithModuleMapping: moduleMaping [
	| result extraSymbols symbol |
	extraSymbols := IdentityDictionary new.
	result := OrderedCollection new.
	self flag: 'Convert this to double dispatch.'.
	relocationList do: [ :reloc |
		reloc isInternalRelocation ifTrue: [
			result add: (SLVMLirMachineCodeRelocation new
				absoluteOffsetOfSize: pointerSize;
				offset: reloc offset;
				addend: reloc addend;
				yourself)
		].
		reloc isModuleElementRelocation  ifTrue: [
			result add: (SLVMLirMachineCodeRelocation new
				absoluteOffsetOfSize: pointerSize;
				offset: reloc offset;
				addend: reloc addend;
				symbol: (moduleMaping at: reloc element);
				yourself)
		].
		reloc isSpecialObjectRelocation ifTrue: [ 
			symbol := extraSymbols at: reloc specialObject ifAbsentPut: [ 
				SLVMLirMachineCodeSymbol new
					name: (SpecialObjectSymbols at: reloc specialObject);
					usedForReloc: true;
					public;
					yourself
			].
			result add: (SLVMLirMachineCodeRelocation new
				absoluteOffsetOfSize: pointerSize;
				offset: reloc offset;
				addend: reloc addend;
				symbol: symbol;
				yourself)
		]
	].

	^ result

]

{ #category : #adding }
SLVMLirObjectSerializer >> classIndexFor: aClass [
	^ KernelClassMapping at: aClass
]

{ #category : #accessing }
SLVMLirObjectSerializer >> contents [
	self addAlignmentPadding.
	^ stream contents
]

{ #category : #adding }
SLVMLirObjectSerializer >> encodeImmediate32: anObject [
	anObject isInteger ifTrue: [
		^ anObject << 1 | 1
	].

	self halt
]

{ #category : #adding }
SLVMLirObjectSerializer >> encodeImmediate64: anObject [
	anObject isInteger ifTrue: [ ^ anObject << 3 | 1].
	self halt
]

{ #category : #adding }
SLVMLirObjectSerializer >> encodeImmediate: anObject [
	pointerSize = 4 ifTrue: [
		^ self encodeImmediate32: anObject
	] ifFalse: [
		^ self encodeImmediate64: anObject
	]
]

{ #category : #adding }
SLVMLirObjectSerializer >> encodeSpecialObject: anObject [
	^ 0
]

{ #category : #initialization }
SLVMLirObjectSerializer >> initialize [
	super initialize.
	stream := ReadWriteStream on: (ByteArray new: 100).
	stream binary.
	dictionary := IdentityDictionary new.
	relocationList := OrderedCollection new.
]

{ #category : #testing }
SLVMLirObjectSerializer >> isDynamicObjectSection [
	^ true
]

{ #category : #adding }
SLVMLirObjectSerializer >> isImmediate: anObject [
	anObject isInteger ifTrue: [ ^ true ].
	anObject isCharacter ifTrue: [ ^ true ].
	^ false
]

{ #category : #adding }
SLVMLirObjectSerializer >> isSpecialObject: anObject [
	^ #(nil true false) includes: anObject
]

{ #category : #adding }
SLVMLirObjectSerializer >> objectElementCount: anObject [
	anObject class isPointers ifTrue: [ 
		^ anObject class instVarNames size + (anObject class isVariable ifTrue: [ anObject size ] ifFalse: [ 0 ])
	] ifFalse: [
		^ anObject size
	]
]

{ #category : #adding }
SLVMLirObjectSerializer >> objectElementSizeFor: format [
	format < 6 ifTrue: [ ^ pointerSize ].
	format < 10 ifTrue: [ ^ 8 ].
	format < 12 ifTrue: [ ^ 4 ].
	format < 16 ifTrue: [ ^ 2 ].
	^ 1
]

{ #category : #accessing }
SLVMLirObjectSerializer >> pointerSize [
	^ pointerSize
]

{ #category : #accessing }
SLVMLirObjectSerializer >> pointerSize: anObject [
	pointerSize := anObject
]

{ #category : #adding }
SLVMLirObjectSerializer >> recordRelocationFor: anObject to: pointer [
	| offset |
	(self isImmediate: anObject) ifTrue: [ ^ self writePointer: pointer ].
	
	offset := stream position.
	(self isSpecialObject: anObject) ifTrue: [ 
		relocationList add: (SLVMLirObjectSpecialRelocation new
			offset: offset;
			addend: pointer;
			specialObject: anObject;
			yourself
		).
		
		^ self writePointer: pointer
	].

	anObject isLirInstructionOperand ifTrue: [ 
		anObject isModuleElement ifTrue: [
			relocationList add: (SLVMLirObjectModuleElementRelocation new
				offset: offset;
				addend: pointer;
				element: anObject;
				yourself
			).
			
			^ self writePointer: pointer
		].
	
		self halt.
	].

	relocationList add: (SLVMLirObjectInternalRelocation new
		offset: offset;
		addend: pointer;
		yourself
	).
	^ self writePointer: pointer
]

{ #category : #adding }
SLVMLirObjectSerializer >> writeInt16: value [
	stream nextPut: (value bitAnd: 16rff).
	stream nextPut: ((value >> 8) bitAnd: 16rff).
]

{ #category : #adding }
SLVMLirObjectSerializer >> writeInt32: value [
	stream nextPut: (value bitAnd: 16rff).
	stream nextPut: ((value >> 8) bitAnd: 16rff).
	stream nextPut: ((value >> 16) bitAnd: 16rff).
	stream nextPut: ((value >> 24) bitAnd: 16rff).
]

{ #category : #adding }
SLVMLirObjectSerializer >> writeInt64: value [
	stream nextPut: (value bitAnd: 16rff).
	stream nextPut: ((value >> 8) bitAnd: 16rff).
	stream nextPut: ((value >> 16) bitAnd: 16rff).
	stream nextPut: ((value >> 24) bitAnd: 16rff).
	
	stream nextPut: ((value >> 32) bitAnd: 16rff).
	stream nextPut: ((value >> 40) bitAnd: 16rff).
	stream nextPut: ((value >> 48) bitAnd: 16rff).
	stream nextPut: ((value >> 56) bitAnd: 16rff).
]

{ #category : #adding }
SLVMLirObjectSerializer >> writePointer: pointer [
	pointerSize = 4 ifTrue: [
		self writeInt32: pointer
	] ifFalse: [
		self writeInt64: pointer
	].
]
