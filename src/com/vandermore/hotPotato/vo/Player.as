package com.vandermore.hotPotato.vo
{
	
	[RemoteClass(alias="com.vandermore.hotPotato.vo.Player")]
	/**
	 *
	 * @langversion ActionScript 3.0
	 * @playerversion Flash x.x
	 * 
	 * @author dmoore
	 * @since  Apr 21, 2011
	 */
	public class Player
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		public var name : String;
		
		public var playerID : Number;
		
		public var score : int = 0;
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		public function Player()
		{
		}
	}
}