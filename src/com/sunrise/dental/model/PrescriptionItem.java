package com.sunrise.dental.model;

/**
 * PrescriptionItem — Individual drug line item inside a prescription.
 */
public class PrescriptionItem {

    private int    itemId;
    private int    prescriptionId;
    private String drugName;
    private String dosage;
    private String frequency;
    private String duration;
    private String instructions;

    // -------------------------------------------------------
    // Getters & Setters
    // -------------------------------------------------------
    public int getItemId() { return itemId; }
    public void setItemId(int v) { this.itemId = v; }

    public int getPrescriptionId() { return prescriptionId; }
    public void setPrescriptionId(int v) { this.prescriptionId = v; }

    public String getDrugName() { return drugName; }
    public void setDrugName(String v) { this.drugName = v; }

    public String getDosage() { return dosage; }
    public void setDosage(String v) { this.dosage = v; }

    public String getFrequency() { return frequency; }
    public void setFrequency(String v) { this.frequency = v; }

    public String getDuration() { return duration; }
    public void setDuration(String v) { this.duration = v; }

    public String getInstructions() { return instructions; }
    public void setInstructions(String v) { this.instructions = v; }
}
