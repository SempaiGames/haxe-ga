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

import googleAnalytics.Config;
import googleAnalytics.Tracker;
import googleAnalytics.Visitor;
import googleAnalytics.Session;
import googleAnalytics.CustomVariable;
import haxe.Http;

import googleAnalytics.internals.ParameterHolder;
import googleAnalytics.internals.Util;
import googleAnalytics.internals.X10;


class Request {

	/**
	 * Indicates the type of request, will be mapped to "utmt" parameter
	 * @see ParameterHolder::$utmt
	 */
	private var type : String;
	private var config : Config;
	private var userAgent : String;
	private var tracker : Tracker;
	private var visitor : Visitor;
	private var session : Session;
		
	static inline public var TYPE_PAGE           = null;
	static inline public var TYPE_EVENT          = 'event';
	static inline public var TYPE_TRANSACTION    = 'tran';
	static inline public var TYPE_ITEM           = 'item';
	static inline public var TYPE_SOCIAL         = 'social';

	/**
	 * This type of request is deprecated in favor of encoding custom variables
	 * within the "utme" parameter, but we include it here for completeness
	 * 
	 * @see ParameterHolder::$__utmv
	 * @link http://code.google.com/apis/analytics/docs/gaJS/gaJSApiBasicConfiguration.html#_gat.GA_Tracker_._setVar
	 * @deprecated
	 */
	static inline public var TYPE_CUSTOMVARIABLE = 'var';
	static inline public var X10_CUSTOMVAR_NAME_PROJECT_ID  = '8';
	static inline public var X10_CUSTOMVAR_VALUE_PROJECT_ID = '9';
	static inline public var X10_CUSTOMVAR_SCOPE_PROJECT_ID = '11';
	static inline public var CAMPAIGN_DELIMITER = '|';

	
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
		
	public function getTracker() : Tracker {
		return this.tracker;
	}
	
	public function setTracker(tracker:Tracker) {
		this.tracker = tracker;
	}
	
	public function getVisitor() : Visitor {
		return this.visitor;
	}
	
	public function setVisitor(visitor:Visitor) {
		this.visitor = visitor;
	}
	
	public function getSession() : Session {
		return this.session;
	}
	
	public function setSession(session:Session) {
		this.session = session;
	}

	public function onError (e:String) {
		trace('ERROR: '+e);
	}

	private function increaseTrackCount() {
		// Increment session track counter for each request
		this.session.increaseTrackCount();
		// See http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/v4/Configuration.as?r=237#48
		// and http://code.google.com/intl/de-DE/apis/analytics/docs/tracking/eventTrackerGuide.html#implementationConsiderations
		if(this.session.getTrackCount() > 500) {
			Tracker._raiseError('Google Analytics does not guarantee to process more than 500 requests per session.', 'Request.buildHttpRequest');
		}
		if(this.tracker.getCampaign()!=null) {
			this.tracker.getCampaign().increaseResponseCount();
		}
	}
	
	
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
		var parameters = this.buildParameters();
		if ( visitor != null ) {
			setUserAgent( visitor.getUserAgent() );
			parameters.utmvid = visitor.getUniqueId();
		}
		var queryString : String = Util.convertToUriComponentEncoding(parameters.toQueryString());
		var url : String = 'http://' + config.getEndPointHost() + config.getEndPointPath() + '?' + queryString;
		increaseTrackCount();
		#if js
			// well, in javascript ocurrs the same thing with CORS, so no request, just load an image.
			var img:js.html.Image = new js.html.Image();
			img.src = url;
		#elseif (flash || openfl)
			// we must load GoogleAnalytics using Flash API (like loading an image to avoid the check 
			// of a crossdomain.xml
			#if flash
			var l : flash.display.Loader = new flash.display.Loader();
			#elseif openfl
			var l : flash.net.URLLoader = new flash.net.URLLoader();
			#end
			var urlRequest : flash.net.URLRequest=new flash.net.URLRequest();
			urlRequest.url=url;
			l.load(urlRequest);
		#else
			var request : Http = new Http(url);
			if(userAgent!=null && userAgent!='') {
				request.setHeader('User-Agent', userAgent);
			}
			request.setHeader('Host', 'http://'+config.getEndPointHost());
			request.setHeader('Connection', 'close');		
			#if (neko||php||cpp||cs||java)
				request.cnxTimeout=config.getRequestTimeout();
			#end
			request.onError = onError;
			request.request(false);
		#end
	}
	
	/**
	 * Indicates the type of request, will be mapped to "utmt" parameter
	 * 
	 * @see ParameterHolder::$utmt
	 * @return string See Request::TYPE_* constants
	 */
	private function getType() : String { return null; }
	
	private function buildParameters() : ParameterHolder {
		var p:ParameterHolder = new ParameterHolder();

		p.utmac = this.tracker.getAccountId();
		p.utmhn = this.tracker.getDomainName();
		
		p.utmt = ''+this.getType();
		p.utmn = Util.generate32bitRandom();
		
		// The "utmip" parameter is only relevant if a mobile analytics
		// ID (MO-123456-7) was given,
		// see https://github.com/fbricker/haxe-ga/issues/detail?id=9
		p.utmip = this.visitor.getIpAddress();
		
		p.utmhid = this.session.getSessionId();
		p.utms   = this.session.getTrackCount();
		
		p = this.buildVisitorParameters(p);
		p = this.buildCustomVariablesParameter(p);
		p = this.buildCampaignParameters(p);
		p = this.buildCookieParameters(p);

		return p;
	}
	
	private function buildVisitorParameters(p:ParameterHolder) : ParameterHolder {
		// Ensure correct locale format, see https://developer.mozilla.org/en/navigator.language
		if(visitor.getLocale()!=null){
			p.utmul = StringTools.replace(visitor.getLocale(), '_', '-').toLowerCase();
		}
		if(this.visitor.getFlashVersion() != null) {
			p.utmfl = this.visitor.getFlashVersion();
		}
		p.utmje = this.visitor.getJavaEnabled()?'1':'0';
		if(this.visitor.getScreenColorDepth() != null) {
			p.utmsc = this.visitor.getScreenColorDepth() + '-bit';
		}
		p.utmsr = this.visitor.getScreenResolution();		
		return p;
	}
	
	/**
	 * @link http://xahlee.org/js/google_analytics_tracker_2010-07-01_expanded.js line 575
\	 */
	private function buildCustomVariablesParameter(p:ParameterHolder) : ParameterHolder {
		var customVars = this.tracker.getCustomVariables();
		if (customVars == null) return p;
		if(customVars.length > 5) {
			// See http://code.google.com/intl/de-DE/apis/analytics/docs/tracking/gaTrackingCustomVariables.html#usage
			Tracker._raiseError('The sum of all custom variables cannot exceed 5 in any given request.', 'Request.buildCustomVariablesParameter');
		}
		
		var x10:X10 = new X10();
		var name;
		var value;
		
		x10.clearKey(/*self.*/X10_CUSTOMVAR_NAME_PROJECT_ID);
		x10.clearKey(/*self.*/X10_CUSTOMVAR_VALUE_PROJECT_ID);
		x10.clearKey(/*self.*/X10_CUSTOMVAR_SCOPE_PROJECT_ID);
		
		for(customVar in customVars) {
			// Name and value get encoded here,
			// see http://xahlee.org/js/google_analytics_tracker_2010-07-01_expanded.js line 563
			name  = Util.encodeUriComponent(customVar.getName());
			value = Util.encodeUriComponent(customVar.getValue());
			
			x10.setKey(/*self.*/X10_CUSTOMVAR_NAME_PROJECT_ID, customVar.getIndex(), name);
			x10.setKey(/*self.*/X10_CUSTOMVAR_VALUE_PROJECT_ID, customVar.getIndex(), value);
			if(customVar.getScope() != CustomVariable.SCOPE_PAGE) {
				x10.setKey(/*self.*/X10_CUSTOMVAR_SCOPE_PROJECT_ID, customVar.getIndex(), customVar.getScope());
			}
		}
		
		var eventFragment:String = x10.renderUrlString();
		// Append only if not null to avoid "null" in event fragments
		if (eventFragment != null) {
			if(p.utme == null) p.utme = eventFragment;
			else p.utme += eventFragment;
		}
		return p;
	}
	
	/**
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/core/GIFRequest.as#123
	 */
	private function buildCookieParameters(p:ParameterHolder) : ParameterHolder {
		var domainHash = this.generateDomainHash();
		p.__utma  = domainHash + '.';
		p.__utma += this.visitor.getUniqueId() + '.';
		p.__utma += this.visitor.getFirstVisitTime().toString() + '.';
		p.__utma += this.visitor.getPreviousVisitTime().toString() + '.';
		p.__utma += this.visitor.getCurrentVisitTime().toString() + '.';
		p.__utma += this.visitor.getVisitCount();
		
		p.__utmb  = domainHash + '.';
		p.__utmb += this.session.getTrackCount() + '.';
		// FIXME: What does "token" mean? I only encountered a value of 10 in my tests.
		p.__utmb += 10 + '.';
		p.__utmb += this.session.getStartTime().toString();
		
		p.__utmc = domainHash;
		
		var cookies : String = '__utma=' + p.__utma + ';';
		if(p.__utmz!=null) {
			cookies += '+__utmz=' + p.__utmz + ';';
		}
		if(p.__utmv!=null) {
			cookies += '+__utmv=' + p.__utmv + ';';
		}
		p.utmcc = cookies;
		return p;
	}
	
	private function buildCampaignParameters(p:ParameterHolder) : ParameterHolder {
		var campaign = this.tracker.getCampaign();
		if (campaign == null) return p;
		p.__utmz  = this.generateDomainHash() + '.';
		p.__utmz += campaign.getCreationTime().toString() + '.';
		p.__utmz += this.visitor.getVisitCount() + '.';
		p.__utmz += campaign.getResponseCount() + '.';
		
		// See http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/campaign/CampaignTracker.as#236
		var data:String = 
			'utmcid='   + campaign.getId() + CAMPAIGN_DELIMITER +
			'utmcsr='   + campaign.getSource() + CAMPAIGN_DELIMITER +
			'utmgclid=' + campaign.getGClickId() + CAMPAIGN_DELIMITER +
			'utmdclid=' + campaign.getDClickId() + CAMPAIGN_DELIMITER +
			'utmccn='   + campaign.getName() + CAMPAIGN_DELIMITER +
			'utmcmd='   + campaign.getMedium() + CAMPAIGN_DELIMITER +
			'utmctr='   + campaign.getTerm() + CAMPAIGN_DELIMITER +
			'utmcct='   + campaign.getContent();
		p.__utmz += StringTools.replace(StringTools.replace(data, '+', '%20'), ' ', '%20');
		return p;
	}
	
	/**
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/v4/Tracker.as#585
	 */
	private function generateDomainHash() : Int {
		var hash:Int = 1;
		if (this.tracker.getAllowHash()) {
			hash = Util.generateHash(this.tracker.getDomainName());
		}
		return hash;
	}
	
}
