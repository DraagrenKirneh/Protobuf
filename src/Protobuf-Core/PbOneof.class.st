"
wrapper class for one of fields, which wraps the real type into a PbOneOf subclass knowing the tag and how to enocde and decode correctly
"
Class {
	#name : #PbOneof,
	#superclass : #Object,
	#instVars : [
		'value'
	],
	#category : #'Protobuf-Core-Models'
}

{ #category : #info }
PbOneof class >> decodeFrom: aPbWireDecoder [

	^ self new
		pbDecodeFrom: aPbWireDecoder
]

{ #category : #info }
PbOneof class >> encodeType [

	^ #oneof
]

{ #category : #visiting }
PbOneof >> acceptVisitor: anObject [

	self subclassResponsibility 
]

{ #category : #initialization }
PbOneof >> defaultValue [

	self subclassResponsibility 
]

{ #category : #initialization }
PbOneof >> initialize [

	super initialize.
	
	value := self defaultValue
]

{ #category : #wire }
PbOneof >> pbDecodeFrom: aPbWireDecoder [

	self subclassResponsibility 

]

{ #category : #wire }
PbOneof >> pbEncodeOn: aPbWireEncoder [

	self subclassResponsibility 
]

{ #category : #initialization }
PbOneof >> tag [

	self subclassResponsibility 
]
