/**
 * Generic Server-Side Google Analytics PHP Client
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
 * @link      http://code.google.com/p/php-ga
 * 
 * @license   http://www.gnu.org/licenses/lgpl.html
 * @author    Thomas Bachem <tb@unitedprototype.com>
 * @copyright Copyright (c) 2010 United Prototype GmbH (http://unitedprototype.com)
 */

package GoogleAnalytics;

/**
 * Note: Doesn't necessarily have to be consistent across requests, as it doesn't
 * alter the actual tracking result.
 * 
 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/core/GIFRequest.as
 */
class Config {
	
	/**
	 * How strict should errors get handled? After all, we do just do some
	 * tracking stuff here, and errors shouldn't break an application's
	 * functionality in production.
	 * RECOMMENDATION: Exceptions during deveopment, warnings in production.
	 * Assign any value of the self::ERROR_SEVERITY_* constants.
	 * @see Tracker::_raiseError()
	 */
	private var errorSeverity : Int = /*self.*/ERROR_SEVERITY_EXCEPTIONS;
	
	/**
	 * Ignore all errors completely.
	 */
	static inline public var ERROR_SEVERITY_SILENCE    = 0;
	/**
	 * Trigger PHP errors with a E_USER_WARNING error level.
	 */
	static inline public var ERROR_SEVERITY_WARNINGS   = 1;
	/**
	 * Throw GoogleAnalytics.Exception exceptions.
	 */
	static inline public var ERROR_SEVERITY_EXCEPTIONS = 2;
	
	/**
	 * Whether to just queue all requests on HttpRequest::fire() and actually send
	 * them on PHP script shutdown after all other tasks are done.
	 * This has two advantages:
	 * 1) It effectively doesn't affect app performance
	 * 2) It can e.g. handle custom variables that were set after scheduling a request
	 * @see Internals.Request.HttpRequest::fire()
	 */
	private var sendOnShutdown : Bool = false;
	
	/**
	 * Whether to make asynchronous requests to GA without waiting for any
	 * response (speeds up doing requests).
	 * @see Internals.Request.HttpRequest::send()
	 */
	private var fireAndForget : Bool = false;
	
	/**
	 * Logging callback, registered via setLoggingCallback(). Will be fired
	 * whenever a request gets sent out and receives the full HTTP request
	 * as the first and the full HTTP response (or null if the "fireAndForget"
	 * option or simulation mode are used) as the second argument.
	 */
	private var loggingCallback : Closure;
	
	/**
	 * Seconds (float allowed) to wait until timeout when connecting to the
	 * Google analytics endpoint host
	 * @see Internals.Request.HttpRequest::send()
	 */
	private var requestTimeout : Float = 1;
	
	// FIXME: Add SSL support, https://ssl.google-analytics.com
	
	/**
	 * Google Analytics tracking request endpoint host. Can be set to null to
	 * silently simulate (and log) requests without actually sending them.
	 * @see Internals.Request.HttpRequest::send()
	 */
	private var endPointHost : String = 'www.google-analytics.com';
	
	/**
	 * Google Analytics tracking request endpoint path
	 * @see Internals.Request.HttpRequest::send()
	 */
	private var endPointPath : String = '/__utm.gif';
	
	/**
	 * Whether to anonymize IP addresses within Google Analytics by stripping
	 * the last IP address block, will be mapped to "aip" parameter
	 * @see Internals.ParameterHolder::$aip
	 * @link http://code.google.com/apis/analytics/docs/gaJS/gaJSApi_gat.html#_gat._anonymizeIp
	 */
	private var anonymizeIpAddresses : Bool = false;
	
	/**
	 * Defines a new sample set size (0-100) for Site Speed data collection.
	 * By default, a fixed 1% sampling of your site visitors make up the data pool from which
	 * the Site Speed metrics are derived.
	 * @see Page::$loadTime
	 * @link http://code.google.com/apis/analytics/docs/gaJS/gaJSApiBasicConfiguration.html#_gat.GA_Tracker_._setSiteSpeedSampleRate
	 */
	private var sitespeedSampleRate : Int = 1;
	
	
	/**
	 */
	public function __construct() {
		for(property => value in properties) {
			// PHP doesn't care about case in method names
			setterMethod = 'set' + property;
			
			if(Reflect.hasMethod(Type.resolveClass_getClass(this), setterMethod)) {
				this.setterMethod(value);
			} else {
				return Tracker._raiseError('There is no setting "' + property + '".', __METHOD__);
			}
		}
	}
	
	/**
	 * @return int See self::ERROR_SEVERITY_* constants
	 */
	public function getErrorSeverity() : Int {
		return this.errorSeverity;
	}
	
	/**
	 * @param errorSeverity See self::ERROR_SEVERITY_* constants
	 */
	public function setErrorSeverity(errorSeverity:Int) {
		this.errorSeverity = errorSeverity;
	}
	
	/**
	 */
	public function getSendOnShutdown() : Bool {
		return this.sendOnShutdown;
	}
	
	/**
	 */
	public function setSendOnShutdown(sendOnShutdown:Bool) {
		this.sendOnShutdown = sendOnShutdown;
	}
	
	/**
	 */
	public function getFireAndForget() : Bool {
		return this.fireAndForget;
	}
	
	/**
	 */
	public function setFireAndForget(fireAndForget:Bool) {
		this.fireAndForget = (bool)fireAndForget;
	}
	
	/**
	 * @return Closure|null
	 */
	public function getLoggingCallback() : Closure {
		return this.loggingCallback;
	}
	
	/**
	 */
	public function setLoggingCallback(callback:Closure) {
		this.loggingCallback = callback;
	}
	
	/**
	 */
	public function getRequestTimeout() : Float {
		return this.requestTimeout;
	}
	
	/**
	 */
	public function setRequestTimeout(requestTimeout:Float) {
		this.requestTimeout = (float)requestTimeout;
	}
	
	/**
	 * @return string|null
	 */
	public function getEndPointHost() : String {
		return this.endPointHost;
	}
	
	/**
	 * @param string|null $endPointHost
	 */
	public function setEndPointHost(endPointHost) {
		this.endPointHost = endPointHost;
	}
	
	/**
	 */
	public function getEndPointPath() : String {
		return this.endPointPath;
	}
	
	/**
	 */
	public function setEndPointPath(endPointPath:String) {
		this.endPointPath = endPointPath;
	}
	
	/**
	 */
	public function getAnonymizeIpAddresses() : Bool {
		return this.anonymizeIpAddresses;
	}
	
	/**
	 */
	public function setAnonymizeIpAddresses(anonymizeIpAddresses:Bool) {
		this.anonymizeIpAddresses = anonymizeIpAddresses;
	}
	
	/**
	 */
	public function getSitespeedSampleRate() : Int {
		return this.sitespeedSampleRate;
	}
	
	/**
	 */
	public function setSitespeedSampleRate(sitespeedSampleRate:Int) {
		if((int)sitespeedSampleRate != (float)sitespeedSampleRate || sitespeedSampleRate < 0 || sitespeedSampleRate > 100) {
			return Tracker._raiseError('For consistency with ga.js, sample rates must be specified as a number between 0 and 100.', __METHOD__);
		}
		
		this.sitespeedSampleRate = (int)sitespeedSampleRate;
	}

}
