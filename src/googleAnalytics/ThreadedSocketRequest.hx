package googleAnalytics;

#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end

class ThreadedSocketRequest {

	#if ( cpp || neko )
	
	private static var thread:Thread;
	private static var initted:Bool=false;	
	
	public static function init() {
		if(initted) return;
		initted=true;
		thread = Thread.create(onThreadMessage);
	}

	private static function onThreadMessage(){
		var s:sys.net.Socket = null;
		var msg:String = null;
		while(true){
			try {
				msg = Thread.readMessage(true);
				if ( msg == null ) continue;
				var t1:Float = Sys.time();
				s = new sys.net.Socket();
				s.setTimeout(2);
				s.connect(new sys.net.Host("www.google-analytics.com"),80);
				s.write(msg);
				s.input.readLine();
				var t2:Float = Sys.time();
				// trace(Math.round((t2-t1)*1000)+"ms ");				
			} catch(e:Dynamic) {
				// trace("Exception: "+e);
			}

			try {
				if(s!=null){
					s.close();
					s=null;
				}
			} catch(e:Dynamic) {
				// trace("Closing Exception: "+e);
			}
		}	
	}

	#end

	public static function request(url:String, userAgent:String){
		#if ( cpp || neko )
			init();
			thread.sendMessage("GET "+url+" HTTP/1.1\nUser-Agent: "+userAgent+"\n\n");
		#end
	}

}
