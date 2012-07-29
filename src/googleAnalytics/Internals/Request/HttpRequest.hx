/**
 * Generic Server-Side Google Analytics Haxe Client
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License (LGPL) as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
 * 
 * Google Analytics is a registered trademark of Google Inc.
 * 
 * @link      https://github.com/fbricker/haxe-ga
 * 
 * @license   http://www.gnu.org/licenses/lgpl.html
 * @author    Federico Bricker <fbricker@gmail.com>
 * @copyright Copyright (c) 2012 SempaiGames (http://www.sempaigames.com)
 */

package  googleAnalytics.internals.request;

import googleAnalytics.Campaign;
import googleAnalytics.Config;
import googleAnalytics.internals.ParameterHolder;
import googleAnalytics.internals.Util;
import haxe.Http;

/**
 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/core/GIFRequest.as
 */

class HttpRequest {	
	
	/**
	 * Indicates the type of request, will be mapped to "utmt" parameter
	 * @see ParameterHolder::$utmt
	 */
	private var type : String;
	private var config : Config;
	private var userAgent : String;
	
	public function new(config:Config=null) {
		setConfig((config!=null) ? config : new Config());
	}
	
	public function getConfig() : Config {
		return this.config;
	}
	
	public function setConfig(config:Config) {
		this.config = config;
	}
	
	private function setUserAgent(value:String) {
		this.userAgent = value;
	}
	
	private function buildHttpHeadersAndData(http:Http) {
		var parameters = this.buildParameters();
		// Mimic Javascript's encodeURIComponent() encoding for the query
		// string just to be sure we are 100% consistent with GA's Javascript client
		var queryString : String = parameters.toQueryString();
		queryString = Util.convertToUriComponentEncoding(queryString);

		// Recent versions of ga.js use HTTP POST requests if the query string is too long		
		http.setHeader('Host', 'http://'+config.getEndPointHost());
		if(userAgent!=null && userAgent!='') {
			http.setHeader('User-Agent', userAgent);
		}
		http.setHeader('Content-Type', 'text/plain');
		http.setHeader('Content-Length', '' + queryString.length);
		http.setHeader('Connection', 'close');		
		http.url += '?' + queryString;
		//http.setPostData(queryString);
	}
	
	private function buildParameters() : ParameterHolder { return null; }
	
	/**
	 * This method should only be called directly or indirectly by fire(), but must
	 * remain public as it can be called by a closure function.
	 * Sends either a normal HTTP request with response or an asynchronous request
	 * to Google Analytics without waiting for the response. Will always return
	 * null in the latter case, or false if any connection problems arise.
	 * @return null|string
	 */
	public function send() {
		// Do not actually send the request if endpoint host is set to null
		if (config.getEndPointHost() == null) return;
		var request : Http = new Http('http://'+config.getEndPointHost()+config.getEndPointPath());
		buildHttpHeadersAndData(request);
		#if (neko||php||cpp||cs||java)
			request.cnxTimeout(config.getRequestTimeout());
		#elseif flash
			// we must load GoogleAnalytics using Flash API (like loading an image to avoid the check 
			// of a crossdomain.xml
		#end
		request.onError = onError;
		request.request(false);
	}
	
	public function onError (e:String) {
		trace('ERROR: '+e);
	}
		
}
