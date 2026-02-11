import { LightningElement, wire, track, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getLayout } from 'lightning/uiLayoutApi';
import { CurrentPageReference } from 'lightning/navigation';

export default class KrakenRecordDetails extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track recordTypeId;

    @api labelFontSize;
    @api labelColor;
    @api valueFontSize;
    @api valueColor;
    @api sectionHeaderFontSize;
    @api sectionHeaderColor;
    @api sectionHeaderBackgroundColor;
    @api sectionHeaderPaddingTop;
    @api sectionHeaderPaddingRight;
    @api sectionHeaderPaddingBottom;
    @api sectionHeaderPaddingLeft;

    get elementStyles() {
        const styles = [];
        // Field Styling
        if (this.labelFontSize) styles.push(`--kraken-label-font-size: ${this.labelFontSize}`);
        if (this.labelColor) styles.push(`--kraken-label-color: ${this.labelColor}`);
        if (this.valueFontSize) styles.push(`--kraken-value-font-size: ${this.valueFontSize}`);
        if (this.valueColor) styles.push(`--kraken-value-color: ${this.valueColor}`);

        // Section Styling
        if (this.sectionHeaderFontSize) styles.push(`--slds-c-accordion-heading-font-size: ${this.sectionHeaderFontSize}`);
        if (this.sectionHeaderColor) styles.push(`--slds-c-accordion-heading-text-color: ${this.sectionHeaderColor}`);
        if (this.sectionHeaderBackgroundColor) styles.push(`--slds-c-accordion-summary-color-background: ${this.sectionHeaderBackgroundColor}`);
        if (this.sectionHeaderPaddingTop) styles.push(`--slds-c-accordion-section-spacing-block-start: ${this.sectionHeaderPaddingTop}`);
        if (this.sectionHeaderPaddingBottom) styles.push(`--slds-c-accordion-section-spacing-block-end: ${this.sectionHeaderPaddingBottom}`);
        if (this.sectionHeaderPaddingLeft) styles.push(`--slds-c-accordion-section-spacing-inline-start: ${this.sectionHeaderPaddingLeft}`);
        if (this.sectionHeaderPaddingRight) styles.push(`--slds-c-accordion-section-spacing-inline-end: ${this.sectionHeaderPaddingRight}`);
        
        return styles.join(';');
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId || this.recordId;
            this.objectApiName = currentPageReference.attributes.objectApiName || this.objectApiName;
        }
    }

    connectedCallback() {
        console.log('recordId', this.recordId);
        console.log('objectApiName', this.objectApiName);
    }


    @track recordData;

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    wiredRecord({ error, data }) {
        if (data) {
            this.recordTypeId = data.recordTypeId;
            this.recordData = data;
        }
    }

    @track layoutData;
    @track activeSectionNames = [];

    @wire(getLayout, { objectApiName: '$objectApiName', layoutType: 'Full', mode: 'View', recordTypeId: '$recordTypeId' })
    wiredLayout({ error, data }) {
        if (data) {
            this.layoutData = data;
            this.activeSectionNames = data.sections.map(section => section.id);
        }
    }

    get layoutSections() {
        if (this.layoutData && this.recordData) {
            return this.layoutData.sections.map((section, sectionIdx) => {
                return {
                    ...section,
                    // Ensure rows maps strict layout items
                    rows: section.layoutRows.map((row, rowIdx) => {
                        return {
                            ...row,
                            key: `row-${section.id}-${rowIdx}`,
                            items: row.layoutItems.map((item, itemIdx) => {
                                const apiName = item.layoutComponents && item.layoutComponents.length > 0 ? item.layoutComponents[0].apiName : null;
                                let value = null;
                                if (apiName && this.recordData.fields && this.recordData.fields[apiName]) {
                                    value = this.recordData.fields[apiName].displayValue || this.recordData.fields[apiName].value;
                                }
                                return {
                                    ...item,
                                    // Creating a unique key for the iterator. Use apiName if available, otherwise positional key.
                                    key: apiName || `item-${section.id}-${rowIdx}-${itemIdx}`,
                                    // Helper to know if we really have a field
                                    isField: item.layoutComponents && item.layoutComponents[0] && item.layoutComponents[0].componentType === 'Field',
                                    fieldName: apiName,
                                    value: value,
                                    label: item.label
                                };
                            })
                        };
                    })
                };
            });
        }
        return [];
    }
}