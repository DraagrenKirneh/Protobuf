"
c# numerical limit values:

Int32.MaxValue 
	 2147483647
	#[ 255 255 255 255 7 ]
	
Int32.MinValue  
	 -2147483648
	#[ 128 128 128 128 248 255 255 255 255 1 ]
	
Int64.MaxValue 
	9223372036854775807
	#[ 255 255 255 255 255 255 255 255 127 ]
	
Int64.MinValue  
	-9223372036854775808
	 #[ 128 128 128 128 128 128 128 128 128 1 ]
	ZigZag: 	#[255 255 255 255 255 255 255 255 255 1]
	
	
"
Class {
	#name : #PbIntBuffer,
	#superclass : #Object,
	#instVars : [
		'buffer',
		'index'
	],
	#category : #'Protobuf-Core-Codec'
}

{ #category : #'write and read' }
PbIntBuffer >> fillIntegerFrom: aStream [

	| byte value |

	index := 0.
	
	[ 
	
		byte := aStream next.	
		value := byte bitAnd: 127.
		index := index + 1.
		buffer at: index put: value	
			
	] doWhileFalse: [ byte = value ].


]

{ #category : #initialization }
PbIntBuffer >> initialize [

	super initialize.
	
	buffer := ByteArray new: 10.
	index := 0.
]

{ #category : #'write and read' }
PbIntBuffer >> readIntegerFrom: aStream [

	self fillIntegerFrom: aStream.

	^ index < 10 
		ifTrue: [ self readPositive ]
		ifFalse: [ self readNegative ]
]

{ #category : #'write and read' }
PbIntBuffer >> readNegative [

	| integer |

	integer := 0.	
	1 to: 9 do: [ :ix |
		integer := integer bitOr: ( 127 - (buffer at: ix) << (7 * (ix - 1)) ).
	].

	^ (integer + 1) negated
]

{ #category : #'write and read' }
PbIntBuffer >> readPositive [

	| integer |
	
	index = 1 ifTrue: [ ^ buffer at: 1 ].
	
	integer := 0.
	1 to: index by: 1 do: [ :ix |
		integer := integer bitOr: ( (buffer at: ix) << (7 * (ix - 1)) ).
	].

	^ integer
]
