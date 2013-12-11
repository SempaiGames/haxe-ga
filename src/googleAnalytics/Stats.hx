package googleAnalytics;

#if (flash || openfl)
import flash.net.SharedObject;
import flash.system.Capabilities;
#end

class Stats {

	private static var tracker:Tracker=null;
	private static var cache:Map<String,GATrackObject>=null;
	private static var visitor:Visitor=null;
	private static var session:Session=null;
	#if native
	private static var working:Bool=false;
	private static var thread:cpp.vm.Thread;
	private static var requests:Array<GATrackObject>;
	#end
	
	private static var accountId:String=null;
	private static var domainName:String=null;
	
	public static function init(accountId:String,domainName:String){
		if(Stats.accountId!=null) return;
		Stats.accountId=accountId;
		Stats.domainName=domainName;
		tracker = new Tracker(accountId,domainName);
		cache = new Map<String,GATrackObject>();
		session = new Session();
		loadVisitor();
		#if native
		requests = new Array<GATrackObject>();
		thread = cpp.vm.Thread.create(onThreadMessage);
		#end
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
		#if !native
			cache.get(hash).track(tracker,visitor,session);
			Stats.persistVisitor();
		#else
			requests.push(cache.get(hash));
			if(!working) thread.sendMessage(null);
		#end
	}

	#if native
	private static function onThreadMessage(){
		while(true){
			cpp.vm.Thread.readMessage(true);
			working=true;
			while(requests.length>0){
				requests.shift().track(tracker,visitor,session);
				Sys.sleep(0.1);
			}
			Stats.persistVisitor();
			working=false;
		}	
	}
	#end
	
	private static function loadVisitor(){
		#if (flash || openfl)
		var ld:SharedObject=SharedObject.getLocal('gaVisitor');
		if(ld.data==null || ld.data.gaVisitor==null){
		#end
			visitor = new Visitor();
			#if ios
			visitor.setUserAgent('iOS');
			#elseif html5
			visitor.setUserAgent('html5');
			#elseif android
			visitor.setUserAgent('android');
			#elseif mac
			visitor.setUserAgent('OS X');
			#elseif tizen
			visitor.setUserAgent("tizen");
			#else
			visitor.setUserAgent('-not-set-');
			#end
			#if (flash || openfl)
			visitor.setScreenResolution(''+Capabilities.screenResolutionX+'x'+Capabilities.screenResolutionY);
			visitor.setLocale(Capabilities.language);
			#else
			visitor.setScreenResolution('1024x768');
			visitor.setLocale('en_US');
			#end
		#if (flash || openfl)
		}else{
			visitor=ld.data.gaVisitor;
		}
		#end

		visitor.getUniqueId();
		visitor.addSession(session);
		Stats.persistVisitor();
	}

	private static function persistVisitor(){
		#if (flash || openfl)
		var ld=SharedObject.getLocal('gaVisitor');
		ld.data.gaVisitor=visitor;
		try{
			ld.flush();
		}catch( e:Dynamic ){
			trace("No se puede salvar el Visitor de Google Analytics!");
		}
		#end
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
