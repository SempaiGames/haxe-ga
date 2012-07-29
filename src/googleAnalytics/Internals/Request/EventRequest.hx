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

import googleAnalytics.Event;
import googleAnalytics.internals.ParameterHolder;

import googleAnalytics.internals.X10;


class EventRequest extends Request {
	
	/**
	 * @var googleAnalytics.Event
	 */
	private var event : Event;
	
	
	/**
	 * @const int
	 */
	static inline public var X10_EVENT_PROJECT_ID = '5';
	
	
	/**
	 */
	override private function getType() : String {
		return Request.TYPE_EVENT;
	}
	
	/**
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/v4/Tracker.as#1503
	 */
	override private function buildParameters() : ParameterHolder {
		var p = super.buildParameters();
		
		var x10 = new X10();
		
		x10.clearKey(/*self.*/X10_EVENT_PROJECT_ID);
		x10.clearValue(/*self.*/X10_EVENT_PROJECT_ID);
		
		// Object / Category
		x10.setKey(/*self.*/X10_EVENT_PROJECT_ID, X10.OBJECT_KEY_NUM, this.event.getCategory());
		
		// Event Type / Action
		x10.setKey(/*self.*/X10_EVENT_PROJECT_ID, X10.TYPE_KEY_NUM, this.event.getAction());
		
		if(this.event.getLabel() != null) {
			// Event Description / Label
			x10.setKey(/*self.*/X10_EVENT_PROJECT_ID, X10.LABEL_KEY_NUM, this.event.getLabel());
		}
		
		if(this.event.getValue() != 0) {
			x10.setValue(/*self.*/X10_EVENT_PROJECT_ID, X10.VALUE_VALUE_NUM, this.event.getValue());
		}
		
		p.utme += x10.renderUrlString();
		
		if(this.event.getNoninteraction()) {
			p.utmni = 1;
		}
		
		return p;
	}
	
	public function getEvent() : Event {
		return this.event;
	}
	
	public function setEvent(event:Event) {
		this.event = event;
	}
	
}
