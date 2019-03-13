"
encoding 
"
Class {
	#name : #ProtobufEncoder,
	#superclass : #ProtobufCodec,
	#classVars : [
		'StreamStack'
	],
	#category : #'Protobuf-Core-Codec'
}

{ #category : #enumerating }
ProtobufEncoder class >> encodeObjectOn: aBlock [

	| encoder result |
	
	encoder := StreamStack pop ifNil: [ 
		self on: (ByteArray new: 200) writeStream 
	].
	
	aBlock value: encoder.
	result := encoder contents.
		
	encoder clearStream.
	StreamStack push: encoder.

	^ result

]

{ #category : #initialization }
ProtobufEncoder class >> initialize [

	StreamStack := PbSharedStack new: 10
]

{ #category : #enumerating }
ProtobufEncoder class >> newEncoderDo: aBlock [

	| encoder result |
	
	encoder := StreamStack pop ifNil: [ 
		self on: (ByteArray new: 200) writeStream 
	].
	
	aBlock value: encoder.
	result := encoder contents.
		
	encoder clearStream.
	StreamStack push: encoder.

	^ result

]

{ #category : #'private - writing' }
ProtobufEncoder >> clearStream [

	stream reset
]

{ #category : #accessing }
ProtobufEncoder >> contents [
	"('LOG: ' , thisContext sender asString) crLog."
	
	^ stream contents
]

{ #category : #copying }
ProtobufEncoder >> copyContentTo: anotherDecoder [

	| content |
	
	content := stream originalContents.

	anotherDecoder writeVarInt: stream position.
	
	anotherDecoder stream 
		next: stream position
		putAll: content 
		startingAt: 1
		

]

{ #category : #writing }
ProtobufEncoder >> encodeString: aString [

	utf8Encoder 
		next: aString size 
		putAll: aString 
		startingAt: 1 
		toStream: stream
]

{ #category : #packing }
ProtobufEncoder >> pack: aCollection using: aBlock [

	<pbEncode: #(packed) field: #writeLengthTag:>
	
	self class newEncoderDo: [ :tempEncoder |
		aCollection do: [ :each |
			aBlock value: tempEncoder value: each
		].
		tempEncoder copyContentTo: self				
	]
]

{ #category : #writing }
ProtobufEncoder >> write32Bit: aNumber [

	<pbEncode: #(float fixed32 sfixed32) field: #write32BitTag:>	
	
	aNumber isFloat ifTrue: [ ^ self write32Bit: aNumber asIEEE32BitWord ].
	aNumber negative ifTrue: [ ^ self write32Bit: 16r100000000 + aNumber ].
	
	stream 
		nextPut: (aNumber digitAt: 1);
		nextPut: (aNumber digitAt: 2);
		nextPut: (aNumber digitAt: 3);
		nextPut: (aNumber digitAt: 4)

]

{ #category : #'writing - field' }
ProtobufEncoder >> write32BitTag: aNumber [

	self writeTag: aNumber type: Wire32Bit  
]

{ #category : #writing }
ProtobufEncoder >> write64Bit: aNumber [

	<pbEncode: #(double fixed64 sfixed64) field: #write64BitTag:>	

	aNumber isFloat ifTrue: [ 
		self 
			write32Bit: (aNumber at: 2);
			write32Bit: (aNumber at: 1)
			
	] ifFalse: [ 
	
		| first |
		
		first := aNumber digitAt: 8.
		aNumber negative ifTrue: [ first := first bitOr: 16r80 ].
		stream nextPut: first.
		
		7 to: 1 by: -1 do: [ :ix | stream nextPut: (aNumber digitAt: ix) ].
		
	]

]

{ #category : #'writing - field' }
ProtobufEncoder >> write64BitTag: aNumber [

	self writeTag: aNumber type: Wire64Bit 
]

{ #category : #'writing - type 0' }
ProtobufEncoder >> writeBoolean: aBoolean [

	<pbEncode: #(bool) field: #writeVarIntTag:>
	
	self writeVarInt: aBoolean asBit
]

{ #category : #writing }
ProtobufEncoder >> writeBytes: aByteArray [

	<pbEncode: #(bytes) field: #writeLengthTag:>	

	self writeVarInt: aByteArray size.

	stream nextPutAll: aByteArray
]

{ #category : #'writing - type 0' }
ProtobufEncoder >> writeEnum: anEnum [

	<pbEncode: #(enum) field: #writeVarIntTag:>
	
	self writeVarInt: anEnum value
]

{ #category : #'writing - type 0' }
ProtobufEncoder >> writeInteger: anInteger [
	
	<pbEncode: #(int32 int64) field: #writeVarIntTag:>	
		
	anInteger positive 
		ifTrue: [ self writeVarInt: anInteger ]
		ifFalse: [ self writeVarInt: 18446744073709551616 + anInteger ].
]

{ #category : #'writing - field' }
ProtobufEncoder >> writeLengthTag: aNumber [

	self writeTag: aNumber type: WireLengthDelimited 
]

{ #category : #writing }
ProtobufEncoder >> writeMap: aMap using: aBlock [
	
	<pbEncode: #(map) field: #writeLengthTag:>	
	
	self class newEncoderDo: [ :tempEncoder |
		aMap associationsDo: [ :assoc |
			aBlock value: tempEncoder value: assoc	
		].
		tempEncoder copyContentTo: self				
	]
]

{ #category : #writing }
ProtobufEncoder >> writeMessage: aMessage [ 
	
	<pbEncode: #(message) field: #writeLengthTag:>	
	
	aMessage ifNil: [ ^ self ].
	
	self class newEncoderDo: [ :tempEncoder |
		aMessage pbEncodeOn: tempEncoder.
		tempEncoder copyContentTo: self				
	]
]

{ #category : #writing }
ProtobufEncoder >> writeOneOf: aOneOfObject [
	
	<pbEncode: #(oneof) field: nil>	
	
	aOneOfObject ifNotNil: [ :obj | 
		obj pbEncodeOn: self 
	]
]

{ #category : #'writing - type 0' }
ProtobufEncoder >> writeSignedInt32: anInteger [
	
	<pbEncode: #(sint32) field: #writeVarIntTag:>	
	
	self writeVarInt: ( (anInteger << 1) bitXor: (anInteger >> 31) )
]

{ #category : #'writing - type 0' }
ProtobufEncoder >> writeSignedInt64: anInteger [
	
	<pbEncode: #(sint64) field: #writeVarIntTag:>	
	
	self writeVarInt: ( (anInteger << 1) bitXor: (anInteger >> 63) )
]

{ #category : #writing }
ProtobufEncoder >> writeString: aString [
	
	<pbEncode: #(string) field: #writeLengthTag:>	
	
	"Size is equal to number of characters so its safe to encode directly"
	aString isByteString ifTrue: [ 
		^ self 
			writeVarInt: aString size;
			encodeString: aString
	].
	
	"unknown how many bytes will be used, so use a temp encoder"
	self class newEncoderDo: [ :tempEncoder |
		tempEncoder 
			encodeString: aString;
			copyContentTo: self				
	].

]

{ #category : #'private - writing' }
ProtobufEncoder >> writeTag: afieldNumber type: aType [

	self writeVarInt: ((afieldNumber << 3) bitOr: aType)
]

{ #category : #'writing - type 0' }
ProtobufEncoder >> writeVarInt: integer [

	<pbEncode: #(uint32 uint64) field: #writeVarIntTag:>	

	| int byte |
	
	int := integer.
	
	[ 
		byte := int bitAnd: 127. "lowest 7 bits"
		int := int >> 7.
		
	int > 0 ] whileTrue: [
		stream nextPut: (byte bitOr: 128) 
	].
		
	stream nextPut: byte
]

{ #category : #'writing - field' }
ProtobufEncoder >> writeVarIntTag: aNumber [

	self writeTag: aNumber type: WireVarInt 
]
