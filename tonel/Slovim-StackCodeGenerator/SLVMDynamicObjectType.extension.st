Extension { #name : #SLVMDynamicObjectType }

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMDynamicObjectType >> popTopUsingLowcodeWith: builder [
	builder popTop
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMDynamicObjectType >> pushConstant: constant usingLowcodeWith: builder [
	builder pushLiteral: constant
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMDynamicObjectType >> pushLocal: location usingLowcodeWith: aCodeGenerator [
	^ aCodeGenerator pushTemp: location

]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMDynamicObjectType >> storeAndPopStackTopIntoLocal: location usingLowcodeWith: aCodeGenerator [
	aCodeGenerator
		storeTemp: location;
		popTop

]
