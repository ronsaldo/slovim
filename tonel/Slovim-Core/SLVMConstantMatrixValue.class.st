Class {
	#name : #SLVMConstantMatrixValue,
	#superclass : #SLVMConstantAggregateValue,
	#category : #'Slovim-Core-SSA'
}

{ #category : #visiting }
SLVMConstantMatrixValue >> accept: aVisitor [
	^ aVisitor visitConstantMatrixValue: self
]

{ #category : #converting }
SLVMConstantMatrixValue >> asFloatArray [
	"This methods reads the content of a constant matrix into a float array in row major order.
	 This method is implemented with the purpose of facilitating the writing of tests"
	| result |
	result := FloatArray new: type columns * type rows.
	slots doWithIndex: [ :column :columnIndex |
		column slots doWithIndex: [ :element :rowIndex |
			result at: (rowIndex -1 ) * type columns + columnIndex put: element value asFloat
		]
	].
	^ result
]

{ #category : #testing }
SLVMConstantMatrixValue >> isConstantMatrixValue [
	^ true
]

{ #category : #printing }
SLVMConstantMatrixValue >> mnemonic [
	^ #constmatrix
]
