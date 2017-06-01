Class {
	#name : #SLVMNativeRuntimeObjectModel,
	#superclass : #SLVMObjectModel,
	#category : #'Slovim-Core-Type'
}

{ #category : #'trampoline names' }
SLVMNativeRuntimeObjectModel >> messageSendTrampoline [
	^ #_slvm_dynrun_send_trampoline
]

{ #category : #'trampoline names' }
SLVMNativeRuntimeObjectModel >> messageSuperSendTrampoline [
	^ #_slvm_dynrun_supersend_trampoline
]

{ #category : #'trampoline names' }
SLVMNativeRuntimeObjectModel >> stackLimitTrampoline [
	^ #_slvm_dynrun_stack_limit_trap
]
