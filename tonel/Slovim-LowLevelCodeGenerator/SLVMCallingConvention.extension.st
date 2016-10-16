Extension { #name : #SLVMCallingConvention }

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> allocatableRegisters [
	^ self usableRegisters copyWithoutAll: self scratchRegisters
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> calledRegisters [
	self subclassResponsibility
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> callerRegisters [
	self subclassResponsibility
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> canBeFrameLess [
	self subclassResponsibility
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> floatReturnRegister [
	self subclassResponsibility
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> gotRegister [
	self subclassResponsibility
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> hasContextMetadata [
	self subclassResponsibility
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> hasSegmentedStack [
	^ false
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> intResultRegister [
	self subclassResponsibility
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> isStackCleanedByCaller [
	self subclassResponsibility
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> receiverRegister [
	self subclassResponsibility
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> scratchRegisters [
	self subclassResponsibility
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> secondIntResultRegister [
	self subclassResponsibility
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> stackAlignment [
	self subclassResponsibility
]

{ #category : #'*Slovim-LowLevelCodeGenerator' }
SLVMCallingConvention >> usableRegisters [
	self subclassResponsibility
]
