Class {
	#name : #SLVMDebugSubprogram,
	#superclass : #SLVMDebugLocalScope,
	#category : #'Slovim-Core-Debug'
}

{ #category : #visiting }
SLVMDebugSubprogram >> accept: visitor [
	^ visitor visitDebugSubprogram: self
]
