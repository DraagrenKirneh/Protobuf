"
Root visitor class for visitng a one of object
"
Class {
	#name : #PbOneOfVisitor,
	#superclass : #Object,
	#category : #'Protobuf-Core-Models'
}

{ #category : #visiting }
PbOneOfVisitor >> accept: anObject [

	anObject 
		ifNil: [ self visitNil ]
		ifNotNil: [ anObject acceptVisitor: self ]
]

{ #category : #visiting }
PbOneOfVisitor >> startVisiting: anObject [

	anObject 
		ifNil: [ self visitNil ]
		ifNotNil: [ anObject acceptVisitor: self ]
]

{ #category : #visiting }
PbOneOfVisitor >> visitNil [

	" default is to do nothing "

	
	
]
