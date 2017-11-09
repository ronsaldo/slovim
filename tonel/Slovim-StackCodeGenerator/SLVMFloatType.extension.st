Extension { #name : #SLVMFloatType }

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMFloatType >> fromOopUsingLowcodeWith: builder [
	size = 4 ifTrue: [ ^ builder lowcodeOopToFloat32 ].
	size = 8 ifTrue: [ ^ builder lowcodeOopToFloat64 ].
	self error: 'Lowcode support not yet implemented.'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMFloatType >> popTopUsingLowcodeWith: builder [
	size = 4 ifTrue: [ ^ builder lowcodePopFloat32 ].
	size = 8 ifTrue: [ ^ builder lowcodePopFloat64 ].
	self error: 'Type not yer supported in Lowcode'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMFloatType >> pushConstant: aConstant usingLowcodeWith: builder [
	size = 4 ifTrue: [ 
		aConstant = 0.0 ifTrue: [ ^ builder lowcodePushZeroFloat32 ].
		aConstant = 1.0 ifTrue: [ ^ builder lowcodePushOneFloat32 ].
	].
	size = 8 ifTrue: [ 
		aConstant = 0.0 ifTrue: [ ^ builder lowcodePushZeroFloat64 ].
		aConstant = 1.0 ifTrue: [ ^ builder lowcodePushOneFloat64 ].
	].

	builder pushLiteral: aConstant.
	self fromOopUsingLowcodeWith: builder
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMFloatType >> pushFromMemoryUsingLowcodeWith: builder [
	size = 4 ifTrue: [ ^ builder lowcodeLoadFloat32FromMemory ].
	size = 8 ifTrue: [ ^ builder lowcodeLoadFloat64FromMemory ].

	self error: 'Float type not yet supported in Lowcode'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMFloatType >> pushLocal: location usingLowcodeWith: builder [
	size = 4 ifTrue: [ ^ builder lowcodeLoadLocalFloat32: location ].
	size = 8 ifTrue: [ ^ builder lowcodeLoadLocalFloat64: location ].

	self error: 'Float type not yet supported in Lowcode'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMFloatType >> storeAndPopStackTopIntoLocal: location usingLowcodeWith: builder [
	size = 4 ifTrue: [ ^ builder lowcodeStoreLocalFloat32: location ].
	size = 8 ifTrue: [ ^ builder lowcodeStoreLocalFloat64: location ].

	self error: 'Float type not yet supported in Lowcode'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMFloatType >> storeAndPopStackTopIntoMemoryUsingLowcodeWith: builder [
	size = 4 ifTrue: [ ^ builder lowcodeStoreFloat32ToMemory ].
	size = 8 ifTrue: [ ^ builder lowcodeStoreFloat64ToMemory ].

	self error: 'Float type not yet supported in Lowcode'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMFloatType >> toInteger: targetType usingLowcodeWith: builder [
	targetType isSigned ifTrue: [
		targetType size <= 4 ifTrue: [
			size = 4 ifTrue: [ ^ builder lowcodeFloat32ToInt32 ].
			size = 8 ifTrue: [ ^ builder lowcodeFloat64ToInt32 ].
		].
		targetType size = 8 ifTrue: [
			size = 4 ifTrue: [ ^ builder lowcodeFloat32ToInt64 ].
			size = 8 ifTrue: [ ^ builder lowcodeFloat64ToInt64 ].
		].
	] ifFalse: [
		targetType size <= 4 ifTrue: [
			size = 4 ifTrue: [ ^ builder lowcodeFloat32ToUInt32 ].
			size = 8 ifTrue: [ ^ builder lowcodeFloat64ToUInt32 ].
		].
		targetType size = 8 ifTrue: [
			size = 4 ifTrue: [ ^ builder lowcodeFloat32ToUInt64 ].
			size = 8 ifTrue: [ ^ builder lowcodeFloat64ToUInt64 ].
		].
	].

	self error: 'Lowcode support not yet implemented.'
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMFloatType >> toOopUsingLowcodeWith: builder [
	size = 4 ifTrue: [ ^ builder lowcodeFloat32ToOop ].
	size = 8 ifTrue: [ ^ builder lowcodeFloat64ToOop ].
	self error: 'Lowcode support not yet implemented.'
]
