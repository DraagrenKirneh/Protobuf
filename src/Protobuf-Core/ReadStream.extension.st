Extension { #name : #ReadStream }

{ #category : #'*Protobuf-Core' }
ReadStream >> peekForAny: aCollection [

	| next |
	
	next := self next.
	
	^ aCollection 
		detect: [ :item | item = next ]
		ifFound: [ true ]
		ifNone: [ self skip: -1. false ]
]
