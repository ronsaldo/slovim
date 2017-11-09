Extension { #name : #SLVMIntegerType }

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMIntegerType >> fromOopUsingLowcodeWith: builder [
	signed ifTrue: [
		size <= 4 ifTrue: [ ^ builder lowcodeOopToInt32 ].
		size = 8 ifTrue: [ ^ builder lowcodeOopToInt64 ].
	] ifFalse: [
		size <= 4 ifTrue: [ ^ builder lowcodeOopToUInt32 ].
		size = 8 ifTrue: [ ^ builder lowcodeOopToUInt64 ].
	].

	self error: 'Lowcode support not yet implemented.'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMIntegerType >> popTopUsingLowcodeWith: builder [
	size <= 4 ifTrue: [
		builder lowcodePopInt32
	] ifFalse: [
		self assert: size = 8.
		builder lowcodePopInt64
	].

]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMIntegerType >> pushConstant: aConstant usingLowcodeWith: builder [
	size <= 4 ifTrue: [
		aConstant = 0 ifTrue: [ ^ builder lowcodePushZero32 ].
		aConstant = 1 ifTrue: [ ^ builder lowcodePushOne32 ].
		builder lowcodePushConstantUInt32: aConstant
	] ifFalse: [
		self assert: size = 8.
		aConstant = 0 ifTrue: [ ^ builder lowcodePushZero64 ].
		aConstant = 1 ifTrue: [ ^ builder lowcodePushOne64 ].
		builder lowcodePushConstantUInt64: aConstant
	].
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMIntegerType >> pushFromMemoryUsingLowcodeWith: builder [
	signed ifTrue: [ 
		size = 1 ifTrue: [ ^ builder lowcodeLoadInt8FromMemory ].
		size = 2 ifTrue: [ ^ builder lowcodeLoadInt16FromMemory ].
		size = 4 ifTrue: [ ^ builder lowcodeLoadInt32FromMemory ].
		size = 8 ifTrue: [ ^ builder lowcodeLoadInt64FromMemory ].
	] ifFalse: [ 
		size = 1 ifTrue: [ ^ builder lowcodeLoadUInt8FromMemory ].
		size = 2 ifTrue: [ ^ builder lowcodeLoadUInt16FromMemory ].
		size = 4 ifTrue: [ ^ builder lowcodeLoadUInt32FromMemory ].
		size = 8 ifTrue: [ ^ builder lowcodeLoadUInt64FromMemory ].
	].
	self error: 'Integer type not yet supported in Lowcode'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMIntegerType >> pushLocal: location usingLowcodeWith: builder [
	signed ifTrue: [ 
		size = 1 ifTrue: [ ^ builder lowcodeLoadLocalInt8: location ].
		size = 2 ifTrue: [ ^ builder lowcodeLoadLocalInt16: location ].
		size = 4 ifTrue: [ ^ builder lowcodeLoadLocalInt32: location ].
		size = 8 ifTrue: [ ^ builder lowcodeLoadLocalInt64: location ].
	] ifFalse: [ 
		size = 1 ifTrue: [ ^ builder lowcodeLoadLocalUInt8: location ].
		size = 2 ifTrue: [ ^ builder lowcodeLoadLocalUInt16: location ].
		size = 4 ifTrue: [ ^ builder lowcodeLoadLocalUInt32: location ].
		size = 8 ifTrue: [ ^ builder lowcodeLoadLocalUInt64: location ].
	].

	self error: 'Integer type not yet supported in Lowcode'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMIntegerType >> storeAndPopStackTopIntoLocal: location usingLowcodeWith: builder [
	size = 1 ifTrue: [ ^ builder lowcodeStoreLocalInt8: location ].
	size = 2 ifTrue: [ ^ builder lowcodeStoreLocalInt16: location ].
	size = 4 ifTrue: [ ^ builder lowcodeStoreLocalInt32: location ].
	size = 8 ifTrue: [ ^ builder lowcodeStoreLocalInt64: location ].
	self error: 'Integer type not yet supported in Lowcode'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMIntegerType >> storeAndPopStackTopIntoMemoryUsingLowcodeWith: builder [
	size = 1 ifTrue: [ ^ builder lowcodeStoreInt8ToMemory ].
	size = 2 ifTrue: [ ^ builder lowcodeStoreInt16ToMemory ].
	size = 4 ifTrue: [ ^ builder lowcodeStoreInt32ToMemory ].
	size = 8 ifTrue: [ ^ builder lowcodeStoreInt64ToMemory ].
	self error: 'Integer type not yet supported in Lowcode'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMIntegerType >> toFloat: targetType usingLowcodeWith: builder [
	signed ifTrue: [
		size <= 4 ifTrue: [
			targetType size = 4 ifTrue: [ ^ builder lowcodeInt32ToFloat32 ].
			targetType size = 8 ifTrue: [ ^ builder lowcodeInt32ToFloat64 ].
		].
		size = 8 ifTrue: [
			targetType size = 4 ifTrue: [ ^ builder lowcodeInt64ToFloat32 ].
			targetType size = 8 ifTrue: [ ^ builder lowcodeInt64ToFloat64 ].
		].
	] ifFalse: [
		size <= 4 ifTrue: [
			targetType size = 4 ifTrue: [ ^ builder lowcodeUint32ToFloat32 ].
			targetType size = 8 ifTrue: [ ^ builder lowcodeUint32ToFloat64 ].
		].
		size = 8 ifTrue: [
			targetType size = 4 ifTrue: [ ^ builder lowcodeUint64ToFloat32 ].
			targetType size = 8 ifTrue: [ ^ builder lowcodeUint64ToFloat64 ].
		].
	].

	self error: 'Lowcode support not yet implemented.'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMIntegerType >> toOopUsingLowcodeWith: builder [
	signed ifTrue: [
		size <= 4 ifTrue: [ ^ builder lowcodeInt32ToOop ].
		size = 8 ifTrue: [ ^ builder lowcodeInt64ToOop ].
	] ifFalse: [
		size <= 4 ifTrue: [ ^ builder lowcodeUint32ToOop  ].
		size = 8 ifTrue: [ ^ builder lowcodeUint64ToOop ].
	].

	self error: 'Lowcode support not yet implemented.'
]
