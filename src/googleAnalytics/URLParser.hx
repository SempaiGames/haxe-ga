package googleAnalytics;

/**
 * ...
 * @author Federico Bricker
 */
import haxe.Http;

class URLParser
{
    // Publics
    public var url : String;
    public var source : String;
    public var protocol : String;
    public var authority : String;
    public var userInfo : String;
    public var user : String;
    public var password : String;
    public var host : String;
    public var port : String;
    public var relative : String;
    public var path : String;
    public var directory : String;
    public var file : String;
    public var query : String;
    public var anchor : String;
 
    // Privates
    inline static private var _parts : Array<String> = ["source","protocol","authority","userInfo","user","password","host","port","relative","path","directory","file","query","anchor"];
 
    public function new(url:String)
    {
        // Save for 'ron
        this.url = url;
 
        // The almighty regexp (courtesy of http://blog.stevenlevithan.com/archives/parseuri)
        var r : EReg = ~/^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/;
 
        // Match the regexp to the url
        r.match(url);
 
        // Use reflection to set each part
        for (i in 0..._parts.length)
        {
            Reflect.setField(this, _parts[i],  r.matched(i));
        }
    }
 
    public function toString() : String
    {
        var s : String = "For Url -> " + url + "\n";
        for (i in 0..._parts.length)
        {
            s += _parts[i] + ": " + Reflect.field(this, _parts[i]) + (i==_parts.length-1?"":"\n");
        }
        return s;
    }
 
    public static function parse(url:String) : URLParser
    {
        return new URLParser(url);
    }
}