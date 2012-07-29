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
 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/ecommerce/Transaction.as
 */
class Transaction {
	
	/**
	 * Order ID, e.g. "a2343898", will be mapped to "utmtid" parameter
	 * @see internals.ParameterHolder::$utmtid
	 */
	private var orderId : String;
	
	/**
	 * Affiliation, Will be mapped to "utmtst" parameter
	 * @see internals.ParameterHolder::$utmtst
	 */
	private var affiliation : String;
	
	/**
	 * Total Cost, will be mapped to "utmtto" parameter
	 * @see internals.ParameterHolder::$utmtto
	 */
	private var total : Float;
	
	/**
	 * Tax Cost, will be mapped to "utmttx" parameter
	 * @see internals.ParameterHolder::$utmttx
	 */
	private var tax : Float;
	
	/**
	 * Shipping Cost, values as for unit and price, e.g. 3.95, will be mapped to
	 * "utmtsp" parameter
	 * @see internals.ParameterHolder::$utmtsp
	 */
	private var shipping : Float;
	
	/**
	 * Billing City, e.g. "Cologne", will be mapped to "utmtci" parameter
	 * @see internals.ParameterHolder::$utmtci
	 */
	private var city : String;
	
	/**
	 * Billing Region, e.g. "North Rhine-Westphalia", will be mapped to "utmtrg" parameter
	 * @see internals.ParameterHolder::$utmtrg
	 */
	private var region : String;
	
	/**
	 * Billing Country, e.g. "Germany", will be mapped to "utmtco" parameter
	 * @see internals.ParameterHolder::$utmtco
	 */
	private var country : String;
	
	/**
	 * @see Transaction::addItem()
	 */
	private var items : Hash<Item>;
	
	public function new() {
		items = new Hash<Item>();
	}
	
	public function validate() : Void {
		if(this.items==null) {
			Tracker._raiseError('Transactions need to consist of at least one item.', 'Transaction.validate');
		}
	}
	
	/**
	 * @link http://code.google.com/apis/analytics/docs/gaJS/gaJSApiEcommerce.html#_gat.GA_Tracker_._addItem
	 */
	public function addItem(item:Item) {
		// Associated items inherit the transaction's order ID
		item.setOrderId(this.orderId);
		items.set(item.getSku(),item);
	}
	
	public function getItems() : Hash<Item> {
		return this.items;
	}
	
	public function getOrderId() : String {
		return this.orderId;
	}
	
	public function setOrderId(orderId:String) {
		this.orderId = orderId;
		
		// Update order IDs of all associated items too
		for(item in this.items) {
			item.setOrderId(orderId);
		}
	}
	
	public function getAffiliation() : String {
		return this.affiliation;
	}
	
	public function setAffiliation(affiliation:String) {
		this.affiliation = affiliation;
	}
	
	public function getTotal() : Float {
		return this.total;
	}
	
	public function setTotal(total:Float) {
		this.total = total;
	}
	
	public function getTax() : Float {
		return this.tax;
	}
	
	public function setTax(tax:Float) {
		this.tax = tax;
	}
	
	public function getShipping() : Float {
		return this.shipping;
	}
	
	public function setShipping(shipping:Float) {
		this.shipping = shipping;
	}
	
	public function getCity() : String {
		return this.city;
	}
	
	public function setCity(city:String) {
		this.city = city;
	}
	
	public function getRegion() : String {
		return this.region;
	}
	
	public function setRegion(region:String) {
		this.region = region;
	}
	
	public function getCountry() : String {
		return this.country;
	}
	
	public function setCountry(country:String) {
		this.country = country;
	}
	
}
