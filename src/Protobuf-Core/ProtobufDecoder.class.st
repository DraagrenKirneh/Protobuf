"
wire decoder, uses an internal int buffer for reading integers
"
Class {
	#name : #ProtobufDecoder,
	#superclass : #ProtobufCodec,
	#instVars : [
		'wireType',
		'intbuf'
	],
	#category : #'Protobuf-Core-Codec'
}

{ #category : #accessing }
ProtobufDecoder class >> data: aByteArray [

	^ self on: aByteArray readStream 
]

{ #category : #accessing }
ProtobufDecoder class >> data: aByteArray do: aBlock [

	^ aBlock value: (self data: aByteArray)
]

{ #category : #converting }
ProtobufDecoder >> asSlice: numberOfBytes do: aBlock [ 
				
	ProtobufDecoderSlice new 
		stateFrom: self;
	   end: stream position + numberOfBytes;
		untilEndDo: aBlock
]

{ #category : #testing }
ProtobufDecoder >> atEnd [
	"End of input?"

	^ stream atEnd
]

{ #category : #converting }
ProtobufDecoder >> decode: aMessage [
	
	[ self atEnd ] whileFalse: [ 
		aMessage pbDecode: self nextFieldNumber from: self 
	].
]

{ #category : #initialization }
ProtobufDecoder >> initialize [

	super initialize.
	
	intbuf := PbIntBuffer new.
	
]

{ #category : #'reading - 32 bit' }
ProtobufDecoder >> next32Bit [
	"Return little-edian encoded 32 bits. Used for fixed32, sfixed32, float"
	
	<pbTranslateType: #fixed32>
	
	| number |
	
	number := stream next.
	number := number bitOr: (stream next << 8).
	number := number bitOr: (stream next << 16).
	
	^ number bitOr: (stream next << 24)
]

{ #category : #'reading - 64 bit' }
ProtobufDecoder >> next64Bit [
	"Return 64 bits. Used for fixed64, sfixed64, double"
	
	<pbTranslateType: #fixed64>
	
	| high |
	
	high := self next32Bit.
	
	^ high = 0 
		ifTrue: [ self next32Bit ]
		ifFalse: [ high + (self next32Bit << 32) ]
	
]

{ #category : #'reading - varint' }
ProtobufDecoder >> nextBoolean [

	<pbTranslateType: #bool>

	^ self nextVarInt > 0
	
]

{ #category : #'reading - sized' }
ProtobufDecoder >> nextByteArray [
	"Length delimited byte array.
	Used for string, bytes, embedded messages, packed repeated fields.
	Read length first, then read and return that number of bytes."

	<pbTranslateType: #bytes>

	^ stream next: self nextVarInt
]

{ #category : #'reading - 64 bit' }
ProtobufDecoder >> nextDouble [
	"Read next field as a double."
	<pbTranslateType: #double>
	
	^ (Float basicNew: 2) 
			basicAt: 2 put: self next32Bit;
			basicAt: 1 put: self next32Bit;
			yourself  
]

{ #category : #private }
ProtobufDecoder >> nextFieldNumber [

	"
	
	Return next field number, store the wire value
	"

	| key |
	
	key := self nextVarInt.
	wireType := key bitAnd: 7.
	
	^ key bitShift: -3
]

{ #category : #'reading - 32 bit' }
ProtobufDecoder >> nextFloat [
	"Read next field as a double."
	<pbTranslateType: #float>
	
	^ Float fromIEEE32Bit: self next32Bit
]

{ #category : #'reading - varint' }
ProtobufDecoder >> nextInteger [

	"Read next field as an integer (int32, int64)"
	<pbTranslateType: #int32>
	<pbTranslateType: #int64>
	
	^ intbuf readIntegerFrom: stream
]

{ #category : #'reading - 32 bit' }
ProtobufDecoder >> nextSignedFixed32Bit [
	"Return 64 bits. Used for fixed64, sfixed64, double"
	
	| number |
	
	<pbTranslateType: #sfixed32>
	
	number := self next32Bit.
	
	^ ((number digitAt: 4) < 16r80) 
		ifTrue: [ number ]
		ifFalse: [ -16r100000000 + number ]

	
]

{ #category : #'reading - 64 bit' }
ProtobufDecoder >> nextSignedFixed64Bit [
	"Return 64 bits. Used for fixed64, sfixed64, double"
	| byte integer |
	<pbTranslateType: #sfixed64>
	
	byte := stream next.
	
	integer := (byte bitAnd: 16r80) isZero 
		ifTrue: [ LargeInteger new: 8 ]
		ifFalse: [ byte := byte bitAnd: 17r7F. LargeNegativeInteger new: 8 ].

	integer digitAt: 8 put: byte.
	
	7 to: 1 by: -1 do: [ :ix |
		integer digitAt: ix put: stream next
	].

	^ integer 
]

{ #category : #'reading - varint' }
ProtobufDecoder >> nextSignedInteger [
	"Read next field as a zig zag encoded sint32, sint64."
	
	<pbTranslateType: #sint32>
	<pbTranslateType: #sint64>
	
	^ self varIntToSint: self nextVarInt 
]

{ #category : #'reading - sized' }
ProtobufDecoder >> nextString [
	"Read next field as string."
	
	<pbTranslateType: #string>
	
	"wireType = WireLengthDelimited ifFalse: [ self error: 'Wrong wireType' ]."
		
	^ utf8Encoder decodeBytes: self nextByteArray 


]

{ #category : #private }
ProtobufDecoder >> nextTag [

	"
	Return next field number, store the wire value
	"

	| key |
	
	key := self nextVarInt.
	wireType := key bitAnd: 7.
	
	^ key bitShift: -3
]

{ #category : #removable }
ProtobufDecoder >> nextValueOnWire [
	"This method can only distinguish the wiretypes
	so the receiver will have to know the exact type
	to convert to."

	"Ok, so sometimes a regular switch could be nice.
	Having blocks in an Array didn't feel that nice either.
	Which is fastest?"
	
	wireType = WireVarInt 			ifTrue: [ ^ self nextVarInt 		].
	wireType = Wire32Bit 				ifTrue: [ ^ self next32Bit 			].
	wireType = Wire64Bit 				ifTrue: [ ^ self next64Bit 			].
	wireType = WireLengthDelimited ifTrue: [ ^ self nextByteArray 	].
	
	wireType = WireStartGroup 		ifTrue: [ self error: 'WireStartGroup deprecated' ].
	wireType = WireEndGroup 			ifTrue: [ self error: 'WireEndGroup deprecated' ].
	
	self error: 'Unknown wiretype: ', wireType asString

]

{ #category : #'reading - varint' }
ProtobufDecoder >> nextVarInt [
	"Return a var int. Used for int32, int64, uint32, uint64, sint32, sint64, bool, enum"
		
	<pbTranslateType: #uint32>
	<pbTranslateType: #uint64>
	
	"As long as each MSB is set we keep
	reading bytes. Then we reverse concatenate the groups of 7 bits.
	The recursion makes it easy to reverse - without allocating a buffer."

	| byte |
	
	byte := stream next.
	
	^ (byte allMask: 128)
		ifTrue: [ (self nextVarInt << 7) bitOr: (byte bitAnd: 127) ]
		ifFalse: [ byte bitAnd: 127 ]
		
	
]

{ #category : #removable }
ProtobufDecoder >> skipNext [

	self nextValueOnWire 
]

{ #category : #packing }
ProtobufDecoder >> unpack: aBlock [

	wireType = WireLengthDelimited ifFalse: [ aBlock value: self. ^ self ].
	
	self asSlice: self nextVarInt do: [ :slice |
		aBlock value: slice	
	].
	
]

{ #category : #enumerating }
ProtobufDecoder >> untilEndDo: aBlock [

	[ self atEnd ] whileFalse: [ aBlock value: self ].

]

{ #category : #private }
ProtobufDecoder >> varIntToSint: integer [

	"Read next field as a zig zag encoded sint32 (or sint64)."

	^ (integer >> 1) bitXor: (integer bitAnd: 1) negated
]

{ #category : #accessing }
ProtobufDecoder >> wireType [

	^ wireType 
]
