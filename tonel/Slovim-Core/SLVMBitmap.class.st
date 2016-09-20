Class {
	#name : #SLVMBitmap,
	#superclass : #Object,
	#instVars : [
		'width',
		'height',
		'data',
		'pitch'
	],
	#category : #'Slovim-Core-Analysis'
}

{ #category : #'instance creation' }
SLVMBitmap class >> width: width height: height [
	^ self new width: width height: height
]

{ #category : #'instance creation' }
SLVMBitmap class >> width: width height: height pitch: pitch data: data [
	^ self new width: width height: height pitch: pitch data: data
]

{ #category : #accessing }
SLVMBitmap >> atRow: row column: column [
	^ self atX: column - 1 y: row - 1
]

{ #category : #accessing }
SLVMBitmap >> atRow: row column: column put: value [
	^ self atX: column - 1 y: row - 1 put: value
]

{ #category : #accessing }
SLVMBitmap >> atX: x y: y [
	| index bit |
	index := (y*pitch) + (x // 8) + 1.
	bit := x \\ 8.
	^ ((data at: index) bitAnd: (1<<bit)) ~= 0
]

{ #category : #accessing }
SLVMBitmap >> atX: x y: y put: value [
	| index bit newValue |
	index := (y*pitch) + (x // 8) + 1.
	bit := x \\ 8.
	newValue := ((data at: index) bitOr: (value asBit<<bit)).
	data at: index put: newValue.
	^ value
]

{ #category : #accessing }
SLVMBitmap >> clearColumn: columnIndex [
	| index bit x andMask |
	x := columnIndex - 1.
	index := (x // 8) + 1.
	bit := x \\ 8.
	andMask := (1 << bit) bitXor: 16rFF.
	1 to: height do: [ :y |
		data at: index put: ((data at: index) bitAnd: andMask).
		index := index + pitch
	]
]

{ #category : #enumerating }
SLVMBitmap >> complement [
	| size resultData |
	size := pitch * height.
	resultData := ByteArray new: size.
	1 to: size do: [ :i |
		resultData at: i put: ((data at: i) bitXor: 16rFF)
	].

	^ self class width: width height: height pitch: pitch data: resultData
]

{ #category : #accessing }
SLVMBitmap >> data [
	^ data
]

{ #category : #accessing }
SLVMBitmap >> height [
	^ height
]

{ #category : #enumerating }
SLVMBitmap >> intersection: bitmap [
	| size otherData resultData |
	self assert: width = bitmap width.
	self assert: height = bitmap height.
	self assert: pitch = bitmap pitch.
	size := pitch * height.
	otherData := bitmap data.
	resultData := ByteArray new: size.
	1 to: size do: [ :i |
		resultData at: i put: ((data at: i) bitAnd: (otherData at: i))
	].

	^ self class width: width height: height pitch: pitch data: resultData
]

{ #category : #accessing }
SLVMBitmap >> pitch [
	^ pitch
]

{ #category : #accessing }
SLVMBitmap >> setColumn: columnIndex [
	| index bit x orMask |
	x := columnIndex - 1.
	index := (x // 8) + 1.
	bit := x \\ 8.
	orMask := 1 << bit.
	1 to: height do: [ :y |
		data at: index put: ((data at: index) bitOr: orMask).
		index := index + pitch
	]
]

{ #category : #accessing }
SLVMBitmap >> setRow: rowIndex [
	| index |
	index := (rowIndex - 1)*pitch + 1.
	index to: index + pitch - 1 do: [ :x |
		data at: x put: 16rff.
	]
]

{ #category : #enumerating }
SLVMBitmap >> union: bitmap [
	| size otherData resultData |
	self assert: width = bitmap width.
	self assert: height = bitmap height.
	self assert: pitch = bitmap pitch.
	size := pitch * height.
	otherData := bitmap data.
	resultData := ByteArray new: size.
	1 to: size do: [ :i |
		resultData at: i put: ((data at: i) bitOr: (otherData at: i))
	].

	^ self class width: width height: height pitch: pitch data: resultData
]

{ #category : #accessing }
SLVMBitmap >> width [
	^ width
]

{ #category : #'instance creation' }
SLVMBitmap >> width: newWidth height: newHeight [
	width := newWidth.
	height := newHeight.
	pitch := (width + 7) // 8.
	data := ByteArray new: pitch*height
	
]

{ #category : #'instance creation' }
SLVMBitmap >> width: newWidth height: newHeight pitch: newPitch data: newData [
	width := newWidth.
	height := newHeight.
	pitch := newPitch.
	data := newData
	
]
