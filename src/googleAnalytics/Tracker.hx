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
import googleAnalytics.internals.request.PageviewRequest;
import googleAnalytics.internals.request.EventRequest;
import googleAnalytics.internals.request.TransactionRequest;
import googleAnalytics.internals.request.ItemRequest;
import googleAnalytics.internals.request.SocialInteractionRequest;


class Tracker {
	
	/**
	 * Google Analytics client version on which this library is built upon,
	 * will be mapped to "utmwv" parameter.
	 * 
	 * This doesn't necessarily mean that all features of the corresponding
	 * ga.js version are implemented but rather that the requests comply
	 * with these of ga.js.
	 * 
	 * @link http://code.google.com/apis/analytics/docs/gaJS/changelog.html
	 * @const string
	 */
	
	static inline public var VERSION:String = '5.2.5'; // As of 25.02.2012
	
	
	/**
	 * The configuration to use for all tracker instances.
	 */
	private static var config : Config;
	
	/**
	 * Google Analytics account ID, e.g. "UA-1234567-8", will be mapped to
	 * "utmac" parameter
	 * @see internals.ParameterHolder::$utmac
	 */
	private var accountId : String;
	
	/**
	 * Host Name, e.g. "www.example.com", will be mapped to "utmhn" parameter
	 * @see internals.ParameterHolder::$utmhn
	 */
	private var domainName : String;
	
	/**
	 * Whether to generate a unique domain hash, default is true to be consistent
	 * with the GA Javascript Client
	 * @link http://code.google.com/apis/analytics/docs/tracking/gaTrackingSite.html#setAllowHash
	 * @see internals.request\Request::generateDomainHash()
	 */
	private var allowHash : Bool = true;
	
	private var customVariables : Array<CustomVariable>;
	
	private var campaign : Campaign;
	
	
	public function new(accountId:String, domainName:String, config:Config=null) {
		customVariables = new Array<CustomVariable>();
		setConfig(config!=null ? config : new Config());
		this.setAccountId(accountId);
		this.setDomainName(domainName);
	}
	
	public static function getConfig() : Config {
		return config;
	}	
	
	public static function setConfig(config:Config) {
		Tracker.config = config;
	}
	
	public function setAccountId(value:String) {
		var r = ~/^(UA|MO)-[0-9]*-[0-9]*$/;
		if(!r.match(value)) {
			_raiseError('"' + value + '" is not a valid Google Analytics account ID.', 'Tracker.setAccountId');
		}
		
		this.accountId = value;
	}
	
	public function getAccountId() : String {
		return this.accountId;
	}
	
	public function setDomainName(value:String) {
		this.domainName = value;
	}
	
	public function getDomainName() : String {
		return this.domainName;
	}
	
	public function setAllowHash(value:Bool) {
		this.allowHash = value;
	}
	
	public function getAllowHash() : Bool {
		return this.allowHash;
	}
	
	/**
	 * Equivalent of _setCustomVar() in GA Javascript client.
	 * @link http://code.google.com/apis/analytics/docs/tracking/gaTrackingCustomVariables.html
	 */
	public function addCustomVariable(customVariable:CustomVariable) {
		// Ensure that all required parameters are set
		customVariable.validate();
		customVariables[customVariable.getIndex()] = customVariable;
	}
	
	public function getCustomVariables() : Array<CustomVariable> {
		return this.customVariables;
	}
	
	/**
	 * Equivalent of _deleteCustomVar() in GA Javascript client.
	 */
	public function removeCustomVariable(index:Int) {
		customVariables.remove(customVariables[index]);
	}
	
	/**
	 * @param googleAnalytics.Campaign $campaign Isn't really optional, but can be set to null
	 */
	public function setCampaign(campaign:Campaign=null) {
		if(campaign!=null) {
			// Ensure that all required parameters are set
			campaign.validate();
		}
		
		this.campaign = campaign;
	}
	
	public function getCampaign() : Campaign {
		return this.campaign;
	}
	
	/**
	 * Equivalent of _trackPageview() in GA Javascript client.
	 * @link http://code.google.com/apis/analytics/docs/gaJS/gaJSApiBasicConfiguration.html#_gat.GA_Tracker_._trackPageview
	 */
	public function trackPageview(page:Page, session:Session, visitor:Visitor) {
		var request = new PageviewRequest(config);
		request.setPage(page);
		request.setSession(session);
		request.setVisitor(visitor);
		request.setTracker(this);
		request.fire();
	}
	
	/**
	 * Equivalent of _trackEvent() in GA Javascript client.
	 * @link http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEventTracking.html#_gat.GA_EventTracker_._trackEvent
	 */
	public function trackEvent(event:Event, session:Session, visitor:Visitor) {
		// Ensure that all required parameters are set
		event.validate();
		
		var request = new EventRequest(config);
		request.setEvent(event);
		request.setSession(session);
		request.setVisitor(visitor);
		request.setTracker(this);
		request.fire();
	}
	
	/**
	 * Combines _addTrans(), _addItem() (indirectly) and _trackTrans() of GA Javascript client.
	 * Although the naming of "_addTrans()" would suggest multiple possible transactions
	 * per request, there is just one allowed actually.
	 * @link http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEcommerce.html#_gat.GA_Tracker_._addTrans
	 * @link http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEcommerce.html#_gat.GA_Tracker_._addItem
	 * @link http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEcommerce.html#_gat.GA_Tracker_._trackTrans
	 */
	public function trackTransaction(transaction:Transaction, session:Session, visitor:Visitor) {
		// Ensure that all required parameters are set
		transaction.validate();
		
		var request = new TransactionRequest(config);
		request.setTransaction(transaction);
		request.setSession(session);
		request.setVisitor(visitor);
		request.setTracker(this);
		request.fire();
		
		// Every item gets a separate request,
		// see http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/v4/Tracker.as#312
		for(item in transaction.getItems()) {
			// Ensure that all required parameters are set
			item.validate();
			
			var request2 = new ItemRequest(config);
			request2.setItem(item);
			request2.setSession(session);
			request2.setVisitor(visitor);
			request2.setTracker(this);
			request2.fire();
		}
	}
	
	/**
	 * Equivalent of _trackSocial() in GA Javascript client.
	 * @link http://code.google.com/apis/analytics/docs/tracking/gaTrackingSocial.html#settingUp
	 */
	public function trackSocial(socialInteraction:SocialInteraction, page:Page, session:Session, visitor:Visitor) {
		var request = new SocialInteractionRequest(config);
		request.setSocialInteraction(socialInteraction);
		request.setPage(page);
		request.setSession(session);
		request.setVisitor(visitor);
		request.setTracker(this);
		request.fire();
	}
	
	/**
	 * For internal use only. Will trigger an error according to the current
	 * Config::$errorSeverity setting.
	 * @see Config::$errorSeverity
	 */
	public static function _raiseError(message:String, method:String) {
		message = method + '(): ' + message;
		var errorSeverity:Int = config!=null ? config.getErrorSeverity() : Config.ERROR_SEVERITY_SILENCE;
		switch(errorSeverity) {
			case Config.ERROR_SEVERITY_TRACE:    trace(message);
			case Config.ERROR_SEVERITY_EXCEPTIONS:	throw message;
			case Config.ERROR_SEVERITY_SILENCE:	// Do nothing
			default:
		}
	}
	
}
