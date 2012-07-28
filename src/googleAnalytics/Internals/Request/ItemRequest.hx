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

import googleAnalytics.Item;

import googleAnalytics.internals.ParameterHolder;


class ItemRequest extends Request {
	
	/**
	 * @var googleAnalytics.Item
	 */
	private var item : googleAnalytics;
	
	
	/**
	 */
	private function getType() : String {
		return Request.TYPE_ITEM;
	}
	
	/**
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/ecommerce/Item.as#61
	 * @return googleAnalytics.internals.ParameterHolder
	 */
	private function buildParameters() : googleAnalytics {
		p = super.buildParameters();		
		
		p.utmtid = this.item.getOrderId();
		p.utmipc = this.item.getSku();
		p.utmipn = this.item.getName();
		p.utmiva = this.item.getVariation();
		p.utmipr = this.item.getPrice();
		p.utmiqt = this.item.getQuantity();  
		
		return p;
	}
	
	/**
	 * The GA Javascript client doesn't send any visitor information for
	 * e-commerce requests, so we don't either.
	 * @param googleAnalytics.internals.ParameterHolder $p
	 * @return googleAnalytics.internals.ParameterHolder
	 */
	private function buildVisitorParameters(p:ParameterHolder) : googleAnalytics {
		return p;
	}
	
	/**
	 * The GA Javascript client doesn't send any custom variables for
	 * e-commerce requests, so we don't either.
	 * @param googleAnalytics.internals.ParameterHolder $p
	 * @return googleAnalytics.internals.ParameterHolder
	 */
	private function buildCustomVariablesParameter(p:ParameterHolder) : googleAnalytics {
		return p;
	}
	
	/**
	 * @return googleAnalytics.Item
	 */
	function getItem() : googleAnalytics {
		return this.item;
	}
	
	/**
	 * @param googleAnalytics.Item $item
	 */
	function setItem(item:Item) {
		this.item = item;
	}
	
}
