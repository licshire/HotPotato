package com.vandermore.networking.p2p.events
{
	import flash.events.Event;
	
	public class HeartbeatEvent extends Event
	{
		public static const PULSE : String = "heartPulse";
		public static const HEART_REMOVED : String = "heartRemoved";
		
		public var peerID : String;
		
		override public function clone():Event
		{
			return new HeartbeatEvent( type, peerID, bubbles, cancelable );
		}
		
		public function HeartbeatEvent( type:String, peerID : String = null, bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super(type, bubbles, cancelable);
			
			this.peerID = peerID;
		}
	}
}