"
sharedStack to keep a number of elements present. 
The idea is to have this at the class side so that some elements such as buffers can easily be reused
"
Class {
	#name : #PbSharedStack,
	#superclass : #Object,
	#instVars : [
		'array',
		'index',
		'mutex'
	],
	#category : #'Protobuf-Core-Codec'
}

{ #category : #'instance creation' }
PbSharedStack class >> new [

	^ self new: 10
]

{ #category : #'instance creation' }
PbSharedStack class >> new: aSize [
	
	^ self basicNew 
		initialize: aSize;
		yourself
]

{ #category : #initialization }
PbSharedStack >> initialize [

	super initialize.
	
	index := 1.
	mutex := Mutex new.
]

{ #category : #initialization }
PbSharedStack >> initialize: aNumber [

	self initialize.
	
	array := Array new: aNumber 
]

{ #category : #adding }
PbSharedStack >> pop [
	
	| obj |
	
	obj := nil.
	
	mutex critical: [ 
		index > 0 ifTrue: [ 
			obj := array at: index.
			index := index - 1	
		]	
	].

	^ obj 
]

{ #category : #adding }
PbSharedStack >> push: anObject [

	mutex critical: [ 
		index < array size ifTrue: [ 
			index := index + 1.
			array at: index put: anObject	
		]	
	]
]

{ #category : #accessing }
PbSharedStack >> size [

	^ array size
]
