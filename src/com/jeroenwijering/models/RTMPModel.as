﻿/**
* Wrapper for playback of video streamed over RTMP.
* 
* All playback functionalities are cross-server (FMS, Wowza, Red5), with the exception of:
* - The SecureToken functionality (Wowza).
* - The FCSubscribe functionality (Limelight/Akamai FMS).
* - getStreamLength / checkBandwidth (FMS3).
**/
package com.jeroenwijering.models {


import com.jeroenwijering.events.*;
import com.jeroenwijering.models.ModelInterface;
import com.jeroenwijering.player.Model;
import com.jeroenwijering.utils.NetClient;
import com.jeroenwijering.utils.TEA;

import flash.display.DisplayObject;
import flash.events.*;
import flash.media.*;
import flash.net.*;
import flash.utils.*;


public class RTMPModel implements ModelInterface {


	/** reference to the model. **/
	private var model:Model;
	/** Video object to be instantiated. **/
	private var video:Video;
	/** NetConnection object for setup of the video stream. **/
	private var connection:NetConnection;
	/** NetStream instance that handles the stream IO. **/
	private var stream:NetStream;
	/** Sound control object. **/
	private var transform:SoundTransform;
	/** Interval ID for the time. **/
	private var timeinterval:Number;
	/** Timeout ID for live stream subscription pings. **/
	private var timeout:Number;
	/** Metadata have been received. **/
	private var metadata:Boolean;


	/** Constructor; sets up the connection and display. **/
	public function RTMPModel(mod:Model):void {
		model = mod;
		connection = new NetConnection();
		connection.addEventListener(NetStatusEvent.NET_STATUS,statusHandler);
		connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
		connection.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
		connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,metaHandler);
		connection.objectEncoding = ObjectEncoding.AMF0;
		connection.client = new NetClient(this);
		video = new Video(320,240);
		quality(model.config['quality']);
		transform = new SoundTransform();
		model.config['mute'] == true ? volume(0): volume(model.config['volume']);
	};


	/** Catch security errors. **/
	private function errorHandler(evt:ErrorEvent):void {
		model.sendEvent(ModelEvent.ERROR,{message:evt.text});
	};


	/** Extract the correct rtmp syntax from the file string. **/
	private function getID(url:String):String {
		var ext:String = url.substr(-4);
		if(ext == '.mp3') {
			return 'mp3:'+url.substr(0,url.length-4);
		} else if(ext == '.mp4' || ext == '.mov' || ext == '.aac' || ext == '.m4a') {
			return 'mp4:'+url;
		} else if (ext == '.flv') {
			return url.substr(0,url.length-4);
		} else {
			return url;
		}
	};


	/** Load content. **/
	public function load():void {
		video.clear();
		model.mediaHandler(video);
		connection.connect(model.playlist[model.config['item']]['streamer']);
		model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.BUFFERING});
	};


	/** Catch noncritical errors. **/
	private function metaHandler(evt:ErrorEvent):void {
		model.sendEvent(ModelEvent.META,{error:evt.text});
	};


	/** Get metadata information from netstream class. **/
	public function onData(dat:Object):void {
		if(dat.type == 'metadata' && !metadata) {
			if(dat.width) {
				video.width = dat.width;
				video.height = dat.height;
			}
			if(model.playlist[model.config['item']]['start'] > 0) {
				seek(model.playlist[model.config['item']]['start']);
			}
			metadata = true;
		} else if(dat.type == 'complete') {
			clearInterval(timeinterval);
			model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.COMPLETED});
		} else if(dat.type == 'fcsubscribe') {
			if(dat.code == "NetStream.Play.StreamNotFound" ) {
				model.sendEvent(ModelEvent.ERROR,{message:"Subscription failed: "+model.playlist[model.config['item']]['file']});
			}else if(dat.code == "NetStream.Play.Start") {
				setStream();
			}
			clearInterval(timeout);
		}
		model.sendEvent(ModelEvent.META,dat);
	};


	/** Pause playback. **/
	public function pause():void {
		clearInterval(timeinterval);
		stream.pause();
		model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.PAUSED});
	};


	/** Resume playing. **/
	public function play():void {
		clearTimeout(timeout);
		clearInterval(timeinterval);
		stream.resume();
		model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.PLAYING});
		timeinterval = setInterval(timeHandler,100);
	};


	/** Change the smoothing mode. **/
	public function quality(qua:Boolean):void {
		if(qua == true) { 
			video.smoothing = true;
			video.deblocking = 3;
		} else { 
			video.smoothing = false;
			video.deblocking = 1;
		}
	};


	/** Change the smoothing mode. **/
	public function seek(pos:Number):void {
		clearTimeout(timeout);
		clearInterval(timeinterval);
		if(model.config['state'] == ModelStates.PAUSED) {
			stream.resume();
		} else {
			model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.PLAYING});
		}
		stream.seek(pos);
	};


	/** Set streaming object **/
	public function setStream():void {
		var url:String = getID(model.playlist[model.config['item']]['file']);
		stream = new NetStream(connection);
		stream.addEventListener(NetStatusEvent.NET_STATUS,statusHandler);
		stream.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
		stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR,metaHandler);
		stream.bufferTime = model.config['bufferlength'];
		stream.client = new NetClient(this);
		video.attachNetStream(stream);
		stream.soundTransform = transform;
		stream.play(url);
		var res:Responder = new Responder(streamlengthHandler);
		connection.call("getStreamLength",res,url);
		connection.call("checkBandwidth",null);
		clearInterval(timeinterval);
		timeinterval = setInterval(timeHandler,100);
	};


	/** Receive NetStream status updates. **/
	private function statusHandler(evt:NetStatusEvent):void {
		switch (evt.info.code) { 
			case 'NetConnection.Connect.Success':
				if(evt.info.secureToken != undefined) {
					connection.call("secureTokenResponse",null,TEA.decrypt(evt.info.secureToken,model.config['token']));
				}
				if(model.config['subscribe']) {
					timeout = setInterval(subscribe,2000,getID(model.playlist[model.config['item']]['file']));
				} else {
					setStream();
				}
				break;
			case  'NetStream.Seek.Notify':
				clearInterval(timeinterval);
				timeinterval = setInterval(timeHandler,100);
				break;
			case 'NetConnection.Connect.Rejected':
				if(evt.info.ex.code == 302) {
					model.playlist[model.config['item']]['streamer'] = evt.info.ex.redirect;
					connection.connect(model.playlist[model.config['item']]['streamer']);
					break;
				}
			case 'NetStream.Play.StreamNotFound':
			case 'NetConnection.Connect.Failed':
				model.sendEvent(ModelEvent.ERROR,{message:"Stream not found: "+model.playlist[model.config['item']]['file']});
				break;
			default:
				model.sendEvent(ModelEvent.META,{info:evt.info.code});
				break;
		}
	};


	/** Destroy the stream. **/
	public function stop():void {
		clearInterval(timeinterval);
		connection.close();
		if(stream) { stream.close(); }
		video.attachNetStream(null);
	};


	/** Get the streamlength returned from the connection. **/
	private function streamlengthHandler(len:Number):void {
		onData({type:'streamlength',duration:len});
	};


	/** Akamai & Limelight subscribes. **/
	private function subscribe(nme:String):void {
		connection.call("FCSubscribe",null,nme);
	};


	/** Interval for the position progress **/
	private function timeHandler():void {
		var bfr:Number = Math.round(stream.bufferLength/stream.bufferTime*100);
		var pos:Number = Math.round(stream.time*10)/10;
		var dur:Number = model.playlist[model.config['item']]['duration'];
		if(bfr < 95 && pos < Math.abs(dur-stream.bufferTime-1)) {
			model.sendEvent(ModelEvent.BUFFER,{percentage:bfr});
			if(model.config['state'] != ModelStates.BUFFERING) {
				connection.call("checkBandwidth",null);
				model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.BUFFERING});
			}
		} else if (model.config['state'] == ModelStates.BUFFERING) {
			model.sendEvent(ModelEvent.STATE,{newstate:ModelStates.PLAYING});
		}
		model.sendEvent(ModelEvent.TIME,{position:pos});
	};


	/** Set the volume level. **/
	public function volume(vol:Number):void {
		transform.volume = vol/100;
		if(stream) { 
			stream.soundTransform = transform;
		}
	};


};


}