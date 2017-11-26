Class {
	#name : #SLVMStackCodeGenerator,
	#superclass : #SLVMCodeGenerator,
	#instVars : [
		'target',
		'translatedElements',
		'etreeModule',
		'finalCodeGenerator'
	],
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #accessing }
SLVMStackCodeGenerator >> etreeModule [
	^ etreeModule ifNil: [ etreeModule := SLVMETreeModule new compilationTarget: target ].

]

{ #category : #'code generation' }
SLVMStackCodeGenerator >> finalCodeGenerator [
	^ finalCodeGenerator ifNil: [finalCodeGenerator :=
		target finalTargetCodeGeneratorClass new
			compilationTarget: target]
]

{ #category : #'as yet unclassified' }
SLVMStackCodeGenerator >> isInliningMandatory [
	^ false
]

{ #category : #testing }
SLVMStackCodeGenerator >> needSSADestroyed [
	^ true
]

{ #category : #testing }
SLVMStackCodeGenerator >> needStructuredControlFlow [
	^ false
]

{ #category : #accessing }
SLVMStackCodeGenerator >> target [
	^ target
]

{ #category : #accessing }
SLVMStackCodeGenerator >> target: anObject [
	target := anObject
]

{ #category : #'code generation' }
SLVMStackCodeGenerator >> translateFinalModuleElement: element [
	| intermediate |
	element isFunction ifTrue: [ self applyPassesInFunction: element ].
	intermediate := self translateModuleElement: element.
	^ self finalCodeGenerator translateElement: intermediate

]

{ #category : #'code generation' }
SLVMStackCodeGenerator >> translateModule: module exportList: exportList [
	self applyPassesIn: module functionList: (exportList select: #isFunction).
	
	exportList do: [ :element |
		self translateModuleElement: element
	].
	^ self etreeModule
]

{ #category : #'code generation' }
SLVMStackCodeGenerator >> translateModuleElement: element [
	^ element accept: self
]

{ #category : #accessing }
SLVMStackCodeGenerator >> translatedElements [
	^ translatedElements ifNil: [ translatedElements := Dictionary new ]
]

{ #category : #visiting }
SLVMStackCodeGenerator >> visitFunction: aFunction [
	| expressionTreeFunction literals |
	self translatedElements at: aFunction ifPresent: [ :incomplete | ^ incomplete ].

	expressionTreeFunction := SLVMETreeFunction new.
	expressionTreeFunction name: aFunction name.
	expressionTreeFunction debugSourceLocation: aFunction debugSourceLocation.
	
	self etreeModule add: expressionTreeFunction.
	translatedElements at: aFunction put: expressionTreeFunction.
	
	SLVMStackFunctionCodeGenerator new
		moduleCodeGenerator: self;
		translateFunction: aFunction into: expressionTreeFunction.
		
	aFunction hasSelectorAndClassBinding ifTrue: [
		literals := aFunction dynamicLiterals.
		expressionTreeFunction
			classBinding: literals last value;
			selector: ((literals at: literals size - 1) value).
	].

	^ expressionTreeFunction
		
]

{ #category : #visiting }
SLVMStackCodeGenerator >> visitGlobalVariable: aGlobalVariable [
	| etreeGlobal |
	self translatedElements at: aGlobalVariable ifPresent: [ :incomplete | ^ incomplete ].
	
	etreeGlobal := SLVMETreeGlobalVariable new.
	etreeGlobal name: aGlobalVariable name;
		valueType: aGlobalVariable valueType;
		type: aGlobalVariable type.
	etreeGlobal debugSourceLocation: aGlobalVariable debugSourceLocation.
	etreeGlobal binding: (aGlobalVariable propertyAt: #binding ifAbsent: [ nil ]).
	
	self etreeModule add: etreeGlobal.
	translatedElements at: aGlobalVariable put: etreeGlobal.
	
	self flag: 'TODO: Translate the initial value.'.
	^ etreeGlobal.
		
]
