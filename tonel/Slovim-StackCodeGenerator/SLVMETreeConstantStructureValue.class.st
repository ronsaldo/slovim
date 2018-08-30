Class {
	#name : #SLVMETreeConstantStructureValue,
	#superclass : #SLVMETreeConstantAggregateValue,
	#category : #'Slovim-StackCodeGenerator'
}

{ #category : #visiting }
SLVMETreeConstantStructureValue >> accept: aVisitor [
	^ aVisitor visitConstantStructureValue: self
]

{ #category : #'public access' }
SLVMETreeConstantStructureValue >> evaluate [
	| offset |
	evaluationValue ifNotNil: [ ^ evaluationValue ].
	evaluationValue := type behavior basicNew.
	slots doWithIndex: [ :slot : index |
		offset := type offsets at: index.
		slot type write: slot evaluate intoPointer: (evaluationValue asPointerToInternalObjectData _slvm_pointerAddOffset: offset)
	].

	^ evaluationValue
]
