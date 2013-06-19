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

package  googleAnalytics.internals;
import haxe.BaseCode;

/**
 * This is nearly a 1:1 Haxe port of the gaforflash X10 class code.
 * I'm sure it cointains errors (since it's been ported form ActionScript to PHP and from PHP
 * to Haxe. I'm not sure also what's X10 about u.u
 * 
 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/data/X10.as
 */

class X10 {
	
	private var projectData : Hash<Hash<Array<String>>>;
	private var KEY : String;
	private var VALUE : String;
	private var SET : Array<String>;
	
	/**
	 * Opening delimiter for wrapping a set of values belonging to the same type.
	 */
	private var DELIM_BEGIN : String;
	
	/**
	 * Closing delimiter for wrapping a set of values belonging to the same type.
	 */
	private var DELIM_END : String;
	
	/**
	 * Delimiter between two consecutive num/value pairs.
	 */
	private var DELIM_SET : String;
	
	/**
	 * Delimiter between a num and its corresponding value.
	 */
	private var DELIM_NUM_VALUE : String;
	
	/**
	 * Mapping of escapable characters to their escaped forms.
	 */
	private var ESCAPE_CHAR_MAP : Hash<String>;
	
	private var MINIMUM : Int;
	
	public function new() {
		projectData = new Hash<Hash<Array<String>>>();
		KEY = 'k';
		VALUE = 'v';
		SET = [ 'k', 'v' ];
		DELIM_BEGIN = '(';
		DELIM_END = ')';
		DELIM_SET = '*';
		DELIM_NUM_VALUE = '!';
		MINIMUM = 1;
		ESCAPE_CHAR_MAP = new Hash<String>();
		ESCAPE_CHAR_MAP.set('\'', '\'0');
		ESCAPE_CHAR_MAP.set(')' , '\'1');
		ESCAPE_CHAR_MAP.set('*' , '\'2');
		ESCAPE_CHAR_MAP.set('!' , '\'3');
	}
	
	
	
	static inline public var OBJECT_KEY_NUM  = 1;
	static inline public var TYPE_KEY_NUM    = 2;
	static inline public var LABEL_KEY_NUM   = 3;
	static inline public var VALUE_VALUE_NUM = 1;
	
	private function hasProject(projectId:String) : Bool {
		return projectData.exists(projectId);
	}
	
	public function setKey(projectId:String, num:Int, value:Dynamic) {
		this.setInternal(projectId, this.KEY, num, value);
	}
	
	public function getKey(projectId:String, num:Int) : Dynamic {
		return this.getInternal(projectId, this.KEY, num);
	}
	
	public function clearKey(projectId:String) {
		this.clearInternal(projectId, this.KEY);
	}
	
	public function setValue(projectId:String, num:Int, value:Dynamic) {
		this.setInternal(projectId, this.VALUE, num, value);
	}
	
	public function getValue(projectId:String, num:Int) : Dynamic {
		return this.getInternal(projectId, this.VALUE, num);
	}
	
	public function clearValue(projectId:String) {
		this.clearInternal(projectId, this.VALUE);
	}
	
	/**
	 * Shared internal implementation for setting an X10 data type.
	 */
	private function setInternal(projectId:String, type:String, num:Int, value:Dynamic) {
		if(!projectData.exists(projectId)) {
			projectData.set(projectId, new Hash<Array<String>>());
		}
		var p = projectData.get(projectId);
		if(!p.exists(type)) {
			p.set(type, new Array<String>());
		}
		p.get(type)[num] = value;
	}
	
	/**
	 * Shared internal implementation for getting an X10 data type.
	 */
	private function getInternal(projectId:String, type:String, num:Int) : Dynamic {
		if (!projectData.exists(projectId)) return null;
		var p : Hash<Array<String>> = projectData.get(projectId);
		if (!p.exists(type)) return null;
		var a : Array<String> = p.get(type);
		if (a[num]==null) return null;
		return a[num];
	}
	
	/**
	 * Shared internal implementation for clearing all X10 data of a type from a
	 * certain project.
	 */
	private function clearInternal(projectId:String, type:String) {
		if(projectData.exists(projectId) && projectData.get(projectId).exists(type)) {
			projectData.get(projectId).remove(type);
		}
	}
	
	/**
	 * Escape X10 string values to remove ambiguity for special characters.
	 * @see X10::$escapeCharMap
	 */
	private function escapeExtensibleValue(value:String) : String {
		var result = '';
		for(i in 0...value.length) {
			var char = value.charAt(i);
			if(ESCAPE_CHAR_MAP.exists(char)) {
				result += this.ESCAPE_CHAR_MAP.get(char);
			} else {
				result += char;
			}
		}
		
		return result;
	}
	
	function SORT_NUMERIC(v1:String, v2:String):Int {
		if (v1 == v2) return 0;
		if (v1 > v2) return 1;
		return -1;
	}
	
	/**
	 * Given a data array for a certain type, render its string encoding.
	 */
	private function renderDataType(data:Array<String>) : String {
		var result:Array<String> = new Array<String>();
		var lastI:Int = 0;
		// The original order must be retained, otherwise event's category/action/label will be mixed up
		//data.sort(SORT_NUMERIC); // on PHP -> ksort(data, SORT_NUMERIC);
		
		for (i in 0...data.length) {
			var entry = data[i];
			if(entry!=null) {
				var str: String = '';
				
				// Check if we need to append the number. If the last number was
				// outputted, or if this is the assumed minimum, then we don't.
				if(i != this.MINIMUM && i - 1 != lastI) {
					str += i;
					str += this.DELIM_NUM_VALUE;
				}
	
				str += this.escapeExtensibleValue(entry);
				result.push(str);
			}
			
			lastI = i;
		}
		
		return this.DELIM_BEGIN + result.join(this.DELIM_SET) + this.DELIM_END;
	}
	
	/**
	 * Given a project array, render its string encoding.
	 */
	private function renderProject(project:Hash<Array<String>>) : String {
		var result = '';
	
		// Do we need to output the type string? As an optimization we do not
		// output the type string if it's the first type, or if the previous
		// type was present.
		var needTypeQualifier: Bool = false;
		
		for(i in 0...SET.length) {
			if(project.exists(this.SET[i])) {
				if(needTypeQualifier) {
					result += SET[i];
				}
				result += renderDataType(project.get(this.SET[i]));
				needTypeQualifier = false;
			} else {
				needTypeQualifier = true;
			}
		}
		
		return result;
	}
	
	/**
	 * Generates the URL parameter string for the current internal extensible data state.
	 */
	public function renderUrlString() : String {
		var result = '';
		for(projectId in this.projectData.keys()) {
			result += projectId + this.renderProject(this.projectData.get(projectId));
		}		
		return result;
	}
	
}
