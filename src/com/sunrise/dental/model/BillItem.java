package com.sunrise.dental.model;

import java.math.BigDecimal;

/**
 * BillItem — A single line item within a Bill.
 * Types: CONSULTATION, TREATMENT, MEDICATION, MATERIAL, OTHER
 */
public class BillItem {

    private int        itemId;
    private int        billId;
    private String     itemType;
    private String     description;
    private BigDecimal unitPrice;
    private BigDecimal quantity;
    private BigDecimal totalPrice;

    // -------------------------------------------------------
    // Computed
    // -------------------------------------------------------
    public void computeTotal() {
        if (unitPrice != null && quantity != null) {
            totalPrice = unitPrice.multiply(quantity);
        }
    }

    // -------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------
    public int        getItemId()               { return itemId; }
    public void       setItemId(int v)          { this.itemId = v; }

    public int        getBillId()               { return billId; }
    public void       setBillId(int v)          { this.billId = v; }

    public String     getItemType()             { return itemType; }
    public void       setItemType(String v)     { this.itemType = v; }

    public String     getDescription()          { return description; }
    public void       setDescription(String v)  { this.description = v; }

    public BigDecimal getUnitPrice()            { return unitPrice; }
    public void       setUnitPrice(BigDecimal v){ this.unitPrice = v; }

    public BigDecimal getQuantity()             { return quantity; }
    public void       setQuantity(BigDecimal v) { this.quantity = v; }

    public BigDecimal getTotalPrice()           { return totalPrice; }
    public void       setTotalPrice(BigDecimal v){ this.totalPrice = v; }

    @Override
    public String toString() {
        return "BillItem{billId=" + billId + ", type='" + itemType
                + "', desc='" + description + "', total=" + totalPrice + "}";
    }
}
