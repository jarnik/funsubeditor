package org.af
{
	import com.gskinner.geom.ColorMatrix;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class MenuPanel extends Sprite
	{
		[Embed(source = '../../../lib/disk.png')]
		private var disk:Class;
		
		private var saveIcon:MovieClip;
		
		private var _width:Number;
		private var _source:SubSource;
		
		public function MenuPanel( w:Number, source:SubSource ):void {
			_width = w;
			
			saveIcon = new MovieClip();			
			var saveImg:DisplayObject = saveIcon.addChild( new disk() );
			saveImg.x = 3;
			saveImg.y = 3;		
			
			_source = source;
			
			addChild( saveIcon );
			saveEnabled = false;
			
		}
		
		private function saveIcon_clickHandler( e:MouseEvent ):void {
			trace("save");
			save();
		}
		
		public function set saveEnabled( value:Boolean ):void {
			if ( value ) {							
				saveIcon.filters = [];			
				saveIcon.buttonMode = true;
				saveIcon.addEventListener( MouseEvent.CLICK, saveIcon_clickHandler );				
			} else {
				var fadeMatrix:ColorMatrix = new ColorMatrix();
				fadeMatrix.adjustSaturation( -100 );
				saveIcon.filters = [new ColorMatrixFilter( fadeMatrix )];			
				saveIcon.buttonMode = false;
				if ( saveIcon.hasEventListener(MouseEvent.CLICK) )
					saveIcon.removeEventListener( MouseEvent.CLICK, saveIcon_clickHandler );
			}			
		}
		
		private function save():void {
			var vars:URLVariables = new URLVariables();
			vars.exportString = _source.exportTT();
			vars.videoUrl = "01";
			
			var request:URLRequest = new URLRequest();
			request.method = URLRequestMethod.POST;
			request.url = "save.php";
			request.data = vars; 
			
			var loader:URLLoader = new URLLoader();		
			loader.addEventListener(Event.COMPLETE, loader_completeHandler);
			loader.load( request );
		}
		
		private function loader_completeHandler( e:Event ):void {
			saveEnabled = false;
		}
		
	}
	
}