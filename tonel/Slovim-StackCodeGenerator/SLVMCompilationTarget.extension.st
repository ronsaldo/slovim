Extension { #name : #SLVMCompilationTarget }

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMCompilationTarget class >> forCurrentImage [
	^ (Smalltalk wordSize = 4 ifTrue: [ self pharo32 ] ifFalse: [ self pharo64 ])
		currentImage: true
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMCompilationTarget class >> pharo32 [
	^ SLVMPharo32CompilationTarget new
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMCompilationTarget class >> pharo64 [
	^ SLVMPharo64CompilationTarget new
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMCompilationTarget class >> webAssembly [
	^ self webAssembly32
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMCompilationTarget class >> webAssembly32 [
	^ SLVMWebAssembly32CompilationTarget new
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMCompilationTarget class >> webAssembly64 [
	^ SLVMWebAssembly64CompilationTarget new
]
