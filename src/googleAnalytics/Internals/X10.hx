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
 * This is nearly a 1:1 PHP port of the gaforflash X10 class code.
 * 
 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/data/X10.as
 */

class X10 {
	
	private var projectData : Hash<Array<Array<String>>>;
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
		projectData = new Array();
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
	
	private function hasProject(projectId:Int) : Bool {
		return isset(this.projectData[projectId]);
	}
	
	public function setKey(projectId:Int, num:Int, value:Dynamic) {
		this.setInternal(projectId, this.KEY, num, value);
	}
	
	public function getKey(projectId:Int, num:Int) : Dynamic {
		return this.getInternal(projectId, this.KEY, num);
	}
	
	public function clearKey(projectId:Int) {
		this.clearInternal(projectId, this.KEY);
	}
	
	public function setValue(projectId:Int, num:Int, value:Dynamic) {
		this.setInternal(projectId, this.VALUE, num, value);
	}
	
	public function getValue(projectId:Int, num:Int) : Dynamic {
		return this.getInternal(projectId, this.VALUE, num);
	}
	
	public function clearValue(projectId:Int) {
		this.clearInternal(projectId, this.VALUE);
	}
	
	/**
	 * Shared internal implementation for setting an X10 data type.
	 */
	private function setInternal(projectId:Int, type:String, num:Int, value:Dynamic) {
		if(!isset(this.projectData[projectId])) {
			this.projectData[projectId] = [];
		}
		if(!isset(this.projectData[projectId][type])) {
			this.projectData[projectId][type] = [];
		}
		
		this.projectData[projectId][type][num] = value;
	}
	
	/**
	 * Shared internal implementation for getting an X10 data type.
	 */
	private function getInternal(projectId:Int, type:String, num:Int) : Dynamic {
		if(isset(this.projectData[projectId][type][num])) {
			return this.projectData[projectId][type][num];
		} else {
			return null;
		}
	}
	
	/**
	 * Shared internal implementation for clearing all X10 data of a type from a
	 * certain project.
	 */
	private function clearInternal(projectId:Int, type:String) {
		if(isset(this.projectData[projectId]) && isset(this.projectData[projectId][type])) {
			unset(this.projectData[projectId][type]);
		}
	}
	
	/**
	 * Escape X10 string values to remove ambiguity for special characters.
	 * @see X10::$escapeCharMap
	 */
	private function escapeExtensibleValue(value:String) : String {
		result = '';
		length = value.length;
		for(i in 0...length-1) {
			char = value[i];
			
			if(isset(this.ESCAPE_CHAR_MAP[char])) {
				result += this.ESCAPE_CHAR_MAP[char];
			} else {
				result += char;
			}
		}
		
		return result;
	}
	
	/**
	 * Given a data array for a certain type, render its string encoding.
	 */
	private function renderDataType(data:Array<String>) : String {
		var result:Array<String> = new Array<String>();
		var lastI:Int = 0;
		ksort(data, SORT_NUMERIC);
		for (i in 0...data.length - 1) {
			var entry = data[i];
			if(isset(entry)) {
				str = '';
				
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
	private function renderProject(project:Array<Array<String>>) : String {
		result = '';
	
		// Do we need to output the type string? As an optimization we do not
		// output the type string if it's the first type, or if the previous
		// type was present.
		needTypeQualifier = false;
		
		length = this.SET.length;
		for(i in 0...length) {
			if(isset(project[this.SET[i]])) {
				data = project[this.SET[i]];
				
				if(needTypeQualifier) {
					result += this.SET[i];
				}
				result += this.renderDataType(data);
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
		result = '';
		for(projectId in this.projectData.keys) {
			result += projectId + this.renderProject(this.projectData.get(projectId));
		}		
		return result;
	}
	
}
