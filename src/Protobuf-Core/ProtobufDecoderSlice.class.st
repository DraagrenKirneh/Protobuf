"
slice for variable length type 2 things
"
Class {
	#name : #ProtobufDecoderSlice,
	#superclass : #ProtobufDecoder,
	#instVars : [
		'end'
	],
	#category : #'Protobuf-Core-Codec'
}

{ #category : #accessing }
ProtobufDecoderSlice >> atEnd [

	^ stream position >= end
]

{ #category : #accessing }
ProtobufDecoderSlice >> end: aNumber [

	end := aNumber 
]

{ #category : #'as yet unclassified' }
ProtobufDecoderSlice >> stateFrom: parentDecoder [

	stream := parentDecoder stream.
	utf8Encoder := parentDecoder utf8Encoder.
	wireType := parentDecoder wireType.
	
]
