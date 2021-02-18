Class {
	#name : #LLVMC,
	#superclass : #FFILibrary,
	#category : #'LLVM-IR-API'
}

{ #category : #testing }
LLVMC class >> isAvailable [ 
	^ self uniqueInstance isAvailable
]

{ #category : #'as yet unclassified' }
LLVMC >> disposeMessage: message [
	^ self ffiCall: #(void LLVMDisposeMessage(char *message))
]

{ #category : #testing }
LLVMC >> isAvailable [
	^ [
		self libraryName isString
	] on: Error do: [ false ]
]

{ #category : #'accessing platform' }
LLVMC >> unix32LibraryName [
	^ FFIUnix32LibraryFinder findAnyLibrary: #('libLLVM-10.so' libLLVM-11.so)
]

{ #category : #'accessing platform' }
LLVMC >> unix64LibraryName [
	^ FFIUnix64LibraryFinder findAnyLibrary: #('libLLVM-10.so' libLLVM-11.so)
]

{ #category : #'accessing platform' }
LLVMC >> win32LibraryName [ 
	^ FFIWindowsLibraryFinder new
		userPaths: #('c:\Program Files\LLVM\bin');
		findAnyLibrary: #('LLVM.dll')
]
