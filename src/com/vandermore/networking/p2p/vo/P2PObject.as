package com.vandermore.networking.p2p.vo
{
	[Bindable]
	[RemoteClass( 'com.vandermore.networking.p2p.vo.P2PObject' )]
	public class P2PObject extends Object
	{
		public var text : String;
		public var neighborID : String;
		public var uniqueID : Number;
		public var userName : String;
		
		public function toString() : String
		{
			var objectSummary : String;
			objectSummary = "text : " + text;
			objectSummary += " ";
			objectSummary += "sender : " + neighborID;
			objectSummary += " ";
			objectSummary += "uniqueID : " + uniqueID;
			objectSummary += " ";
			objectSummary += "userName : " + userName;
			
			return objectSummary;
		}
		
		public function P2PObject()
		{
		}
	}
}