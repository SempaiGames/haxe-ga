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

/**
 * @link http://code.google.com/apis/analytics/docs/tracking/eventTrackerOverview.html
 * @link http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEventTracking.html
 */

class Event {	
	
	/**
	 * The general event category (e.g. "Videos").
	 */
	private var category : String;
	
	/**
	 * The action for the event (e.g. "Play").
	 */
	private var action : String;
	
	/**
	 * An optional descriptor for the event (e.g. the video's title).
	 */
	private var label : String;
	
	/**
	 * An optional value associated with the event. You can see your event values in the Overview,
	 * Categories, and Actions reports, where they are listed by event or aggregated across events,
	 * depending upon your report view.
	 */
	private var value : Int;
	
	/**
	 * Default value is false. By default, event hits will impact a visitor's bounce rate.
	 * By setting this parameter to true, this event hit will not be used in bounce rate calculations.
	 */
	private var noninteraction : Bool = false;
	
	
	public function new(category:String=null, action:String=null, label:String=null, value:Int=0, noninteraction:Bool=false) {
		if(category       != null) this.setCategory(category);
		if(action         != null) this.setAction(action);
		if(label          != null) this.setLabel(label);
		this.setValue(value);
		this.setNoninteraction(noninteraction);
	}
	
	public function validate() : Void {
		if(this.category == null || this.action == null) {
			Tracker._raiseError('Events need at least to have a category and action defined.', 'Event.validate');
		}
	}
	
	public function getCategory() : String {
		return this.category;
	}
	
	public function setCategory(category:String) {
		this.category = category;
	}
	
	public function getAction() : String {
		return this.action;
	}
	
	public function setAction(action:String) {
		this.action = action;
	}
	
	public function getLabel() : String {
		return this.label;
	}
	
	public function setLabel(label:String) {
		this.label = label;
	}
	
	public function getValue() : Int {
		return this.value;
	}
	
	public function setValue(value:Int) {
		this.value = value;
	}
	
	public function getNoninteraction() : Bool {
		return this.noninteraction;
	}
	
	public function setNoninteraction(value:Bool) {
		this.noninteraction = value;
	}
	
}
