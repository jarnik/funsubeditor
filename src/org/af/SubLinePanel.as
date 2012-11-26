package org.af
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flash.events.MouseEvent;
	import flash.text.TextFieldType;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class SubLinePanel extends MovieClip
	{				
		
		private var _subLine:SubLine;
		private var subLineClip:DisplayObject;
		private var textField:TextField;
		private var textFieldFormat:TextFormat;
		private var timeField:TextField;
		private var timeFieldFormat:TextFormat;
		
		private var _width:Number;
		
		public function SubLinePanel( _w:Number, subLine:SubLine ):void {
			_width = _w;
			_subLine = subLine;
			init();
		}
		
		private function init():void {
														
			this.addEventListener( MouseEvent.MOUSE_OVER, text_mouseHandler );
			this.addEventListener( MouseEvent.MOUSE_OUT, text_mouseHandler );
			this.addEventListener( MouseEvent.MOUSE_DOWN, text_mouseHandler );	

			addChild( timeField = new TextField());
			timeField.x = 5;
			timeField.setTextFormat( new TextFormat( "Verdana", 8 ) );
			timeField.height = 15;			
			timeField.selectable = false;
			timeFieldFormat = new TextFormat( null, 8 );
									
			addChild( textField = new TextField());
			textField.x = 10;
			textField.y = 15;
			textField.width = _width - 20;
			textField.height = 35;
			textField.addEventListener( Event.CHANGE, text_changeHandler );
			textField.selectable = false;
			textField.multiline = true;
			textFieldFormat = new TextFormat( "Verdana" );
									
			this.mouseChildren = false;
			this.buttonMode = true;
			this.useHandCursor = true;			
			
			editing = false;
			
			update();
		}
		
		public function update():void {						
			textField.text = _subLine.text;						
			textField.setTextFormat( textFieldFormat );	
			timeField.text = _subLine.startTimeCode+" > "+_subLine.endTimeCode;			
			timeField.setTextFormat( timeFieldFormat );
		}
		
		// save edited text to source
		public function save():void {	
			_subLine.text = textField.text;
			dispatchEvent( new SubEvent( SubEvent.CHANGE, true ) );
		}
		
		private function text_mouseHandler( e:MouseEvent ):void {
			switch( e.type ) {
				case MouseEvent.MOUSE_OVER:					
					break;
				case MouseEvent.MOUSE_OUT:
					break;
				case MouseEvent.MOUSE_DOWN:					
					startEdit();
					break;
			}						
		}
		
		private function startEdit():void {
			var e:SubEvent = new SubEvent( SubEvent.EDIT, true );
			e.line = this._subLine;
			dispatchEvent( e );
			mouseChildren = true;
			stage.focus = textField;
			editing = true;
		}
		
		public function stopEdit():void {						
			editing = false;
			mouseChildren = false;
		}
		
		private function set editing( value:Boolean ):void {
			textField.border = true;
			textField.background = true;
			if ( !value ) {
				textField.type = TextFieldType.DYNAMIC;
				textField.selectable = false;
				textField.borderColor = 0xe0e0e0;
				textField.backgroundColor = 0xf0f0f0;
			} else {
				textField.borderColor = 0xf0b0b0;			
				textField.type = TextFieldType.INPUT;
				textField.selectable = true;
				textField.backgroundColor = 0xffffff;
			}
		}
		
		private function text_changeHandler( e:Event=null ):void {
			save();
			update();
		}
	}
	
}