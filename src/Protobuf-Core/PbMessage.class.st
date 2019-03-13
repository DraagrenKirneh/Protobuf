"
I am an abstract class for Protobuf message classes.
I specify field initialization and encoding / decoding methods

"
Class {
	#name : #PbMessage,
	#superclass : #Object,
	#category : #'Protobuf-Core-Models'
}

{ #category : #info }
PbMessage class >> encodeType [

	^ #message
]

{ #category : #'instance creation' }
PbMessage class >> fromWire: aByteArray [

	^ ProtobufDecoder data: aByteArray do: [ :decoder |
		self new 
			pbDecodeFrom: decoder;
			yourself	
	]

]

{ #category : #deprecation }
PbMessage class >> systemIcon [

	^ self iconNamed: #smallSave
]

{ #category : #wire }
PbMessage >> encoded [

	^ ProtobufEncoder encodeObjectOn: [ :aStream |
		self pbEncodeOn: aStream	
	].
]

{ #category : #initialization }
PbMessage >> initialize [

	super initialize.
	
	self initializeFields
]

{ #category : #initialization }
PbMessage >> initializeFields [

	"no fields"
]

{ #category : #wire }
PbMessage >> pbDecode: aTag from: aPbWireDecoder [

	"default is skip, assuming that the generated message has no fields"

	aPbWireDecoder skipNext
]

{ #category : #wire }
PbMessage >> pbDecodeFrom: aPbWireDecoder [

	aPbWireDecoder decode: self

]

{ #category : #wire }
PbMessage >> pbEncodeOn: aPbWireEncoder [

	"default is nop, assuming that the generated message has no fields"
]
