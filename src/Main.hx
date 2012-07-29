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

package ;

class Main {
	
	public static function main() {
		trace('Creating Tracker');
		var tracker = new googleAnalytics.Tracker('UA-27265081-3', 'testing.sempaigames.com');
		trace(tracker);
		
		trace('Creating Visitor');
		// (could also get unserialized from database)
		var visitor = new googleAnalytics.Visitor();
		visitor.setUserAgent('haXe-ga');
		visitor.setScreenResolution('1024x768');
		visitor.setLocale('es_AR');
		trace(visitor);

		trace('Creating Session');
		var session = new googleAnalytics.Session();
		trace(session);

		trace('Creating Page');
		// Assemble Page information
		var page = new googleAnalytics.Page('/page.html');
		page.setTitle('My Page');
		trace(page);

		trace('Tracking PageView');
		// Track page view
		tracker.trackPageview(page, session, visitor);
		trace(tracker);
	}
	
}