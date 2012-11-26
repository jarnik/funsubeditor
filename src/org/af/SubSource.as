package org.af
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.xml.XMLNode;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class SubSource extends EventDispatcher	
	{
		
		public var lines:Array;
		private var _fileName:String;
		
		public function SubSource():void {		
			lines = [];			
		}
		
		public function getSubtitle( time_ms:Number ):String {			
			var index:int = 0;			
			while ( index < lines.length ) {
				var line:SubLine = lines[ index ];
				if ( line.startTime_ms <= time_ms && line.endTime_ms >= time_ms ) {
					break;
				}
				index++;
			}
			
			if ( index == lines.length )
				return "";
			else
				return (lines[index] as SubLine).text;
		}
		
		public function load( filename:String ):void {
			_fileName = filename;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, loader_completeHandler );
			loader.load( new URLRequest( filename ) );
		}
		
		private function loader_completeHandler( e:Event ):void {
			switch ( _fileName.toLowerCase().substr( -3) ) {
				case "srt":
					parseSRT( e.target.data );
					break;
				case "ass":
					parseASS( e.target.data );
					break;
				default:
					parseTT( e.target.data );
					break;
			}
		}
		
		public function parseASS( data:String ):void {
			var lineData:Array = data.split("\n");						
			var index:int =  0;
			while ( lineData[index].indexOf("[Events]") == -1 && index < lineData.length )
				index++;
			index += 2;
			
			while ( index < lineData.length ) {
				var params:Array = (lineData[index] as String).split(",");
				if ( params[0].indexOf("Dialogue") == -1 ) {
					index++;
					continue;
				}
				var startTime:String = params[1];
				var endTime:String = params[2];
				addLine( timecodeToMs( startTime ),timecodeToMs( endTime ) , params.slice(9).join("") ); 
				index ++;
			}
			
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		public function parseTT( data:String ):void {			
			namespace ns = "http://www.w3.org/2006/04/ttaf1#styling";
			use namespace ns;
			
			namespace ns2 = "http://www.w3.org/2006/04/ttaf1";
			use namespace ns2;
			
			var xml:XML = new XML( data );
						
			for each ( var p:XML in xml.body.div.p ) {			
				addLine( timecodeToMs(p.@begin), timecodeToMs(p.@end), p ); 
			}
			
			dispatchEvent( new Event( Event.COMPLETE ) );			
		}
		
		public function parseSRT( data:String ):void {			
			var lineData:Array = data.split("\n");						
			var index:int = 0;
			while ( (index + 2) < lineData.length ) {
				var startTime:String = lineData[index + 1].substr(0, 12);
				var endTime:String = lineData[index + 1].substr(17, 12);				
				addLine( timecodeToMs( startTime, /(.*):(.*):(.*),(.*)/i ),timecodeToMs( endTime, /(.*):(.*):(.*),(.*)/i ) , lineData[index+2] ); 
				index += 4;
			}
			
			dispatchEvent( new Event( Event.COMPLETE ) );						
		}		
		
		private function timecodeToMs( timecode:String, pattern:RegExp = null ):Number {			
			var re:RegExp = /(.*):(.*):(.*)\.(.*)/i;
			if ( pattern )
				re = pattern;
			var result:Object = re.exec(timecode);	
			if ( !result )
				return 0;
			var h:Number =  parseInt( (result[1] as String) );
			var m:Number =  parseInt( (result[2] as String) )
			var s:Number =  parseInt( (result[3] as String) )
			var ms:Number =  parseFloat( "0." + (result[4] as String))  * 1000;
			
			return h*3600000 + m*60000 + s*1000 + ms;
		}
		
		private function addLine( start:Number, end:Number, text:String ):void {
			if ( !lines )
				return;
				
			trace("adding line: "+text);
			lines.push( new SubLine(text, start, end) );
		}
		
		public function exportTT():String {
			var prefix:String = '<?xml version="1.0" encoding="UTF-8"?>\n';
			var xml:XML = <tt xml:lang="en" xmlns="http://www.w3.org/2006/04/ttaf1" xmlns:tts="http://www.w3.org/2006/04/ttaf1#styling">
				<head>
				</head>
				<body tts:textAlign="center">
				<div>									
				</div>
				</body>
				</tt>
			for ( var i:int = 0; i < lines.length; i++ ) {
				var line:SubLine = (lines[i] as SubLine);
				var lineXML:XML = <p begin={line.startTimeCode} end={line.endTimeCode}>{line.text}</p>;
				xml.body.div.* += lineXML;
			}
			return prefix+xml.toString();
		}
	}
	
}