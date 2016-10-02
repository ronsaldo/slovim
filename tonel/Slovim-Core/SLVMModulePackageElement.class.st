"
I represent an element in a Smalltalk package that is compiled into a native module.
"
Class {
	#name : #SLVMModulePackageElement,
	#superclass : #SLVMObject,
	#instVars : [
		'name',
		'dependencies',
		'compiledValue'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #adding }
SLVMModulePackageElement >> addDependency: dependency [
	dependencies add: dependency
]

{ #category : #accessing }
SLVMModulePackageElement >> compiledValue [
	^ compiledValue
]

{ #category : #accessing }
SLVMModulePackageElement >> compiledValue: anObject [
	compiledValue := anObject
]

{ #category : #accessing }
SLVMModulePackageElement >> dependencies [
	^ dependencies
]

{ #category : #'code generation' }
SLVMModulePackageElement >> emitFor: module registrationWithAllocaBuilder: allocaBuilder codeBuilder: codeBuilder [
]

{ #category : #initialization }
SLVMModulePackageElement >> initialize [
	super initialize.
	dependencies := Set new.
	
]

{ #category : #accessing }
SLVMModulePackageElement >> name [
	^ name
]

{ #category : #accessing }
SLVMModulePackageElement >> name: anObject [
	name := anObject
]
