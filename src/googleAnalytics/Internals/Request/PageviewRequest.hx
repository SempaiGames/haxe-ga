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
import googleAnalytics.internals.ParameterHolder;
import googleAnalytics.Page;

class PageviewRequest extends Request {
	
	private var page : Page;

	override private function getType() : String {
		return Request.TYPE_PAGE;
	}
	
	public function new(config:Config=null) {
		super(config);		
	}
	
	override private function buildParameters() : ParameterHolder {
		var p = super.buildParameters();
		p.utmp  = this.page.getPath();
		p.utmdt = this.page.getTitle();
		if(this.page.getCharset() != null) {
			p.utmcs = this.page.getCharset();
		}
		if(this.page.getReferrer() != null) {
			p.utmr = this.page.getReferrer();
		}
		
		if(this.page.getLoadTime()!=0) {
			// Sample sitespeed measurements
			if(p.utmn % 100 < this.config.getSitespeedSampleRate()) {
				p.utme += 0;
			}
		}
		
		return p;
	}
	
	public function getPage() : Page {
		return this.page;
	}
	
	public function setPage(page:Page) {
		this.page = page;
	}
	
}
