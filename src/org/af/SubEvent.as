package org.af
{
	import flash.events.Event;
	import org.af.SubLine;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class SubEvent extends Event 
	{
		public static const CHANGE:String = "change";
		public static const EDIT:String = "edit";	
		
		public var line:SubLine;
		
		public function SubEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false ) { 
			super(type, bubbles, cancelable);
		} 		
	}
	
}