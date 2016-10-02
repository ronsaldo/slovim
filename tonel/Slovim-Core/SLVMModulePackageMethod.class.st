Class {
	#name : #SLVMModulePackageMethod,
	#superclass : #SLVMModulePackageElement,
	#instVars : [
		'method',
		'className',
		'classSide'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMModulePackageMethod >> className [
	^ className
]

{ #category : #accessing }
SLVMModulePackageMethod >> className: anObject [
	className := anObject
]

{ #category : #accessing }
SLVMModulePackageMethod >> classSide [
	^ classSide
]

{ #category : #accessing }
SLVMModulePackageMethod >> classSide: anObject [
	classSide := anObject
]

{ #category : #'code generation' }
SLVMModulePackageMethod >> emitFor: module registrationWithAllocaBuilder: allocaBuilder codeBuilder: codeBuilder [
	| oopType registrationFunction |
	oopType := module compilationTarget dynamicObjectType.
	
	registrationFunction := module globalValues at: #'slvm_dynrun_registerMethodWithNames' ifAbsent: [ 
		(module functionName: #'slvm_dynrun_registerMethodWithNames' arguments: {
			"method " oopType .
			"selector " oopType .
			"className" oopType .
			"classSide" oopType .
			} returnType: oopType) makeExternal
	].

	compiledValue := codeBuilder call: registrationFunction arguments: {
		compiledValue compiledMethodMetaDataValue .
		codeBuilder addDynamicLiteral: name.
		codeBuilder addDynamicLiteral: className .
		codeBuilder addDynamicLiteral: classSide .
	}.

]
