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
 * @link http://code.google.com/apis/analytics/docs/tracking/gaTrackingCustomVariables.html
 */

class CustomVariable {
	
	/**
	 */
	private var index : Int;
	
	/**
	 * WATCH OUT: It's a known issue that GA will not decode URL-encoded characters
	 * in custom variable names and values properly, so spaces will show up
	 * as "%20" in the interface etc.
	 * @link http://www.google.com/support/forum/p/Google%20Analytics/thread?tid=2cdb3ec0be32e078
	 */
	private var name : String;
	
	/**
	 * WATCH OUT: It's a known issue that GA will not decode URL-encoded characters
	 * in custom variable names and values properly, so spaces will show up
	 * as "%20" in the interface etc.
	 * @link http://www.google.com/support/forum/p/Google%20Analytics/thread?tid=2cdb3ec0be32e078
	 */
	private var value : Dynamic;
	
	/**
	 * See SCOPE_* constants
	 */
	private var scope : Int = /*self.*/SCOPE_PAGE;
	
	static inline public var SCOPE_VISITOR = 1;
	static inline public var SCOPE_SESSION = 2;
	static inline public var SCOPE_PAGE    = 3;
	
	
	/**
	 * @param scope See SCOPE_* constants
	 */
	public function new(index:Int=0, name:String=null, value:Dynamic=null, scope:Int=0) {
		if(index != 0) this.setIndex(index);
		if(name  != null) this.setName(name);
		if(value != null) this.setValue(value);
		if(scope != 0) this.setScope(scope);
	}
	
	public function validate() : Void {
		// According to the GA documentation, there is a limit to the combined size of
		// name and value of 64 bytes after URL encoding,
		// see http://code.google.com/apis/analytics/docs/tracking/gaTrackingCustomVariables.html#varTypes
		// and http://xahlee.org/js/google_analytics_tracker_2010-07-01_expanded.js line 563
		// This limit was increased to 128 bytes BEFORE encoding with the 2012-01 release of ga.js however,
		// see http://code.google.com/apis/analytics/community/gajs_changelog.html
		if((this.name + this.value).length > 128) {
			Tracker._raiseError('Custom Variable combined name and value length must not be larger than 128 bytes.', 'CustomVariable.validate');
		}
	}
	
	public function getIndex() : Int {
		return this.index;
	}
	
	/**
	 * @link http://code.google.com/intl/de-DE/apis/analytics/docs/tracking/gaTrackingCustomVariables.html#usage
	 */
	public function setIndex(index:Int) {
		// Custom Variables are limited to five slots officially, but there seems to be a
		// trick to allow for more of them which we could investigate at a later time (see
		// http://analyticsimpact.com/2010/05/24/get-more-than-5-custom-variables-in-google-analytics/)
		if(index < 1 || index > 5) {
			Tracker._raiseError('Custom Variable index has to be between 1 and 5.', 'CustomVariable.setIndex');
		}
		this.index = index;
	}
	
	public function getName() : String {
		return this.name;
	}
	
	public function setName(name:String) {
		this.name = name;
	}
	
	public function getValue() : Dynamic {
		return this.value;
	}
	
	public function setValue(value:Dynamic) {
		this.value = value;
	}
	
	public function getScope() : Int {
		return this.scope;
	}
	
	public function setScope(scope:Int) {
		if( scope != SCOPE_PAGE && scope != SCOPE_SESSION && scope != SCOPE_VISITOR ) {
			Tracker._raiseError('Custom Variable scope has to be one of the CustomVariable::SCOPE_* constant values.', 'CustomVariable.setScope');
		}
		this.scope = scope;
	}
	
}
