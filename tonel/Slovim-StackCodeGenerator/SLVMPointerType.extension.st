Extension { #name : #SLVMPointerType }

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMPointerType >> pushFromMemoryUsingLowcodeWith: builder [
	builder lowcodeLoadPointerFromMemory
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMPointerType >> pushLocal: location usingLowcodeWith: aCodeGenerator [
	aCodeGenerator lowcodeLoadLocalPointer: location
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMPointerType >> storeAndPopStackTopIntoLocal: location usingLowcodeWith: aCodeGenerator [
	aCodeGenerator lowcodeStoreLocalPointer: location
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMPointerType >> storeAndPopStackTopIntoMemoryUsingLowcodeWith: builder [
	builder lowcodeStorePointerToMemory
]
