package ;

import flash.display.MovieClip;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import googleAnalytics.Config;

/**
 * ...
 * @author Federico Bricker
 */

class Main 
{
	
	public static function main() 
	{
		//var stage = Lib.current.stage;
		//stage.scaleMode = StageScaleMode.NO_SCALE;
		//stage.align = StageAlign.TOP_LEFT;
		trace('hola mundo');
		var pepe = new Config ();
//		var google = new googleAnalytics.Tracker('UA-12345678-9','example.com');
		// entry point
	}
	
	public var pepe:String;
	public var cacho:Int;
	

	function new() {
		pepe = 'PEPE VALE HOLA! =]';
		cacho = 33;
	}
	
	function toArray() : Hash<String> {
		var hash = new Hash<String>();
		var property:String;
		for (property in Type.getInstanceFields(Main)) {
			if (property.charAt(0) != '_' && !Reflect.isFunction(Reflect.field(this,property))) {
				hash.set(property, Reflect.field(this, property));
			}
		}
		return hash;
	}
	
}