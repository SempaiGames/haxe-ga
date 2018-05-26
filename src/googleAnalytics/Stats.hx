package googleAnalytics;

#if (flash || openfl)
import extension.locale.Locale;
import flash.net.SharedObject;
import flash.system.Capabilities;
import flash.Lib;
import haxe.Unserializer;
import haxe.Serializer;
#end
#if js
import extension.locale.Locale;
import haxe.Unserializer;
import haxe.Serializer;
#end

class Stats {

	private static var accountId:String=null;
	private static var cache:Map<String,GATrackObject>=null;
	private static var domainName:String=null;
	private static var paused:Bool=false;
	private static var session:Session=null;
	private static var tracker:Tracker=null;
	private static var visitor:Visitor=null;

	public static function init(accountId:String,domainName:String,useSSL:Bool=false){
		if(Stats.accountId!=null) return;
		Stats.accountId=accountId;
		Stats.domainName=domainName;
		tracker = new Tracker(accountId,domainName,new Config(useSSL));
		cache = new Map<String,GATrackObject>();
		session = new Session();
		loadVisitor();
	}

	public static function trackPageview(path:String,title:String=null){
		var hash='page:'+path;
		if(!cache.exists(hash)){
			var p=new Page(path);
			if(title!=null) p.setTitle(title);
			cache.set(hash,new GATrackObject(p,null));
		}
		Stats.track(hash);
	}

	public static function trackEvent(category:String,event:String,label:String,value:Int=0){
		var hash='event:'+category+'/'+event+'/'+label+':'+value;
		if(!cache.exists(hash)){
			cache.set(hash,new GATrackObject(null,new Event(category,event,label,value)));
		}
		Stats.track(hash);
	}

	private static function track(hash:String){
		if(paused) return;
		cache.get(hash).track(tracker,visitor,session);
		Stats.persistVisitor();
	}

	public static function pause() {
		paused = true;
	}

	public static function resume() {
		paused = false;
	}

	private static function loadVisitor(){
		var version:String=" [haxe]";
		visitor = new Visitor();
		#if (flash || openfl)
		var ld:SharedObject=SharedObject.getLocal('ga-visitor');
		if(ld.data!=null && ld.data.gaVisitor!=null){
			try{
				visitor=Unserializer.run(ld.data.gaVisitor);
			}catch(e:Dynamic){
				visitor = new Visitor();
			}
		}
		#end

		#if js
			try{
				visitor=Unserializer.run(js.Cookie.get('MUSES_TRACKING'));
			}catch(e:Dynamic){
				visitor = new Visitor();
			}
		#end

		#if (openfl && !flash && !html5)
			#if (!openfl_legacy)
			version+="/" + Lib.application.config.packageName + "." + Lib.application.config.version;
			#else
			version+="/" + Lib.packageName + "." + Lib.version;
			#end
		#end

		#if ios
		visitor.setUserAgent('iOS'+version);
		#elseif android
		visitor.setUserAgent('Android'+version);
		#elseif mac
		visitor.setUserAgent('OS-X'+version);
		#elseif tizen
		visitor.setUserAgent("Tizen"+version);
		#elseif blackberry
		visitor.setUserAgent("BlackBerry"+version);
		#elseif windows
		visitor.setUserAgent("Windows"+version);
		#elseif linux
		visitor.setUserAgent("Linux"+version);
		#elseif js
		visitor.setUserAgent("JS"+version);
		#else
		visitor.setUserAgent('-not-set-'+version);
		#end

		#if (flash || openfl)
		visitor.setScreenResolution(''+Capabilities.screenResolutionX+'x'+Capabilities.screenResolutionY);
		visitor.setLocale(Locale.getLangCode());
		#elseif js
		if(js.Browser.window != null){
			visitor.setScreenResolution(js.Browser.window.screen.availWidth+'x'+js.Browser.window.screen.availHeight);
			visitor.setLocale(js.Browser.navigator.language);
			visitor.setUserAgent(js.Browser.navigator.userAgent);
		}else{
			visitor.setScreenResolution('1024x768');
			visitor.setLocale(Locale.getLangCode());
		}
		#else
		visitor.setScreenResolution('1024x768');
		visitor.setLocale('en_US');
		#end

		visitor.getUniqueId();
		visitor.addSession(session);
		Stats.persistVisitor();
	}

	private static function persistVisitor(){
		try{
		#if (flash || openfl)
			var ld=SharedObject.getLocal('ga-visitor');
			var old_USE_CACHE = Serializer.USE_CACHE;
			Serializer.USE_CACHE = true;
			ld.data.gaVisitor = Serializer.run(visitor);
			Serializer.USE_CACHE = old_USE_CACHE;
			ld.flush();
		#elseif js
			var old_USE_CACHE = Serializer.USE_CACHE;
			Serializer.USE_CACHE = true;
			var data = Serializer.run(visitor);
			Serializer.USE_CACHE = old_USE_CACHE;
			js.Cookie.set('MUSES_TRACKING',data,3600*24*365);
		#end
		}catch( e:Dynamic ){
			trace("Error while saving Google Analytics Visitor!");
		}
	}

}

private class GATrackObject {

	private var event:Event;
	private var page:Page;

	public function new(page:Page,event:Event) {
		this.page=page;
		this.event=event;
	}

	public function track(tracker:Tracker,visitor:Visitor,session:Session){
		if(this.page!=null){
			tracker.trackPageview(page,session,visitor);
		}
		if(this.event!=null){
			tracker.trackEvent(event,session,visitor);
		}
	}
}
