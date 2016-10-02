Class {
	#name : #SLVMModulePackageClass,
	#superclass : #SLVMModulePackageElement,
	#instVars : [
		'actualClass'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #accessing }
SLVMModulePackageClass >> actualClass [
	^ actualClass
]

{ #category : #accessing }
SLVMModulePackageClass >> actualClass: anObject [
	actualClass := anObject
]

{ #category : #'code generation' }
SLVMModulePackageClass >> emitFor: module registrationWithAllocaBuilder: allocaBuilder codeBuilder: codeBuilder [
	| oopType registrationFunction |
	oopType := module compilationTarget dynamicObjectType.
	
	registrationFunction := module globalValues at: #'slvm_dynrun_subclassWithNames' ifAbsent: [ 
		(module functionName: #'slvm_dynrun_subclassWithNames' arguments: {
			"superclassName " oopType .
			"name" oopType .
			"instanceVariableName" oopType .
			"format" oopType .
			"metaInstanceVariableName" oopType .
			"metaFormat" oopType .
			"classVariableNames" oopType .
			"poolDictionaries" oopType .
			"category" oopType .
			} returnType: oopType) makeExternal
	].

	compiledValue := codeBuilder call: registrationFunction arguments: { 
		codeBuilder addDynamicLiteral: actualClass superclass name.
		codeBuilder addDynamicLiteral: name.
		codeBuilder addDynamicLiteral: actualClass instanceVariables.
		codeBuilder addDynamicLiteral: actualClass format.
		codeBuilder addDynamicLiteral: actualClass class instanceVariables.
		codeBuilder addDynamicLiteral: actualClass class format.
		codeBuilder addDynamicLiteral: actualClass classPool keys.
		codeBuilder addDynamicLiteral: (actualClass sharedPools collect: #name).
		codeBuilder addDynamicLiteral: actualClass category.
	}.

]
