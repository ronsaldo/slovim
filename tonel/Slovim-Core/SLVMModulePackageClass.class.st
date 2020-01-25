"
I represent metadata for registering a Smalltalk class.
"
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
	
	registrationFunction := module globalValues at: #'slvm_dynrun_subclassWithSomeNames' ifAbsent: [ 
		(module functionName: #'slvm_dynrun_subclassWithSomeNames' arguments: {
			"superclassName " oopType .
			"name" oopType .
			"instanceVariableName" oopType .
			"format" oopType .
			"metaInstanceVariableName" oopType .
			"metaFormat" oopType .
			"classVariableAssociations" oopType .
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
		codeBuilder addDynamicLiteral: actualClass classPool associations.
		codeBuilder addDynamicLiteral: (actualClass sharedPools collect: [:each | each binding]).
		codeBuilder addDynamicLiteral: actualClass category.
	}.

]
