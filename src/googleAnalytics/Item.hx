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

/**
 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/ecommerce/Item.as
 */
class Item {
	
	/**
	 * Order ID, e.g. "a2343898", will be mapped to "utmtid" parameter
	 * @see internals.ParameterHolder::$utmtid
	 */
	private var orderId : String;
	
	/**
	 * Product Code. This is the sku code for a given product, e.g. "989898ajssi",
	 * will be mapped to "utmipc" parameter
	 * @see internals.ParameterHolder::$utmipc
	 */
	private var sku : String;
	
	/**
	 * Product Name, e.g. "T-Shirt", will be mapped to "utmipn" parameter
	 * @see internals.ParameterHolder::$utmipn
	 */
	private var name : String;
	
	/**
	 * Variations on an item, e.g. "white", "black", "green" etc., will be mapped
	 * to "utmiva" parameter
	 * @see internals.ParameterHolder::$utmiva
	 */
	private var variation : String;
	
	/**
	 * Unit Price. Value is set to numbers only (e.g. 19.95), will be mapped to
	 * "utmipr" parameter
	 * @see internals.ParameterHolder::$utmipr
	 */
	private var price : Float;
	
	/**
	 * Unit Quantity, e.g. 4, will be mapped to "utmiqt" parameter
	 * @see internals.ParameterHolder::$utmiqt
	 */
	private var quantity : Int = 1;
	
	
	function validate() : Void {
		if(this.sku === null) {
			Tracker._raiseError('Items need to have a sku/product code defined.', __METHOD__);
		}
	}
	
	/**
	 */
	function getOrderId() : String {
		return this.orderId;
	}
	
	/**
	 */
	function setOrderId(orderId:String) {
		this.orderId = orderId;
	}
	
	/**
	 */
	function getSku() : String {
		return this.sku;
	}
	
	/**
	 */
	function setSku(sku:String) {
		this.sku = sku;
	}
	
	/**
	 */
	function getName() : String {
		return this.name;
	}
	
	/**
	 */
	function setName(name:String) {
		this.name = name;
	}
	
	/**
	 */
	function getVariation() : String {
		return this.variation;
	}
	
	/**
	 */
	function setVariation(variation:String) {
		this.variation = variation;
	}
	
	/**
	 */
	function getPrice() : Float {
		return this.price;
	}
	
	/**
	 */
	function setPrice(price:Float) {
		this.price = (float)price;
	}
	
	/**
	 */
	function getQuantity() : Int {
		return this.quantity;
	}
	
	/**
	 */
	function setQuantity(quantity:Int) {
		this.quantity = (int)quantity;
	}
	
}
