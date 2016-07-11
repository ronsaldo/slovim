Class {
	#name : #SLVMConstantBuiltInFunction,
	#superclass : #SLVMConstant,
	#instVars : [
		'functionType',
		'type',
		'name',
		'isPureFunction'
	],
	#classVars : [
		'ValidBuiltInFunctionNames'
	],
	#category : #'Slovim-Core-SSA'
}

{ #category : #'class initialization' }
SLVMConstantBuiltInFunction class >> initialize [
	"
	self initialize
	"
	super initialize.
	ValidBuiltInFunctionNames := Set newFrom: #(
		"Vector functions"
		cross
		dot
		length
		normalize
		reflect
		refract
		
		"Math functions"
		smoothstep
		step
		
		"Common functions"
		umin
		smin
		fmin
		
		pow atan2
		
		asin sin asinh sinh
		acos cos acosh cosh
		atan tan atanh
		exp exp2 log log2
		sqrt inverseSqrt
		floor ceil trunc round roundEven fract
		degrees radians 
		fabs
		fsign
			
		umax
		smax
		fmax
		
		fmix
		
		"Matrix functions"
		transpose
	).
]

{ #category : #construction }
SLVMConstantBuiltInFunction class >> name: aName functionType: aFunctionType [
	^ self new name: aName functionType: aFunctionType
]

{ #category : #'as yet unclassified' }
SLVMConstantBuiltInFunction >> accept: aVisitor [
	^ aVisitor visitConstantBuiltInFunction: self
]

{ #category : #accessing }
SLVMConstantBuiltInFunction >> functionType [
	^ functionType
]

{ #category : #'as yet unclassified' }
SLVMConstantBuiltInFunction >> initialize [
	super initialize.
	isPureFunction := true.
]

{ #category : #testing }
SLVMConstantBuiltInFunction >> isConstantBuiltInFunction [
	^ true
]

{ #category : #accessing }
SLVMConstantBuiltInFunction >> isPureFunction [
	^ isPureFunction
]

{ #category : #accessing }
SLVMConstantBuiltInFunction >> isPureFunction: anObject [
	isPureFunction := anObject
]

{ #category : #accessing }
SLVMConstantBuiltInFunction >> name [
	^ name
]

{ #category : #construction }
SLVMConstantBuiltInFunction >> name: aName functionType: aFunctionType [
	self assert: (ValidBuiltInFunctionNames includes: aName).
	self assert: aFunctionType isSlovimType.
	name := aName.
	functionType := aFunctionType.
	type := SLVMReferenceType baseType: functionType storage: SLVMType genericStorage.
	
]

{ #category : #'as yet unclassified' }
SLVMConstantBuiltInFunction >> printOn: aStream [
	aStream nextPutAll: 'builtin '; print: name; space; print: functionType
]

{ #category : #accessing }
SLVMConstantBuiltInFunction >> type [
	^ type
]

{ #category : #accessing }
SLVMConstantBuiltInFunction >> type: anObject [
	type := anObject
]
