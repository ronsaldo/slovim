Class {
	#name : #LLVMValueRefArray,
	#superclass : #FFIExternalArray,
	#category : #'LLVM-IR-API'
}

{ #category : #'instance creation' }
LLVMValueRefArray class >> new: size [
	^ self newType: #'void*' size: size
]

{ #category : #'instance creation' }
LLVMValueRefArray class >> withAll: elements [
	| result |
	result := self new: elements size.
	elements doWithIndex: [ :el :index |
		result at: index put: el validHandle getHandle
	].
	^ result
]
