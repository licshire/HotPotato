package com.vandermore.networking.p2p.events
{
	import flash.events.Event;
	
	public class MessageEvent extends Event
	{
		public static const MESSAGE_RECEIVED : String = "Message Received";
		public static const MESSAGE_SENT : String = "Message Sent";
		
		public var message : Object;
		
		override public function clone():Event
		{
			return new MessageEvent( type, message, bubbles, cancelable );
		}
		
		public function MessageEvent(type:String, message : Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.message = message;
			super(type, bubbles, cancelable);
		}
	}
}