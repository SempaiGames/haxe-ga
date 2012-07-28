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

package googleAnalytics;

import googleAnalytics.internals.Util;
import DateTime;

/**
 * You should serialize this object and store it in e.g. the user database to keep it
 * persistent for the same user permanently (similar to the "__umtz" cookie of
 * the GA Javascript client).
 */
class Campaign {
	
	/**
	 * See self::TYPE_* constants, will be mapped to "__utmz" parameter.
	 * @see internals.ParameterHolder::$__utmz
	 */
	private var type : String;
	
	/**
	 * Time of the creation of this campaign, will be mapped to "__utmz" parameter.
	 * @see internals.ParameterHolder::$__utmz
	 */
	private var creationTime : DateTime;
	
	/**
	 * Response Count, will be mapped to "__utmz" parameter.
	 * Is also used to determine whether the campaign is new or repeated,
	 * which will be mapped to "utmcn" and "utmcr" parameters.
	 * @see internals.ParameterHolder::$__utmz
	 * @see internals.ParameterHolder::$utmcn
	 * @see internals.ParameterHolder::$utmcr
	 */
	private var responseCount : Int = 0;
	
	/**
	 * Campaign ID, a.k.a. "utm_id" query parameter for ga.js
	 * Will be mapped to "__utmz" parameter.
	 * @see internals.ParameterHolder::$__utmz
	 */
	private var id : Int;
	
	/**
	 * Source, a.k.a. "utm_source" query parameter for ga.js.
	 * Will be mapped to "utmcsr" key in "__utmz" parameter.
	 * @see internals.ParameterHolder::$__utmz
	 */
	private var source : String;
	
	/**
	 * Google AdWords Click ID, a.k.a. "gclid" query parameter for ga.js.
	 * Will be mapped to "utmgclid" key in "__utmz" parameter.
	 * @see internals.ParameterHolder::$__utmz
	 */
	private var gClickId : String;
	
	/**
	 * DoubleClick (?) Click ID. Will be mapped to "utmdclid" key in "__utmz" parameter.
	 * @see internals.ParameterHolder::$__utmz
	 */
	private var dClickId : String;
	
	/**
	 * Name, a.k.a. "utm_campaign" query parameter for ga.js.
	 * Will be mapped to "utmccn" key in "__utmz" parameter.
	 * @see internals.ParameterHolder::$__utmz
	 */
	private var name : String;
	
	/**
	 * Medium, a.k.a. "utm_medium" query parameter for ga.js.
	 * Will be mapped to "utmcmd" key in "__utmz" parameter.
	 * @see internals.ParameterHolder::$__utmz
	 */
	private var medium : String;
	
	/**
	 * Terms/Keywords, a.k.a. "utm_term" query parameter for ga.js.
	 * Will be mapped to "utmctr" key in "__utmz" parameter.
	 * @see internals.ParameterHolder::$__utmz
	 */
	private var term : String;
	
	/**
	 * Ad Content Description, a.k.a. "utm_content" query parameter for ga.js.
	 * Will be mapped to "utmcct" key in "__utmz" parameter.
	 * @see internals.ParameterHolder::$__utmz
	 */
	private var content : String;
	
	
	/**
	 * @const string
	 */
	static inline public var TYPE_DIRECT = 'direct';
	/**
	 * @const string
	 */
	static inline public var TYPE_ORGANIC = 'organic';
	/**
	 * @const string
	 */
	static inline public var TYPE_REFERRAL = 'referral';
	
	
	/**
	 * @see createFromReferrer
	 * @param type See TYPE_* constants
	 */
	function __construct(type:String) {
		if(!in_array(type, [ /*self.*/TYPE_DIRECT, /*self.*/TYPE_ORGANIC, /*self.*/TYPE_REFERRAL ])) {
			Tracker._raiseError('Campaign type has to be one of the Campaign::TYPE_* constant values.', __METHOD__);
		}
		
		this.type = type;
		
		switch(type) {
			// See http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/campaign/CampaignManager.as#375
			case /*self.*/TYPE_DIRECT:
				this.name   = '(direct)';
				this.source = '(direct)';
				this.medium = '(none)';
				break;
			// See http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/campaign/CampaignManager.as#340
			case /*self.*/TYPE_REFERRAL:
				this.name   = '(referral)';
				this.medium = 'referral';
				break;
			// See http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/campaign/CampaignManager.as#280
			case /*self.*/TYPE_ORGANIC:
				this.name   = '(organic)';
				this.medium = 'organic';
				break;
		}
		
		this.creationTime = new DateTime();
	}
	
	/**
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/campaign/CampaignManager.as#333
	 * @return googleAnalytics.Campaign
	 */
	public static function createFromReferrer(url:String) {
		instance = new static(/*self.*/TYPE_REFERRAL);
		urlInfo = parse_url(url);
		instance.source  = urlInfo.getset('host');
		instance.content = urlInfo.getset('path');
		
		return instance;
	}
	
	/**
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/campaign/CampaignTracker.as#153
	 */
	function validate() {
		// NOTE: gaforflash states that id and gClickId must also be specified,
		// but that doesn't seem to be correct
		if(!this.source) {
			Tracker._raiseError('Campaigns need to have at least the "source" attribute defined.', __METHOD__);
		}
	}
	
	/**
	 */
	function setType(type:String) {
		this.type = type;
	}
	
	/**
	 */
	function getType() : String {
		return this.type;
	}
	
	/**
	 */
	function setCreationTime(creationTime:DateTime) {
		this.creationTime = creationTime;
	}
	
	/**
	 */
	function getCreationTime() : DateTime {
		return this.creationTime;
	}
	
	/**
	 */
	function setResponseCount(responseCount) {
		this.responseCount = (int)responseCount;
	}
	
	/**
	 */
	function getResponseCount() : Int {
		return this.responseCount;
	}
	
	/**
	 */
	function increaseResponseCount(byAmount:Int=1) {
		this.responseCount += byAmount;
	}
	
	/**
	 */
	function setId(id:Int) {
		this.id = id;
	}
	
	/**
	 */
	function getId() : Int {
		return this.id;
	}
	
	/**
	 */
	function setSource(source:String) {
		this.source = source;
	}
	
	/**
	 */
	function getSource() : String {
		return this.source;
	}
	
	/**
	 */
	function setGClickId(gClickId:String) {
		this.gClickId = gClickId;
	}
	
	/**
	 */
	function getGClickId() : String {
		return this.gClickId;
	}
	
	/**
	 */
	function setDClickId(dClickId:String) {
		this.dClickId = dClickId;
	}
	
	/**
	 */
	function getDClickId() : String {
		return this.dClickId;
	}
	
	/**
	 */
	function setName(name:String) {
		this.name = name;
	}
	
	/**
	 */
	function getName() : String {
		return this.name;
	}
	
	/**
	 */
	function setMedium(medium:String) {
		this.medium = medium;
	}
	
	/**
	 */
	function getMedium() : String {
		return this.medium;
	}
	
	/**
	 */
	function setTerm(term:String) {
		this.term = term;
	}
	
	/**
	 */
	function getTerm() : String {
		return this.term;
	}
	
	/**
	 */
	function setContent(content:String) {
		this.content = content;
	}
	
	/**
	 */
	function getContent() : String {
		return this.content;
	}
	
}
