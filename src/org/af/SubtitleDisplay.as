package org.af
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class SubtitleDisplay extends Sprite
	{
		
		private var _source:SubSource;
		private var subtitleField:TextField;
		private var format:TextFormat;
		private var subTimer:Timer;
		private var _width:Number;
		
		private var lastTime:Number = 0;
		
		public function SubtitleDisplay( width:Number ):void {
			_width = width;
			init();			
		}
		
		private function init():void {
			subtitleField = new TextField();							
			subtitleField.filters = [ new GlowFilter( 0x000000, 1, 3, 3 , 4 ) ];
			
			subtitleField.width = _width;
			subtitleField.text = "abcdefg sa \n dsad sasdsad";
			subtitleField.textColor = 0xffffff;
			subtitleField.selectable = false;
			subtitleField.height = 20;
			//subtitleField.background = true;
			//subtitleField.backgroundColor = 0x505050;
			addChild( subtitleField );
			
			format = new TextFormat( "Verdana", 12 );			
			format.align = TextFormatAlign.CENTER;
			subtitleField.setTextFormat( format );			
			subtitleField.x = -_width / 2;			
		}
		
		public function setSubSource( source:SubSource ):void {
			_source = source;
			update();
		}
		
		private function show( text:String ):void {			
			subtitleField.text = text;			
			
			subtitleField.setTextFormat( format );
			subtitleField.height = subtitleField.textHeight + 10;
			subtitleField.y = -subtitleField.textHeight;			
		}
		
		private function hide():void { 			
		}	
		
		public function update( time:Number = NaN ):void {
			if ( isNaN( time ) )
				time = lastTime;
			else
				lastTime = time;
			show( _source.getSubtitle( time*1000 ) );
		}
	}
	
}