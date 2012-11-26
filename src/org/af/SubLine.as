package org.af
{
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class SubLine
	{
		
		public var text:String;
		public var startTime_ms:Number;
		public var endTime_ms:Number;
		
		public function SubLine( _text:String, _start:Number, _end:Number ):void {			
			text = _text;
			startTime_ms = _start;
			endTime_ms = _end;			
		}		
		
		public function get startTimeCode():String {
			return formatTime( startTime_ms );
		}
		
		public function get endTimeCode():String {
			return formatTime( endTime_ms );
		}
		
		private function leadingZeros(theNumber:Number,digits:Number = 2):String {
			var ourString:String = String(theNumber);
			for(var i:uint = digits-ourString.length; i > 0; i--){
				ourString = "0"+ourString;
			}
			return ourString;
		}
		
		private function formatTime( time_ms:Number ):String {					
			var mins:String = leadingZeros( Math.floor(time_ms / 60000) );
			time_ms = time_ms % 60000;
			var secs:String = leadingZeros( Math.floor(time_ms / 1000) );
			var milis:String = leadingZeros( Math.floor(time_ms % 1000),3  );						
			return mins + ":" + secs + "." + milis;
		}
				
	}
	
}