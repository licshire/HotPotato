package com.vandermore.hotPotato.vo
{
	[Bindable]
	public class Neighbor
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		public var neighbor : String;
		
		public var peerID : String;
		
		public var humanName : String = "Temp Name " + Math.round( Math.random() * 100 + 1 );
		
		//----------------------------------------
		//
		// Methods
		//
		//----------------------------------------
		public function toString() : String
		{
			return "humanName : " + humanName + "\n :: neighbor : " + neighbor + "\n :: peerID : " +  peerID;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		public function Neighbor()
		{
		}
	}
}