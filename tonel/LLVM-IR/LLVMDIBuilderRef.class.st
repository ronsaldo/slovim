Class {
	#name : #LLVMDIBuilderRef,
	#superclass : #LLVMDisposableRef,
	#instVars : [
		'context',
		'module'
	],
	#category : #'LLVM-IR-API'
}

{ #category : #accessing }
LLVMDIBuilderRef >> context [

	^ context
]

{ #category : #accessing }
LLVMDIBuilderRef >> context: anObject [

	context := anObject
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createArrayType: baseType size: size align: alignInBits subscripts: subscripts count: subscriptCount [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateArrayType(self, uint64 size,
                             uint32 alignInBits, LLVMMetadataRef baseType,
                             void *subscripts,
                             uint subscriptCount)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createAutoVariableIn: scope name: name len: nameLen file: file line: line type: type alwaysPreserve: alwaysPreserve flags: flags align: alignInBits [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateAutoVariable(
    self, LLVMMetadataRef scope, char *name,
    size_t nameLen, LLVMMetadataRef file, uint line, LLVMMetadataRef type,
    bool alwaysPreserve, uint flags, uint32 alignInBits)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createBasicTypeNamed: name len: nameLen sizeInBits: sizeInBits encoding: encoding flags: flags [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateBasicType(self, char *name,
                             size_t nameLen, uint64 sizeInBits,
                             uint encoding,
                             uint flags)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createClassTypeIn: scope name: name len: nameLen file: file line: line
	size: sizeInBits align: alignInBits
	flags: flags derivedFrom: derivedFrom
	elements: elements count: numElements
	vtableHolder: vtableHolder
	templateParams: templateParams
	uniqueId: uniqueId uniqueIdLen: uniqueIdLen [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateClassType(self,
    LLVMMetadataRef scope, char *name, size_t nameLen,
    LLVMMetadataRef file, uint line, uint64 sizeInBits,
    uint32 alignInBits, uint64 "offsetInBits"0, uint flags,
    LLVMMetadataRef derivedFrom,
    void *elements, uint numElements,
    LLVMMetadataRef vtableHolder, LLVMMetadataRef templateParams,
    char *uniqueId, size_t uniqueIdLen)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createCompileUnitWithLang: lang fileRef: fileRef
	producer: producer producerLen: producerLen
	isOptimized: isOptimized
	runtimeVer: runtimeVer
	kind: kind dwoId: dwoId splitDebugInlining: splitDebugInlining
	debugInfoForProfiling: debugInfoForProfiling
	sysRoot: sysRoot sysRootLen: sysRootLen
	sdk: sdk sdkLen: sdkLen [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateCompileUnit(self, uint lang,
    LLVMMetadataRef fileRef, char *producer, size_t producerLen,
    bool isOptimized, "flags" nil, "flags len" size_t 0,
    uint runtimeVer, "split name" nil, "spli name len" size_t 0,
	 uint kind, uint dwoId, bool splitDebugInlining,		
    bool debugInfoForProfiling, char *sysRoot, size_t sysRootLen,
    char *sdk, size_t sdkLen)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createEmptyDIExpression [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateExpression(self, nil, size_t 0)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createEnumerationTypeIn: scope name: name len: nameLen
	file: file line: line
	size: sizeInBits align: alignInBits
	elements: elements count: numElements classType: classType [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateEnumerationType(
    self, LLVMMetadataRef scope, char *name,
    size_t nameLen, LLVMMetadataRef file, uint line,
    uint64 sizeInBits, uint32 alignInBits, void *elements,
    uint numElements, LLVMMetadataRef classType)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createFile: filename len: filenameLen directory: directory directoryLen: directoryLen [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateFile(self, char *filename,
                        size_t filenameLen, char *directory,
                        size_t directoryLen)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createFunctionInScope: scope
	name: name nameLen: nameLen
	linkageName: linkageName linkageNameLen: linkageNameLen
	file: file lineNo: lineNo type: type
	isLocalToUnit: isLocalToUnit isDefinition: isDefinition
	scopeLine: scopeLine flags: flags optimized: isOptimized [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateFunction(self,
		LLVMMetadataRef scope, char *name,
    size_t nameLen, char *linkageName, size_t linkageNameLen,
    LLVMMetadataRef file, uint lineNo, LLVMMetadataRef type,
    bool isLocalToUnit, bool isDefinition,
    uint scopeLine, uint flags, bool isOptimized)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createGlobalVariableExpressionIn: scope name: name nameLen: nameLen linkage: linkage len: linkageLen file: file line: line type: type localToUnit: localToUnit expr: expr decl: decl align: alignInBits [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateGlobalVariableExpression(
    self, LLVMMetadataRef scope, char *name,
    size_t nameLen, char *linkage, size_t linkageLen, LLVMMetadataRef file,
    uint line, LLVMMetadataRef type, bool localToUnit,
    LLVMMetadataRef expr, LLVMMetadataRef decl, uint32 alignInBits)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createInheritanceIn: type baseType: baseType baseOffset: baseOffset vbptrOffset: vbptrOffset flags: flags [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateInheritance(self,
                               LLVMMetadataRef type, LLVMMetadataRef baseType,
                               uint64 baseOffset, uint32 vbptrOffset,
                               uint flags)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createLexicalBlockFileIn: scope file: file discriminator: discriminator [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateLexicalBlockFile(self,
                                    LLVMMetadataRef scope,
                                    LLVMMetadataRef file,
                                    uint discriminator)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createLexicalBlockIn: scope file: file line: line column: column [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateLexicalBlock(self, LLVMMetadataRef scope,
    LLVMMetadataRef file, uint line, uint column)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createLocationLine: line column: column scope: scope inlinedAt: inlinedAt [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateDebugLocation(LLVMContextRef context, uint line,
                                 uint column, LLVMMetadataRef scope,
                                 LLVMMetadataRef inlinedAt)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createMemberIn: scope name: name len: nameLen
	file: file line: line
	size: sizeInBits alignInBits: alignInBits offsetInBits: offsetInBits
	flags: flags type: type [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateMemberType(
    self, LLVMMetadataRef scope, char *name,
    size_t nameLen, LLVMMetadataRef file, uint line,
    uint64 sizeInBits, uint32 alignInBits, uint64 offsetInBits,
    uint flags, LLVMMetadataRef type)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createNamespaceIn: scope name: name len: nameLen exportSymbols: exportSymbols [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateNameSpace(self,
                             LLVMMetadataRef scope,
                             char *name, size_t nameLen,
                             bool exportSymbols)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createParameterVariableIn: scope name: name len: nameLen argNo: argNo file: file line: line type: type alwaysPreserve: alwaysPreserve flags: flags [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateParameterVariable(
    self, LLVMMetadataRef scope, char *name,
    size_t nameLen, uint argNo, LLVMMetadataRef file, uint line,
    LLVMMetadataRef type, bool alwaysPreserve, uint flags)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createPointerType: baseType size: sizeInBits align: alignInBits addressSpace: addressSpace name: name nameLen: nameLen [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreatePointerType(self, LLVMMetadataRef baseType,
    uint64 sizeInBits, uint32 alignInBits, uint addressSpace,
    char *name, size_t nameLen)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createQualifiedType: baseType tag: tag [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateQualifiedType(self, uint tag, LLVMMetadataRef baseType)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createReferenceType: baseType tag: tag [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateReferenceType(self, uint tag, LLVMMetadataRef baseType)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createStructTypeIn: scope name: name len: nameLen file: file line: line
	size: sizeInBits align: alignInBits
	flags: flags derivedFrom: derivedFrom
	elements: elements count: numElements
	runtimeLang: runtimeLang vtableHolder: vtableHolder
	uniqueId: uniqueId uniqueIdLen: uniqueIdLen [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateStructType(self,
	LLVMMetadataRef scope, char *name,
    size_t nameLen, LLVMMetadataRef file, uint line,
    uint64 sizeInBits, uint32 alignInBits, uint flags,
    LLVMMetadataRef derivedFrom, void *elements,
    uint numElements, uint runtimeLang, LLVMMetadataRef vtableHolder,
    char *uniqueId, size_t uniqueIdLen)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createSubroutineTypeInFile: file parameters: parameters count: count flags: flags [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateSubroutineType(self,
                                  LLVMMetadataRef file,
                                  void *parameters,
                                  uint count,
                                  uint flags)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createTempGlobalVariableFwdDeclIn: scope name: name nameLen: nameLen linkage: linkage len: linkageLen file: file line: line type: type localToUnit: localToUnit decl: decl align: alignInBits [
	^ (self primitiveCreateTempGlobalVariableFwdDeclIn: scope name: name nameLen: nameLen linkage: linkage len: linkageLen file: file line: line type: type localToUnit: localToUnit decl: decl align: alignInBits)
		autoRelease;
		yourself
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> createUnionTypeIn: scope name: name len: nameLen file: file line: line
	size: sizeInBits align: alignInBits
	flags: flags
	elements: elements count: numElements
	runtimeLang: runtimeLang
	uniqueId: uniqueId uniqueIdLen: uniqueIdLen [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateUnionType(
    self, LLVMMetadataRef scope, char *name,
    size_t nameLen, LLVMMetadataRef file, uint line,
    uint64 sizeInBits, uint32 alignInBits, uint flags,
    void *elements, uint numElements, uint runtimeLang,
    char *uniqueId, size_t uniqueIdLen)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> finalizeBuilder [
	^ self ffiCall: #(void LLVMDIBuilderFinalize(self)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> getOrCreateSubrangeFrom: lowerBound count: count [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderGetOrCreateSubrange(self, int64 lowerBound, int64 count)) library: LLVMC
]

{ #category : #accessing }
LLVMDIBuilderRef >> module [

	^ module
]

{ #category : #accessing }
LLVMDIBuilderRef >> module: anObject [

	module := anObject
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> primitiveCreateTempGlobalVariableFwdDeclIn: scope name: name nameLen: nameLen linkage: linkage len: linkageLen file: file line: line type: type localToUnit: localToUnit decl: decl align: alignInBits [
	^ self ffiCall: #(LLVMMetadataRef LLVMDIBuilderCreateTempGlobalVariableFwdDecl(
    self, LLVMMetadataRef scope, char *name,
    size_t nameLen, char *linkage, size_t linkageLen, LLVMMetadataRef file,
    uint line, LLVMMetadataRef type, bool localToUnit,
    LLVMMetadataRef decl, uint32 alignInBits)) library: LLVMC
]

{ #category : #'memory management' }
LLVMDIBuilderRef >> primitiveDispose [
	^ self ffiCall: #(void LLVMDisposeDIBuilder(self)) library: LLVMC
]
