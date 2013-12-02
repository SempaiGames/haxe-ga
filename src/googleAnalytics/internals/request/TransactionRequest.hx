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

import googleAnalytics.Transaction;

import googleAnalytics.internals.ParameterHolder;


class TransactionRequest extends Request {
	
	private var transaction : Transaction;
	
	override private function getType() : String {
		return Request.TYPE_TRANSACTION;
	}
	
	/**
	 * @link http://code.google.com/p/gaforflash/source/browse/trunk/src/com/google/analytics/ecommerce/Transaction.as#76
	 */
	override private function buildParameters() : ParameterHolder {
		var p = super.buildParameters();
		
		p.utmtid = this.transaction.getOrderId();
		p.utmtst = this.transaction.getAffiliation();
		p.utmtto = this.transaction.getTotal();
		p.utmttx = this.transaction.getTax();
		p.utmtsp = this.transaction.getShipping();
		p.utmtci = this.transaction.getCity();
		p.utmtrg = this.transaction.getRegion();
		p.utmtco = this.transaction.getCountry();
		
		return p;
	}
	
	/**
	 * The GA Javascript client doesn't send any visitor information for
	 * e-commerce requests, so we don't either.
	 */
	override private function buildVisitorParameters(p:ParameterHolder) : ParameterHolder {
		return p;
	}
	
	/**
	 * The GA Javascript client doesn't send any custom variables for
	 * e-commerce requests, so we don't either.
	 */
	override private function buildCustomVariablesParameter(p:ParameterHolder) : ParameterHolder {
		return p;
	}
	
	public function getTransaction() : Transaction {
		return this.transaction;
	}
	
	public function setTransaction(transaction:Transaction) {
		this.transaction = transaction;
	}
	
}
