Extension { #name : #Object }

{ #category : #'*Slovim-MessagePack' }
Object >> asSLVMMessagePackSerializableObject [
	^ self subclassResponsibility
]

{ #category : #'*Slovim-MessagePack' }
Object >> isSLVMMessagePackExtensionData [
	^ false
]

{ #category : #'*Slovim-MessagePack' }
Object >> slvmMessagePackEncodeWith: encoder [
	^ self asSLVMMessagePackSerializableObject slvmMessagePackEncodeWith: encoder
]
