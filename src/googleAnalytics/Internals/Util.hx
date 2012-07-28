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

package  googleAnalytics.internals;

/**
 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/core/Utils.as
 */

class Util {
	
	/**
	 * This class does only have public static methods, no instantiation necessary
	 */
	private function __construct() { }
	
	
	/**
	 * Mimics Javascript's encodeURIComponent() function for consistency with the GA Javascript client.
	 */
	public static function encodeUriComponent(value:Dynamic) : String {
		return static.convertToUriComponentEncoding(rawurlencode(value));
	}
	
	/**
	 * Here as a separate method so it can also be applied to e.g. a http_build_query() result.
	 * @link http://stackoverflow.com/questions/1734250/what-is-the-equivalent-of-javascripts-encodeuricomponent-in-php/1734255#1734255
	 * @link http://devpro.it/examples/php_js_escaping.php
	 */
	public static function convertToUriComponentEncoding(encodedValue:String) : String {
		return encodedValue.replace([ '%21', '%2A', '%27', '%28', '%29' ], [ '!', '*', "'", '(', ')' ]);
	}
	
	/**
	 * Generates a 32bit random number.
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/core/Utils.as#33
	 */
	public static function generate32bitRandom() : Int {
		return Math.round((rand() / getrandmax()) * 0x7fffffff);
	}
	
	/**
	 * Generates a hash for input string.
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/core/Utils.as#44
	 */
	public static function generateHash(string:String) : Int {
		string = (string)string;
		hash = 1;
		
		if(string !== null && string !== '') {
			hash = 0;
			
			length = string.length;
			for(pos = length - 1; pos >= 0; pos--) {
				current   = ord(string[pos]);
				hash      = ((hash << 6) & 0xfffffff) + current + (current << 14);
				leftMost7 = hash & 0xfe00000;
				if(leftMost7 != 0) {
					hash ^= leftMost7 >> 21;
				}
			}
		}
		
		return hash;
	}
	
}
