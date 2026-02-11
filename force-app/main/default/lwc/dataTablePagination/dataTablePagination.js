import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getCursorContactList from '@salesforce/apex/CursorContacts.getContacts';
import getCursorTotalContacts from '@salesforce/apex/CursorContacts.getTotalContacts';

export default class DataTablePagination extends LightningElement {

    @track contactList;
    @track pageSize = 5;
    @track page = 0;
    @track nextButton;
    @track prevButton = true;

    constructor(){
        super();

        this.columns = [
            { label: 'Name', fieldName: 'Name', type: 'url', 
                typeAttributes: { 
                    label: { fieldName: 'Name' }, 
                    target: '_self' 
                } 
            },
            { label: 'Role', fieldName: 'Role__c' },
            { label: 'Email', fieldName: 'Email', type: 'email' },
            { label: 'Contact Creation Date', fieldName: 'CreatedDate', type: 'date' },
            { label: 'Status', fieldName: 'Status__c' },
            { type: 'action', 
                typeAttributes: { 
                    rowActions: this.getRowActions 
                }
            }
        ];
    }

    // Define the actions available for each row depending on the row's status field value.
    getRowActions(row, done){

        const actions = [];
        if(row.Status__c === 'Active'){

            actions.push(
                { label: 'Edit contact details', name: 'edit'},
                { label: 'Send password reset email', name: 'reset_email'},
                { label: 'Set status to "Inactive"', name: 'status_inactive'}
            );

        } else if(row.Status__c === 'Inactive'){

            actions.push(
                { label: 'Edit contact details', name: 'edit'},
                { label: 'Set status to "Active"', name: 'status_active'}
            );

        } else if(row.Status__c === 'In Progress') {

            actions.push(
                { label: 'Edit contact details', name: 'edit'},
                { label: 'Resend invite email', name: 'resend_email'},
                { label: 'Set status to "Inactive"', name: 'status_inactive'}
            );

        }
        done(actions);
    }

    // Set records per page
    get pageSizeOptions(){

        return [
            { label: '5', value: 5 },
            { label: '10', value: 10 },
            { label: '20', value: 20},
            { label: '25', value: 25 },
            { label: '50', value: 50 }
        ];

    }

    // Get Number of Records
    @wire(getCursorTotalContacts)
    getContactCount(data, error){
        
        data = data.data
        if(data){
        
            // console.log(`Record Count: ${data}`);
        
        } else if(error) {

            console.error('Error getting record count: ', error);
        
        }

    };

    // Get Records
    @wire(getCursorContactList, { pageSize: '$pageSize', page: '$page' })
    contacts(data, error){

        data = data.data;
        if(data) {

            this.contactList = data;
            // console.log(data);

        } else if(error){

            console.error('Error setting limit for contact list: ', error);

        }

    };

    async selectPageSize(event){

        this.pageSize = event.detail.value;
        this.page = 0;
        try {

            await getCursorContactList({
                page: this.page ,
                pageSize: this.pageSize,
            });

            await refreshApex(this.contacts);

            this.prevButton = false;

        } catch (error) {

            console.error("Error received: code" + error.errorCode + ", " + "message " + error.body.message);
            this.nextButton = true;

        }
    }

    async nextPage(){

        this.page += 1;
        try {

            await getCursorContactList({
                page: this.page ,
                pageSize: this.pageSize,
            });

            await refreshApex(this.contacts);
            
            this.prevButton = false;

        } catch (error) {

            console.error("Error received: code" + error.errorCode + ", " + "message " + error.body.message);
            this.nextButton = true;
            
        }
    }

    async previousPage(){

        this.page -= 1;
        try {

            await getCursorContactList({
              page: this.page ,
              pageSize: this.pageSize,
            });

            await refreshApex(this.contacts);

            this.nextButton = false;

        } catch (error) {

            console.error("Error received: code" + error.errorCode + ", " + "message " + error.body.message);
            this.prevButton = true;

        }
    }

}