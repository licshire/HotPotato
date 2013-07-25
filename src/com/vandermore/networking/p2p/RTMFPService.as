package com.vandermore.networking.p2p
{
	import com.vandermore.hotPotato.vo.Neighbor;
	import com.vandermore.networking.p2p.events.HeartbeatEvent;
	import com.vandermore.networking.p2p.events.MessageEvent;
	import com.vandermore.networking.p2p.vo.P2PObject;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	
	import mx.collections.ArrayCollection;
	
	public class RTMFPService extends EventDispatcher
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		//TODO:: Move this into an event
		public static const CONNECTION_SUCCESS_EVENT : String = "connection success event";
		private const IP_MULTICAST_ADDRESS : String = "225.225.0.1:30303"; 
		//Has to begin with 225, and have a unique UDP port number higher than 1024.
		
		//----------------------------------------
		//
		// Methods
		//
		//----------------------------------------
		private var _netConnection : NetConnection;
		private var _group : NetGroup;
		
		private var _connectionName : String;
		private var _connected:Boolean = false;
		
		protected var heartMonitor : Heartbeat;
		
		[Bindable]
		public var connectedPeers : ArrayCollection;
		
		[Bindable]
		public var userName : String;
		
		//TODO:: Keep Alive signal
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		public function get group():NetGroup
		{
			return _group;
		}

		public function get netConnection() : NetConnection
		{
			return _netConnection;
		}
		
		[Bindable]
		public function get connectionName():String
		{
			return _connectionName;
		}

		public function set connectionName(value:String):void
		{
			_connectionName = value;
		}

		[Bindable]
		public function get connected() : Boolean
		{
			return _connected;
		}
		
		public function set connected( value : Boolean ) : void
		{
			_connected = value;
		}
		
		//----------------------------------------
		//
		// Methods
		//
		//----------------------------------------
		public function connect( connectionName : String ) : void
		{
			if ( !_netConnection )
			{
				this.connectionName = connectionName;
				_netConnection = new NetConnection();
				_netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				_netConnection.connect("rtmfp:"); // <-- The magic. Allows for P2P, no direct connections, but allows for groups.
			} else {
				trace( "Connection already started" );
			}
		}
		
		/**
		 * Closes the group connection so that peers know that the app has disconnected.
		 * 
		 */
		public function disconnect() : void
		{
			_group.close();
			_netConnection.close();
			_group = null;
			_netConnection = null;
		}
		
		private function setupGroup():void
		{
			var groupspec:GroupSpecifier = new GroupSpecifier( connectionName );
			groupspec.postingEnabled = true;
			groupspec.ipMulticastMemberUpdatesEnabled = true; //Can group membership be exchanged on IP multicast sockets.
			groupspec.addIPMulticastAddress( IP_MULTICAST_ADDRESS );
			
			_group = new NetGroup( _netConnection, groupspec.groupspecWithAuthorizations() );
			_group.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			
			heartMonitor = Heartbeat.getInstance();
			heartMonitor.addEventListener( HeartbeatEvent.PULSE, sendPulseHandler );
			heartMonitor.addEventListener( HeartbeatEvent.HEART_REMOVED, peerRemovedHandler );
			heartMonitor.addHeart();
		}
		
		//TODO:: Accept an object to send.
		public function sendMessage(txt:String) : void
		{
			var message:P2PObject = new P2PObject();
			message.text = txt;
			message.neighborID = _group.convertPeerIDToGroupAddress( _netConnection.nearID );
			message.userName = userName;
			//				message.userName = txtUser.text;
			//The uniqueID here is just to make sure if we send duplicate messages in any other way, they will still get sent.
			//This probably is partially circumventing the anti-DOS protections. It's only in here for demo purposes.
			message.uniqueID = Math.round(Math.random()*1000);
			
			_group.post(message);
			
			receiveMessage(message);
		}
		
		public function receiveMessage(message:Object):void
		{
			updateUsername( message as P2PObject );

			//Throw an event here, so that things listening to it can get the new message.
			var messageEvent : MessageEvent = new MessageEvent( MessageEvent.MESSAGE_RECEIVED, message );
			if ( message.text == null )
				return;
			dispatchEvent( messageEvent );
		}
		
		protected function updateUsername( value : P2PObject ) : void
		{
			if ( !value )
				return;
			
			for each ( var neighbor : Neighbor in connectedPeers )
			{
				if ( neighbor.neighbor == value.neighborID )
				{
					neighbor.humanName = value.userName;
//					connectedPeers.refresh();
					break;
				}
			}
		}
		
		protected function neighborConnected( neighbor : String, peerID : String ) : void
		{
			if ( !connectedPeers )
			{
				connectedPeers = new ArrayCollection();
			}
			
			var neighborObject : Neighbor = new Neighbor();
			neighborObject.neighbor = neighbor;
			neighborObject.peerID = peerID;
			
			heartMonitor.peerPulse( peerID );
			
			//Add the neighbor to the connected clients list.
			connectedPeers.addItem( neighborObject );
			trace ( "Added PEER: " + neighborObject );
		}
		
		protected function neighborDisconnected( neighbor : String, peerID : String ) : void
		{
			if ( !connectedPeers )
			{
				return;
			}
			
			//Loop over connected peers to remove it from the array of neighbors.
			for( var i : int = 0; i < connectedPeers.length; i++ )
			{
				var neighborInfo : Neighbor = connectedPeers[ i ] as Neighbor;
				if ( neighborInfo && neighborInfo.neighbor == neighbor )
				{
					var neighborRemoved : Neighbor = connectedPeers.removeItemAt( i ) as Neighbor;
					trace( "Removed PEER : " + neighborRemoved );
					return;
				}
			}
		}
		
		private function netStatusHandler(event:NetStatusEvent):void
		{
			switch(event.info.code){
				case "NetConnection.Connect.Success":
					setupGroup();
					break;
				
				case "NetGroup.Connect.Success":
					connected = true;
					dispatchEvent( new Event( CONNECTION_SUCCESS_EVENT ) );
					break;
				
				case "NetGroup.Posting.Notify":
					receiveMessage(event.info.message);
					break;
				
				case "NetGroup.Neighbor.Connect":
					neighborConnected( event.info.neighbor, event.info.peerID );
					break;
				
				case "NetGroup.Neighbor.Disconnect":
					neighborDisconnected( event.info.neighbor, event.info.peerID );
					heartMonitor.removeHeart( event.info.peerID );
					break;
				
				default :
					trace( event.info );
			}
		}
		
		/**
		 * Whenever our heart beats, send out an "I'm alive" signal. 
		 * @param event
		 * 
		 */
		protected function sendPulseHandler( event : HeartbeatEvent ) : void
		{
			sendMessage(null);
		}
		
		/**
		 * If a peer misses two heartbeats, then we get a message to remove it from our list. 
		 * @param event
		 * 
		 */
		protected function peerRemovedHandler( event : HeartbeatEvent ) : void
		{
			//TODO:: Need to get the neighbor in here, or switch everything to peerID.
			neighborDisconnected( null, event.peerID );
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		public function RTMFPService()
		{
		}
	}
}