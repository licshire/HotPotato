package com.vandermore.networking.p2p
{
	import com.vandermore.networking.p2p.events.HeartbeatEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	/**
	 * Keeps track of peer IDs, and sees if a peer has failed two checkins.
	 * @author David Moore
	 * 
	 */
	public class Heartbeat extends EventDispatcher
	{
		//----------------------------------------------------------------------------
		//
		// Constants
		//
		//----------------------------------------------------------------------------
		//The rate at which to check the heartbeat.
		public static const BEAT : int = 2000;
		
		//----------------------------------------------------------------------------
		//
		// Variables
		//
		//----------------------------------------------------------------------------
		private static var instance : Heartbeat;
		
		protected var heartbeat : Timer;
		
		protected var peerHeartbeats : Dictionary;

		//----------------------------------------------------------------------------
		//
		// Methods
		//
		//----------------------------------------------------------------------------
		/**
		 * Adds the heartbeat timer if we need one, and starts it. 
		 * 
		 */
		public function addHeart () : void
		{
			if ( !peerHeartbeats )
			{
				peerHeartbeats = new Dictionary();
				startHeartbeat();
			}
		}
			
		/**
		 * Just like in the Temple of Doom! 
		 * @param key String ID of the peer heart to remove.
		 * 
		 */
		public function removeHeart ( key : String ) : void
		{
			delete peerHeartbeats[key]; //removes the key
			dispatchEvent( new HeartbeatEvent( HeartbeatEvent.HEART_REMOVED, key ) );
		}
		
		/**
		 * Takes a peer ID as a key and adds it to the dictionary. 
		 * @param key
		 * 
		 */
		public function peerPulse( peer : String ) : void
		{
			addHeart();
			peerHeartbeats[ peer ] = new Date();
		}
		
		/**
		 * Sets up and starts the heartbeat. 
		 * 
		 */
		public function startHeartbeat() : void
		{
			if ( !heartbeat )
			{
				heartbeat = new Timer( BEAT );
				heartbeat.addEventListener( TimerEvent.TIMER, heartbeatListener, false, 0, true );
			}
			heartbeat.start();
		}
		
		/**
		 * Stops the heartbeat and tears down the timer. 
		 * 
		 */
		public function stopHeartbeat() : void
		{
			if ( !heartbeat )
				return;
			
			heartbeat.stop();
			heartbeat.removeEventListener( TimerEvent.TIMER, heartbeatListener );
			heartbeat = null;
		}
		
		/**
		 * Checks the timing of the heartbeats. If the pulse hasn't been
		 * updated in the time of two beats, then the peer is considered dead.
		 *  
		 * @param peerBeat
		 * @return 
		 * 
		 */
		protected function isItDeadJim( peerBeat : Date ) : Boolean
		{
			var beatTime : Number;
			beatTime = new Date().time - peerBeat.time;
			
			if ( beatTime > (2 * BEAT ) )
			{
				//Damnit Jim, I'm a doctor not a bricklayer!
				return true;
			}
			
			// I'm not dead yet!
			return false;
		}
		
		/**
		 * Loops through the dictionary, and checks all of the hearts for pulses.
		 * If there is no pulse, then it removes the heart. 
		 * 
		 */
		protected function checkForPulses() : void
		{
			for ( var k : String in peerHeartbeats ) {
				var lastBeat : Date = peerHeartbeats[ k ];
				var key : String = k;
				
				//Check the peers for a pulse.
				if ( isItDeadJim( lastBeat ) )
				{
					removeHeart( key );
				}
			}
		}

		/**
		 * Returns an instance of the singleton Heartbeat. 
		 * @return 
		 * 
		 */
		public static function getInstance() : Heartbeat
		{
			if ( !instance )
			{
				instance = new Heartbeat( new SingletonEnforcer() );
			}
			
			return instance;
		}
		
		//----------------------------------------------------------------------------
		//
		// Listeners
		//
		//----------------------------------------------------------------------------
		/**
		 * The timer listener we use to check the pulses of the peers. 
		 * @param event
		 * 
		 */
		public function heartbeatListener ( event : TimerEvent ) : void
		{
			checkForPulses();
			dispatchEvent( new HeartbeatEvent( HeartbeatEvent.PULSE ) );
		}
		
		//----------------------------------------------------------------------------
		//
		// Constructor
		//
		//----------------------------------------------------------------------------
		public function Heartbeat( singletonEnforcer : SingletonEnforcer )
		{
			if ( singletonEnforcer == null )
			{
				throw new Error( "SINGLETON_EXCEPTION" );
			}
			instance = this;
		}
	}
}

class SingletonEnforcer {}
