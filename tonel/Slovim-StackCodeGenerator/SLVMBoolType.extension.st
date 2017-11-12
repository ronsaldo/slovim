Extension { #name : #SLVMBoolType }

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMBoolType >> fromOopUsingLowcodeWith: builder [
	self assert: size = 1.
	^ builder lowcodeOopToBoolean32
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMBoolType >> pushFromMemoryUsingLowcodeWith: builder [
	self assert: size = 1.
	builder lowcodeLoadInt8FromMemory.
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMBoolType >> pushLocal: location usingLowcodeWith: aCodeGenerator [
	self assert: size = 1.
	aCodeGenerator lowcodeLoadLocalInt8: location
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMBoolType >> storeAndPopStackTopIntoLocal: location usingLowcodeWith: aCodeGenerator [
	self assert: size = 1.
	aCodeGenerator lowcodeStoreLocalInt8: location
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMBoolType >> storeAndPopStackTopIntoMemoryUsingLowcodeWith: builder [
	self assert: size = 1.
	builder lowcodeStoreInt8ToMemory.
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMBoolType >> toOopUsingLowcodeWith: builder [
	self assert: size = 1.
	builder lowcodeBoolean32ToOop
]
