Class {
	#name : #LLVMDisposableRef,
	#superclass : #LLVMRef,
	#category : #'LLVM-IR-API'
}

{ #category : #'memory management' }
LLVMDisposableRef >> autoRelease [
	self class finalizationRegistry add: self
]

{ #category : #'memory management' }
LLVMDisposableRef >> dispose [
	self class finalizationRegistry remove: self.
	self primitiveDispose.
	handle := nil
]

{ #category : #'memory management' }
LLVMDisposableRef >> finalize [
	(handle isNotNil and: [ handle isNull not ]) ifTrue: [
		self primitiveDispose
	]
]
