Extension { #name : #SLVMCompilationTarget }

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMCompilationTarget class >> forCurrentImage [
	^ self forCurrentImageWithoutLowcode
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMCompilationTarget class >> forCurrentImageWithLowcode [
	^ (Smalltalk wordSize = 4 ifTrue: [ self pharoLowcode32 ] ifFalse: [ self pharoLowcode64 ])
		types: SLVMCompilationTargetTypes forCurrentImage;
		currentImage: true
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMCompilationTarget class >> forCurrentImageWithoutLowcode [
	^ (Smalltalk wordSize = 4 ifTrue: [ self pharo32 ] ifFalse: [ self pharo64 ])
		types: SLVMCompilationTargetTypes forCurrentImage;
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
SLVMCompilationTarget class >> pharoLowcode32 [
	^ SLVMPharoLowcode32CompilationTarget new
]

{ #category : #'*Slovim-StackCodeGenerator' }
SLVMCompilationTarget class >> pharoLowcode64 [
	^ SLVMPharoLowcode64CompilationTarget new
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
