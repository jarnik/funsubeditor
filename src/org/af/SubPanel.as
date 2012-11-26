package org.af
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class SubPanel extends Sprite
	{
		
		private var _source:SubSource;
		
		private var content:MovieClip;		
		private var scrollbar:Scrollbar;
		private var _width:Number;
		
		private var panels:Array;
		
		public function SubPanel( _w:Number ):void {
			
			_width = _w;
			addChild( content = new MovieClip() );									
			addChild( scrollbar = new Scrollbar() );
			scrollbar.x = _width - 17;
			
			update();
		}
		
		public function setSubSource( source:SubSource ):void {
			_source = source;
			update();
		}
		
		public function update():void {
			if ( !_source || _source.lines.length==0)
				return;
		
			trace("updating lines: "+_source.lines.length);
			panels = [];					
				
			for (var i:int = 0 ; i < _source.lines.length; i++ ) {
				var subLine:SubLine = _source.lines[i];				
				var subLinePanel:SubLinePanel = new SubLinePanel( _width - 10, subLine );				
				content.addChild( subLinePanel );				
				subLinePanel.y = 10 + i * (subLinePanel.height );
				
				subLinePanel.addEventListener( SubEvent.EDIT, subLinePanel_editHandler );
				panels.push( subLinePanel );
			}
			
			//this.y = 10;
			scrollbar.init( content, "a", 0, false, 1 );
			
			return;
		}
		
		private function subLinePanel_editHandler( e:Event ):void {
			for ( var i:int = 0; i < panels.length; i++ )
				(panels[i] as SubLinePanel).stopEdit();
		}
	}
	
}