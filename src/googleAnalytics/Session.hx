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
 * You should serialize this object and store it in the user session to keep it
 * persistent between requests (similar to the "__umtb" cookie of
 * the GA Javascript client).
 */
class Session {
	
	/**
	 * A unique per-session ID, will be mapped to "utmhid" parameter
	 * @see internals.ParameterHolder::$utmhid
	 */
	private var sessionId : Int;
	
	/**
	 * The amount of pageviews that were tracked within this session so far,
	 * will be part of the "__utmb" cookie parameter.
	 * Will get incremented automatically upon each request.
	 * @see internals.ParameterHolder::$__utmb
	 * @see internals.request\Request::buildHttpRequest()
	 */
	private var trackCount : Int;
	
	/**
	 * Timestamp of the start of this new session, will be part of the "__utmb"
	 * cookie parameter
	 * @see internals.ParameterHolder::$__utmb
	 */
	private var startTime : DateTime;
	
	
	public function new() : Void {
		this.setSessionId(this.generateSessionId());
		this.setTrackCount(0);
		this.setStartTime(new DateTime());
	}
	
	/**
	 * Will extract information for the "trackCount" and "startTime"
	 * properties from the given "__utmb" cookie value.
	 * @see internals.ParameterHolder::$__utmb
	 * @see internals.request\Request::buildCookieParameters()
	 * @return $this
	 */
	public function fromUtmb(value:String) {
		var parts : Array<String> = value.split('.');
		if(parts.length != 4) {
			Tracker._raiseError('The given "__utmb" cookie value is invalid.', 'Session.fromUtmb');
			return this;
		}
		
		this.setTrackCount(Util.parseInt(parts[1],0));
		this.setStartTime(new DateTime(parts[3]));
		
		// Allow chaining
		return this;
	}
	
	/**
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/core/DocumentInfo.as#52
	 */
	private function generateSessionId() : Int {
		// TODO: Integrate AdSense support
		return Util.generate32bitRandom();
	}
	
	public function getSessionId() : Int {
		return this.sessionId;
	}
	
	public function setSessionId(sessionId:Int) {
		this.sessionId = sessionId;
	}
	
	public function getTrackCount() : Int {
		return this.trackCount;
	}
	
	public function setTrackCount(trackCount:Int) {
		this.trackCount = trackCount;
	}
	
	public function increaseTrackCount(byAmount:Int=1) {
		this.trackCount += byAmount;
	}
	
	public function getStartTime() : DateTime {
		return this.startTime;
	}
	
	public function setStartTime(startTime:DateTime) {
		this.startTime = startTime;
	}
}
