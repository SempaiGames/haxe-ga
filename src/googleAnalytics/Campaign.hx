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

import googleAnalytics.internals.ParameterHolder;
import googleAnalytics.internals.Util;

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
	public function new(type:String) {
		
		if( type != TYPE_DIRECT && type != TYPE_ORGANIC && type != TYPE_REFERRAL ) {
			Tracker._raiseError('Campaign type has to be one of the Campaign::TYPE_* constant values.', 'Campaign.new');
		}
		
		this.type = type;
		
		switch(type) {
			// See http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/campaign/CampaignManager.as#375
			case /*self.*/TYPE_DIRECT:
				this.name   = '(direct)';
				this.source = '(direct)';
				this.medium = '(none)';
			// See http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/campaign/CampaignManager.as#340
			case /*self.*/TYPE_REFERRAL:
				this.name   = '(referral)';
				this.medium = 'referral';
			// See http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/campaign/CampaignManager.as#280
			case /*self.*/TYPE_ORGANIC:
				this.name   = '(organic)';
				this.medium = 'organic';
		}
		
		this.creationTime = new DateTime();
	}
	
	/**
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/campaign/CampaignManager.as#333
	 * @return googleAnalytics.Campaign
	 */
	public static function createFromReferrer(url:String) {
		var instance = new Campaign(TYPE_REFERRAL);

		var urlInfo = new URLParser(url);
		instance.source  = urlInfo.host;
		instance.content = urlInfo.path;
		return instance;
	}
	
	/**
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/campaign/CampaignTracker.as#153
	 */
	public function validate() {
		// NOTE: gaforflash states that id and gClickId must also be specified,
		// but that doesn't seem to be correct
		if(this.source == null) {
			Tracker._raiseError('Campaigns need to have at least the "source" attribute defined.', 'Campaign.validate');
		}
	}
	
	public function setType(type:String) {
		this.type = type;
	}

	public function getType() : String {
		return this.type;
	}
	
	public function setCreationTime(creationTime:DateTime) {
		this.creationTime = creationTime;
	}
	
	public function getCreationTime() : DateTime {
		return this.creationTime;
	}
	
	public function setResponseCount(responseCount:Int) {
		this.responseCount = responseCount;
	}
	
	public function getResponseCount() : Int {
		return this.responseCount;
	}
	
	public function increaseResponseCount(byAmount:Int=1) {
		this.responseCount += byAmount;
	}
	
	public function setId(id:Int) {
		this.id = id;
	}
	
	public function getId() : Int {
		return this.id;
	}
	
	public function setSource(source:String) {
		this.source = source;
	}
	
	public function getSource() : String {
		return this.source;
	}
	
	public function setGClickId(gClickId:String) {
		this.gClickId = gClickId;
	}
	
	public function getGClickId() : String {
		return this.gClickId;
	}
	
	public function setDClickId(dClickId:String) {
		this.dClickId = dClickId;
	}
	
	public function getDClickId() : String {
		return this.dClickId;
	}
	
	public function setName(name:String) {
		this.name = name;
	}
	
	public function getName() : String {
		return this.name;
	}
	
	public function setMedium(medium:String) {
		this.medium = medium;
	}
	
	public function getMedium() : String {
		return this.medium;
	}
	
	public function setTerm(term:String) {
		this.term = term;
	}
	
	public function getTerm() : String {
		return this.term;
	}
	
	public function setContent(content:String) {
		this.content = content;
	}
	
	public function getContent() : String {
		return this.content;
	}
	
}
