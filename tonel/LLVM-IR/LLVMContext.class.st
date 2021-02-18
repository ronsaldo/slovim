Class {
	#name : #LLVMContext,
	#superclass : #LLVMObject,
	#instVars : [
		'types',
		'labelTy',
		'voidTy',
		'metadataTy',
		'floatTy',
		'doubleTy',
		'int1Ty',
		'int8Ty',
		'int16Ty',
		'int32Ty',
		'int64Ty',
		'int128Ty',
		'halfTy',
		'enumAttributeHandles'
	],
	#category : #'LLVM-IR'
}

{ #category : #accessing }
LLVMContext >> buildHandle [
	handle := LLVMContextRef create.
	
	labelTy setHandle: handle labelType.
	voidTy setHandle: handle voidType.
	metadataTy setHandle: handle metadataType.
	
	halfTy setHandle: handle halfType.
	floatTy setHandle: handle floatType.
	doubleTy setHandle: handle doubleType.

	int1Ty setHandle: handle int1Type.
	int8Ty setHandle: handle int8Type.
	int16Ty setHandle: handle int16Type.
	int32Ty setHandle: handle int32Type.
	int64Ty setHandle: handle int64Type.
	int128Ty setHandle: handle int128Type.
]

{ #category : #accessing }
LLVMContext >> doubleTy [
	^ doubleTy
]

{ #category : #accessing }
LLVMContext >> floatTy [
	^ floatTy
]

{ #category : #'as yet unclassified' }
LLVMContext >> getOrCreateEnumAttributeHandleFor: attributeName [
	^ enumAttributeHandles at: attributeName ifAbsentPut: [ 
		self validHandle createEnumAttribute: (LLVMC uniqueInstance getAttributeKindForName: attributeName) value: 0
	]
]

{ #category : #accessing }
LLVMContext >> halfTy [
	^ halfTy
]

{ #category : #initialization }
LLVMContext >> initialize [
	super initialize.
	types := Dictionary new.
	
	labelTy := LLVMLabelType new context: self.
	voidTy := LLVMVoidType new context: self.
	metadataTy := LLVMMetadataType new context: self.
	
	halfTy := LLVMFloatingPointType new name: #half; context: self; bits: 16.
	floatTy := LLVMFloatingPointType new name: #float; context: self; bits: 32.
	doubleTy := LLVMFloatingPointType new name: #double; context: self; bits: 64.

	int1Ty := LLVMIntegerType new context: self; bits: 1.
	int8Ty := LLVMIntegerType new context: self; bits: 8.
	int16Ty := LLVMIntegerType new context: self; bits: 16.
	int32Ty := LLVMIntegerType new context: self; bits: 32.
	int64Ty := LLVMIntegerType new context: self; bits: 64.
	int128Ty := LLVMIntegerType new context: self; bits: 128.
	
	enumAttributeHandles := Dictionary new.
]

{ #category : #accessing }
LLVMContext >> int128Ty [
	^ int128Ty
]

{ #category : #accessing }
LLVMContext >> int16Ty [
	^ int16Ty
]

{ #category : #accessing }
LLVMContext >> int1Ty [
	^ int1Ty
]

{ #category : #accessing }
LLVMContext >> int32Ty [
	^ int32Ty
]

{ #category : #accessing }
LLVMContext >> int64Ty [
	^ int64Ty
]

{ #category : #accessing }
LLVMContext >> int8Ty [
	^ int8Ty
]

{ #category : #accessing }
LLVMContext >> labelTy [
	^ labelTy
]

{ #category : #accessing }
LLVMContext >> metadataTy [
	^ metadataTy
]

{ #category : #accessing }
LLVMContext >> typeAt: name ifAbsentPut: ifAbsentBlock [
	^ types at: name ifAbsentPut: ifAbsentBlock
]

{ #category : #accessing }
LLVMContext >> voidTy [
	^ voidTy
]
