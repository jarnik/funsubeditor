package org.af
{
	import com.jeroenwijering.player.Player;
	import com.jeroenwijering.events.PlayerEvent;
	import com.jeroenwijering.events.SPLoaderEvent;
	
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import com.jeroenwijering.events.ModelEvent;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class FunSubEditor extends Player 
	{
		[Embed(source = '../../../lib/player.swf', symbol = 'player_fla.player_1')]
		//[Embed(source='../../../lib/player.swc', symbol='player_fla.player_1')]
		public var playerClass:Class;							
		
		private var subDisplay:SubtitleDisplay;
		private var subPanel:SubPanel;
		private var menuPanel:MenuPanel;
		
		private var subFilename:String;
		private var videoFilename:String;
		
		public function FunSubEditor():void 
		{
			var child:DisplayObject = addChild( skin = new playerClass() );
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			subFilename = ( loaderInfo.parameters.subs ? loaderInfo.parameters.subs : "funsub03-fumoffu.ass" );
			videoFilename = ( loaderInfo.parameters.video ? loaderInfo.parameters.video : "funsub01-slayers.flv" );
			
			this.config.width = this.stage.stageWidth / 2;
			this.config.height = this.stage.stageHeight;
			this.config.resizing = false;
			this.config.file = videoFilename;
			
			var timer:Timer = new Timer( 1400, 1 );
			timer.addEventListener( TimerEvent.TIMER_COMPLETE, stats );			
			timer.start();			
			
			var source:SubSource = new SubSource();
			source.addEventListener( Event.COMPLETE, source_loadedHandler );
			source.load( subFilename );
			
			subPanel = new SubPanel( stage.stageWidth/2 );
			addChild( subPanel );
			subPanel.x = stage.stageWidth / 2;
			subPanel.setSubSource( source );
			subPanel.addEventListener( SubEvent.CHANGE, subpanel_changeHandler );
			subPanel.addEventListener( SubEvent.EDIT, subpanel_editHandler );
			
			subDisplay = new SubtitleDisplay( stage.stageWidth/2 );
			addChild( subDisplay );
			subDisplay.x = this.stage.stageWidth * 0.25;
			subDisplay.y = this.stage.stageHeight - 30;
			subDisplay.setSubSource( source );
			
			addChild( menuPanel = new MenuPanel( this.stage.stageWidth/2, source ) );
			
			addEventListener( PlayerEvent.READY, player_readyHandler );						
		}
		
		private function source_loadedHandler( e:Event ):void {
			if ( subPanel )
				subPanel.update();
		}
		
		private function player_readyHandler( e:PlayerEvent ):void {
			this.view.addModelListener( ModelEvent.TIME, model_timeHandler );
		}
		
		private function subpanel_changeHandler( e:Event ):void {
			if ( subDisplay )
				subDisplay.update();
			if ( menuPanel )
				menuPanel.saveEnabled = true;
		}
		
		private function subpanel_editHandler( e:SubEvent ):void {
			var position:Number = e.line.startTime_ms / 1000;
			this.view.sendEvent("SEEK", position);			
			this.view.sendEvent("PLAY", false);
			if ( subDisplay )
				subDisplay.update( position );
		}		
		
		private function model_timeHandler( e:ModelEvent ):void {
			if ( subDisplay )
				subDisplay.update( e.data.position );
		}
		
		private function stats( e:Event = null ):void {					
		}	
		
	}
	
}