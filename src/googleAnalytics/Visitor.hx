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

package googleAnalytics;

import googleAnalytics.internals.Util;

/**
 * You should serialize this object and store it in the user database to keep it
 * persistent for the same user permanently (similar to the "__umta" cookie of
 * the GA Javascript client).
 */
class Visitor {
	
	/**
	 * Unique user ID, will be part of the "__utma" cookie parameter
	 * @see internals.ParameterHolder::$__utma
	 */
	private var uniqueId : Int;
	
	/**
	 * Time of the very first visit of this user, will be part of the "__utma"
	 * cookie parameter
	 * @see internals.ParameterHolder::$__utma
	 */
	private var firstVisitTime : DateTime;
	
	/**
	 * Time of the previous visit of this user, will be part of the "__utma"
	 * cookie parameter
	 * @see internals.ParameterHolder::$__utma
	 * @see addSession
	 */
	private var previousVisitTime : DateTime;
	
	/**
	 * Time of the current visit of this user, will be part of the "__utma"
	 * cookie parameter
	 * @see internals.ParameterHolder::$__utma
	 * @see addSession
	 */
	private var currentVisitTime : DateTime;
	
	/**
	 * Amount of total visits by this user, will be part of the "__utma"
	 * cookie parameter
	 * @see internals.ParameterHolder::$__utma
	 */
	private var visitCount : Int;
	
	/**
	 * IP Address of the end user, e.g. "123.123.123.123", will be mapped to "utmip" parameter
	 * and "X-Forwarded-For" request header
	 * @see internals.ParameterHolder::$utmip
	 * @see internals.request\HttpRequest::$xForwardedFor
	 */
	private var ipAddress : String;
	
	/**
	 * User agent string of the end user, will be mapped to "User-Agent" request header
	 * @see internals.request\HttpRequest::$userAgent
	 */
	private var userAgent : String;
	
	/**
	 * Locale string (country part optional), e.g. "de-DE", will be mapped to "utmul" parameter
	 * @see internals.ParameterHolder::$utmul
	 */
	private var locale : String;
	
	/**
	 * Visitor's Flash version, e.g. "9.0 r28", will be maped to "utmfl" parameter
	 * @see internals.ParameterHolder::$utmfl
	 */
	private var flashVersion : String;
	
	/**
	 * Visitor's Java support, will be mapped to "utmje" parameter
	 * @see internals.ParameterHolder::$utmje
	 */
	private var javaEnabled : Bool;
	
	/**
	 * Visitor's screen color depth, e.g. 32, will be mapped to "utmsc" parameter
	 * @see internals.ParameterHolder::$utmsc
	 */
	private var screenColorDepth : String;
	
	/**
	 * Visitor's screen resolution, e.g. "1024x768", will be mapped to "utmsr" parameter
	 * @see internals.ParameterHolder::$utmsr
	 */
	private var screenResolution : String;
	
	
	/**
	 * Creates a new visitor without any previous visit information.
	 */
	public function new() {
		// ga.js sets all three timestamps to now for new visitors, so we do the same
		var now = new DateTime();
		this.uniqueId = 0;
		this.setFirstVisitTime(now);
		this.setPreviousVisitTime(now);
		this.setCurrentVisitTime(now);		
		this.setVisitCount(1);
	}
	
	/**
	 * Will extract information for the "uniqueId", "firstVisitTime", "previousVisitTime",
	 * "currentVisitTime" and "visitCount" properties from the given "__utma" cookie
	 * value.
	 * @see internals.ParameterHolder::$__utma
	 * @see internals.request\Request::buildCookieParameters()
	 * @return $this
	 */
	public function fromUtma(value:String) {
		var parts : Array<String> = value.split('.');
		if(parts.length != 6) {
			Tracker._raiseError('The given "__utma" cookie value is invalid.', 'Visitor.fromUtma');
			return this;
		}
		
		this.setUniqueId(Util.parseInt(parts[1],0));
		this.setFirstVisitTime(new DateTime(parts[2]));
		this.setPreviousVisitTime(new DateTime(parts[3]));
		this.setCurrentVisitTime(new DateTime(parts[4]));
		this.setVisitCount(Util.parseInt(parts[5],0));
		
		// Allow chaining
		return this;
	}
	
	/**
	 * Generates a hashed value from user-specific properties.
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/v4/Tracker.as#542
	 */
	private function generateHash() : Int {
		// TODO: Emulate orginal Google Analytics client library generation more closely
		return Util.generateHash(this.userAgent + this.screenResolution + this.screenColorDepth);
	}
	
	/**
	 * Generates a unique user ID from the current user-specific properties.
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/v4/Tracker.as#563
	 */
	private function generateUniqueId() : Int {
		// There seems to be an error in the gaforflash code, so we take the formula
		// from http://xahlee.org/js/google_analytics_tracker_2010-07-01_expanded.js line 711
		// instead ("&" instead of "*")
		return ((Util.generate32bitRandom() ^ this.generateHash()) & 0x7fffffff);
	}
	
	/**
	 * @see generateUniqueId
	 */
	public function setUniqueId(value:Int) {
		if(value < 0 || value > 0x7fffffff) {
			Tracker._raiseError('Visitor unique ID has to be a 32-bit integer between 0 and ' + 0x7fffffff + '.', 'Visitor.setUniqueId');
		}
		this.uniqueId = value;
	}
	
	/**
	 * Will be generated on first call (if not set already) to include as much
	 * user-specific information as possible.
	 */
	public function getUniqueId() : Int {
		if(this.uniqueId == 0) {
			this.uniqueId = this.generateUniqueId();
		}
		return this.uniqueId;
	}
	
	/**
	 * Updates the "previousVisitTime", "currentVisitTime" and "visitCount"
	 * fields based on the given session object.
	 */
	public function addSession(session:Session) {
		var startTime = session.getStartTime();
		if(startTime != this.currentVisitTime) {
			this.previousVisitTime = this.currentVisitTime;
			this.currentVisitTime  = startTime;
			++this.visitCount;
		}
	}
	
	/**
	 */
	public function setFirstVisitTime(value:DateTime) {
		this.firstVisitTime = value;
	}
	
	public function getFirstVisitTime() : DateTime {
		return this.firstVisitTime;
	}
	
	public function setPreviousVisitTime(value:DateTime) {
		this.previousVisitTime = value;
	}
	
	public function getPreviousVisitTime() : DateTime {
		return this.previousVisitTime;
	}

	public function setCurrentVisitTime(value:DateTime) {
		this.currentVisitTime = value;
	}
	
	public function getCurrentVisitTime() : DateTime {
		return this.currentVisitTime;
	}
	
	public function setVisitCount(value:Int) {
		this.visitCount = value;
	}
	
	public function getVisitCount() : Int {
		return this.visitCount;
	}
	
	public function setIpAddress(value:String) {
		this.ipAddress = value;
	}
	
	public function getIpAddress() : String {
		return this.ipAddress;
	}
	
	public function setUserAgent(value:String) {
		this.userAgent = value;
	}
	
	public function getUserAgent() : String {
		return this.userAgent;
	}
	
	public function setLocale(value:String) {
		this.locale = value;
	}
	
	public function getLocale() : String {
		return this.locale;
	}
	
	public function setFlashVersion(value:String) {
		this.flashVersion = value;
	}
	
	public function getFlashVersion() : String {
		return this.flashVersion;
	}
	
	public function setJavaEnabled(value:Bool) {
		this.javaEnabled = value;
	}
	
	public function getJavaEnabled() : Bool {
		return this.javaEnabled;
	}
	
	public function setScreenColorDepth(value:String) {
		this.screenColorDepth = value;
	}
	
	public function getScreenColorDepth() : String {
		return this.screenColorDepth;
	}
	
	public function setScreenResolution(value:String) {
		this.screenResolution = value;
	}
	
	public function getScreenResolution() : String {
		return this.screenResolution;
	}
	
}
