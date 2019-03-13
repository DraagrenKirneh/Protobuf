"
enum abstract type
"
Class {
	#name : #PbEnum,
	#superclass : #Object,
	#instVars : [
		'value'
	],
	#category : #'Protobuf-Core-Models'
}

{ #category : #info }
PbEnum class >> encodeType [

	^ #enum
]

{ #category : #info }
PbEnum class >> protoIdentifier [

	^ self subclassResponsibility 
]

{ #category : #deprecation }
PbEnum class >> systemIcon [

	^ self iconNamed: #smallSave
]

{ #category : #comparing }
PbEnum >> = anotherObject [

	^ self class == anotherObject class and: [ 
		value = anotherObject value	
	]
]

{ #category : #accessing }
PbEnum >> asSymbol [

	^ (self symbolTable detect: [ :each | each first = value ]) second
]

{ #category : #initialization }
PbEnum >> initialize [

	super initialize.
	
	value := 0
]

{ #category : #wire }
PbEnum >> pbDecodeFrom: aPbWireDecoder [

	value := aPbWireDecoder nextVarInt 

]

{ #category : #accessing }
PbEnum >> symbolTable [

	^ self subclassResponsibility 
]

{ #category : #initialization }
PbEnum >> value [

	^ value
]

{ #category : #accessing }
PbEnum >> value: aNumber [

	value := aNumber 

]
