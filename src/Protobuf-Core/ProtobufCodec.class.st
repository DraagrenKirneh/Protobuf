"
See PBProtobuf class>>initialize for wiretypes.

Some interesting comments from the net:

fixed32 and fixed64 are unsigned integers encoded directly as 4 or 8 bytes on the wire, in little-endian order.  sfixed32 and sfixed64 are the same, but signed -- negative numbers just use two's complement.  ZigZag encoding is explicitly designed for use with varint-encoded values, so it doesn't make sense to use it here.  Sorry about the naming; it's the result of gradual evolution.  Proto1 only had fixed32 and fixed64, which were unsigned from the start.  The ""sfixed"" variants were added in proto2.

Groups are *not* encoded like nested messages.  Nested messages are encoded as a length followed by the message contents (the ""length-delimited"" wire type).  Groups are encoded as a start-group tag, followed by the message contents, followed by an end-group tag.

Groups are still used by many protocols inside Google, so all implementations of protobufs that we use internally had to support them.  It's possible that some of these protocols will be exposed publicly at some point (though I don't know of any specific examples), which would mean that external implementations need to support them too.  However, any *new* protocols should definitely not use them.  It's probably safe to not implement them for now, although you should at least recognize the wire type and be able to ignore groups seen on the wire, for forwards-compatibility.
"
Class {
	#name : #ProtobufCodec,
	#superclass : #Object,
	#instVars : [
		'stream',
		'utf8Encoder'
	],
	#classVars : [
		'Wire32Bit',
		'Wire64Bit',
		'WireEndGroup',
		'WireLengthDelimited',
		'WireStartGroup',
		'WireVarInt'
	],
	#category : #'Protobuf-Core-Codec'
}

{ #category : #'class initialization' }
ProtobufCodec class >> initialize [
	"self initialize"
	
	"The available wire types are as follows:

	Type	Meaning	Used For
	0	Varint	int32, int64, uint32, uint64, sint32, sint64, bool, enum
	1	64-bit	fixed64, sfixed64, double
	2	Length-delimited	string, bytes, embedded messages, packed repeated fields
	3	Start group	groups (deprecated)
	4	End group	groups (deprecated)
	5	32-bit	fixed32, sfixed32, float"

	WireVarInt := 0.
	Wire64Bit := 1.
	WireLengthDelimited := 2.
	WireStartGroup := 3.
	WireEndGroup := 4.
	Wire32Bit := 5.
	
]

{ #category : #'instance creation' }
ProtobufCodec class >> on: aStream [

	^ self new 
		stream: aStream; 
		yourself
]

{ #category : #initialization }
ProtobufCodec >> initialize [

	super initialize.
	
	utf8Encoder := ZnUTF8Encoder new.
]

{ #category : #accessing }
ProtobufCodec >> stream [
	
	^ stream
]

{ #category : #accessing }
ProtobufCodec >> stream: aByteArrayReadStream [
	
	stream := aByteArrayReadStream
]

{ #category : #accessing }
ProtobufCodec >> utf8Encoder [

	^ utf8Encoder 
]
