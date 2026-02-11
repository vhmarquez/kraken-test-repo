import { LightningElement, wire, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import MULTI_PICKLIST_FIELD from '@salesforce/schema/Contact.Test_Multi_Select__c';

export default class PanaFieldMutliselect extends LightningElement {

    @track pickListValues;
    @track selectedValues;

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA' , fieldApiName: MULTI_PICKLIST_FIELD })
    wiredPicklistValues({data, error}){
        if(data) {
            console.log(data);
            this.pickListValues = data.values;
        } else if (error) {
            console.error(error);
        }
    }

}