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


class SocialInteraction {
	
	/**
	 * Required. A string representing the social network being tracked (e.g. "Facebook", "Twitter", "LinkedIn", ...),
	 * will be mapped to "utmsn" parameter
	 * @see internals.ParameterHolder::$utmsn
	 */
	private var network : String;
	
	/**
	 * Required. A string representing the social action being tracked (e.g. "Like", "Share", "Tweet", ...),
	 * will be mapped to "utmsa" parameter
	 * @see internals.ParameterHolder::$utmsa
	 */
	private var action : String;
	
	/**
	 * Optional. A string representing the URL (or resource) which receives the action. For example,
	 * if a user clicks the Like button on a page on a site, the the target might be set to the title
	 * of the page, or an ID used to identify the page in a content management system. In many cases,
	 * the page you Like is the same page you are on. So if this parameter is not given, we will default
	 * to using the path of the corresponding Page object.
	 * @see internals.ParameterHolder::$utmsid
	 */
	private var target : String;
	
	
	public function __construct(network=null, action=null, target=null) {
		if(network != null) this.setNetwork(network);
		if(action  != null) this.setAction(action);
		if(target  != null) this.setTarget(target);
	}
	
	public function validate() : Void {
		if(this.network == null || this.action == null) {
			Tracker._raiseError('Social interactions need to have at least the "network" and "action" attributes defined.', 'SocialInteraction.validate');
		}
	}
	
	public function setNetwork(network:String) {
		this.network = network;
	}
	
	public function getNetwork() : String {
		return this.network;
	}
	
	public function setAction(action:String) {
		this.action = action;
	}
	
	public function getAction() : String {
		return this.action;
	}
	
	public function setTarget(target:String) {
		this.target = target;
	}
	
	public function getTarget() : String {
		return this.target;
	}
	
}
