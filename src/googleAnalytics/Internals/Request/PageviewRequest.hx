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

package  googleAnalytics.internals.request;

import googleAnalytics.Page;

import googleAnalytics.internals.X10;


class PageviewRequest extends Request {
	
	/**
	 * @var googleAnalytics.Page
	 */
	private var page : googleAnalytics;
	
	
	/**
	 * @const int
	 */
	static inline public var X10_SITESPEED_PROJECT_ID = 14;
	
	
	/**
	 */
	private function getType() : String {
		return Request.TYPE_PAGE;
	}
	
	/**
	 * @return googleAnalytics.internals.ParameterHolder
	 */
	private function buildParameters() : googleAnalytics {
		p = super.buildParameters();
		
		p.utmp  = this.page.getPath();
		p.utmdt = this.page.getTitle();
		if(this.page.getCharset() !== null) {
			p.utmcs = this.page.getCharset();
		}
		if(this.page.getReferrer() !== null) {
			p.utmr = this.page.getReferrer();
		}
		
		if(this.page.getLoadTime() !== null) {
			// Sample sitespeed measurements
			if(p.utmn % 100 < this.config.getSitespeedSampleRate()) {
				x10 = new X10();
				
				x10.clearKey(/*self.*/X10_SITESPEED_PROJECT_ID);
				x10.clearValue(/*self.*/X10_SITESPEED_PROJECT_ID);
				
				// Taken from ga.js code
				key = Math.max(Math.min(floor(this.page.getLoadTime() / 100), 5000), 0) * 100;
				x10.setKey(/*self.*/X10_SITESPEED_PROJECT_ID, X10.OBJECT_KEY_NUM, key);
				
				x10.setValue(/*self.*/X10_SITESPEED_PROJECT_ID, X10.VALUE_VALUE_NUM, this.page.getLoadTime());
				
				p.utme += x10.renderUrlString();
			}
		}
		
		return p;
	}
	
	/**
	 * @return googleAnalytics.Page
	 */
	function getPage() : googleAnalytics {
		return this.page;
	}
	
	/**
	 * @param googleAnalytics.Page $page
	 */
	function setPage(page:Page) {
		this.page = page;
	}
	
}
