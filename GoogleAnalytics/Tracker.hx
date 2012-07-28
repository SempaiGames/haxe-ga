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

import GoogleAnalytics.Internals.Util;
import GoogleAnalytics.Internals.Request.PageviewRequest;
import GoogleAnalytics.Internals.Request.EventRequest;
import GoogleAnalytics.Internals.Request.TransactionRequest;
import GoogleAnalytics.Internals.Request.ItemRequest;
import GoogleAnalytics.Internals.Request.SocialInteractionRequest;


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
	static inline public var VERSION = '5.2.5'; // As of 25.02.2012
	
	
	/**
	 * The configuration to use for all tracker instances.
	 * @var GoogleAnalytics.Config
	 */
	private static var config : GoogleAnalytics;
	
	/**
	 * Google Analytics account ID, e.g. "UA-1234567-8", will be mapped to
	 * "utmac" parameter
	 * @see Internals.ParameterHolder::$utmac
	 */
	private var accountId : String;
	
	/**
	 * Host Name, e.g. "www.example.com", will be mapped to "utmhn" parameter
	 * @see Internals.ParameterHolder::$utmhn
	 */
	private var domainName : String;
	
	/**
	 * Whether to generate a unique domain hash, default is true to be consistent
	 * with the GA Javascript Client
	 * @link http://code.google.com/apis/analytics/docs/tracking/gaTrackingSite.html#setAllowHash
	 * @see Internals.Request\Request::generateDomainHash()
	 */
	private var allowHash : Bool = true;
	
	/**
	 */
	private var customVariables : NativeArray = [];
	
	/**
	 * @var GoogleAnalytics.Campaign
	 */
	private var campaign : GoogleAnalytics;
	
	
	/**
	 * @param GoogleAnalytics.Config $config
	 */
	public function __construct(accountId:String, domainName:String, config:Config=null) {
		static.setConfig(config ? config : new Config());
		
		this.setAccountId(accountId);
		this.setDomainName(domainName);
	}
	
	/**
	 * @return GoogleAnalytics.Config
	 */
	public static function getConfig() : GoogleAnalytics {
		return static.var config;
	}	
	
	/**
	 * @param GoogleAnalytics.Config $value
	 */
	public static function setConfig(value:Config) {
		static.var config = value;
	}
	
	/**
	 */
	public function setAccountId(value:String) {
		if(!preg_match('/^(UA|MO)-[0-9]*-[0-9]*$/', value)) {
			static._raiseError('"' + value + '" is not a valid Google Analytics account ID.', __METHOD__);
		}
		
		this.accountId = value;
	}
	
	/**
	 */
	public function getAccountId() : String {
		return this.accountId;
	}
	
	/**
	 */
	public function setDomainName(value:String) {
		this.domainName = value;
	}
	
	/**
	 */
	public function getDomainName() : String {
		return this.domainName;
	}
	
	/**
	 */
	public function setAllowHash(value:Bool) {
		this.allowHash = (bool)value;
	}
	
	/**
	 */
	public function getAllowHash() : Bool {
		return this.allowHash;
	}
	
	/**
	 * Equivalent of _setCustomVar() in GA Javascript client.
	 * @link http://code.google.com/apis/analytics/docs/tracking/gaTrackingCustomVariables.html
	 * @param GoogleAnalytics.CustomVariable $customVariable
	 */
	public function addCustomVariable(customVariable:CustomVariable) {
		// Ensure that all required parameters are set
		customVariable.validate();
		
		index = customVariable.getIndex();
		this.customVariables[index] = customVariable;
	}
	
	/**
	 * @return GoogleAnalytics.CustomVariable[]
	 */
	public function getCustomVariables() : GoogleAnalytics {
		return this.customVariables;
	}
	
	/**
	 * Equivalent of _deleteCustomVar() in GA Javascript client.
	 */
	public function removeCustomVariable(index:Int) {
		unset(this.customVariables[index]);
	}
	
	/**
	 * @param GoogleAnalytics.Campaign $campaign Isn't really optional, but can be set to null
	 */
	public function setCampaign(campaign:Campaign=null) {
		if(campaign) {
			// Ensure that all required parameters are set
			campaign.validate();
		}
		
		this.campaign = campaign;
	}
	
	/**
	 * @return GoogleAnalytics.Campaign|null
	 */
	public function getCampaign() : GoogleAnalytics {
		return this.campaign;
	}
	
	/**
	 * Equivalent of _trackPageview() in GA Javascript client.
	 * @link http://code.google.com/apis/analytics/docs/gaJS/gaJSApiBasicConfiguration.html#_gat.GA_Tracker_._trackPageview
	 * @param GoogleAnalytics.Page $page
	 * @param GoogleAnalytics.Session $session
	 * @param GoogleAnalytics.Visitor $visitor
	 */
	public function trackPageview(page:Page, session:Session, visitor:Visitor) {
		request = new PageviewRequest(static.var config);
		request.setPage(page);
		request.setSession(session);
		request.setVisitor(visitor);
		request.setTracker(this);
		request.fire();
	}
	
	/**
	 * Equivalent of _trackEvent() in GA Javascript client.
	 * @link http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEventTracking.html#_gat.GA_EventTracker_._trackEvent
	 * @param GoogleAnalytics.Event $event
	 * @param GoogleAnalytics.Session $session
	 * @param GoogleAnalytics.Visitor $visitor
	 */
	public function trackEvent(event:Event, session:Session, visitor:Visitor) {
		// Ensure that all required parameters are set
		event.validate();
		
		request = new EventRequest(static.var config);
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
	 * @param GoogleAnalytics.Transaction $transaction
	 * @param GoogleAnalytics.Session $session
	 * @param GoogleAnalytics.Visitor $visitor
	 */
	public function trackTransaction(transaction:Transaction, session:Session, visitor:Visitor) {
		// Ensure that all required parameters are set
		transaction.validate();
		
		request = new TransactionRequest(static.var config);
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
			
			request = new ItemRequest(static.var config);
			request.setItem(item);
			request.setSession(session);
			request.setVisitor(visitor);
			request.setTracker(this);
			request.fire();
		}
	}
	
	/**
	 * Equivalent of _trackSocial() in GA Javascript client.
	 * @link http://code.google.com/apis/analytics/docs/tracking/gaTrackingSocial.html#settingUp
	 * @param GoogleAnalytics.SocialInteraction $socialInteraction
	 * @param GoogleAnalytics.Page $page
	 * @param GoogleAnalytics.Session $session
	 * @param GoogleAnalytics.Visitor $visitor
	 */
	public function trackSocial(socialInteraction:SocialInteraction, page:Page, session:Session, visitor:Visitor) {
		request = new SocialInteractionRequest(static.var config);
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
		method = method.replace(__NAMESPACE__ + '\\', '');
		message = method + '(): ' + message;
		
		errorSeverity = isset(static.var config) ? static.var config.getErrorSeverity() : Config.ERROR_SEVERITY_EXCEPTIONS;
		
		switch(errorSeverity) {
			case Config.ERROR_SEVERITY_SILENCE:
				// Do nothing
				break;
			case Config.ERROR_SEVERITY_WARNINGS:
				trigger_error(message, E_USER_WARNING);
				break;
			case Config.ERROR_SEVERITY_EXCEPTIONS:
				throw new Exception(message);
				break;
		}
	}
	
}
