import { LightningElement, api } from 'lwc';

export default class ContactRow extends LightningElement {
    @api contact;
    @api orgId;
    @api isExpanded = false;

    deviceColumns = [
        { label: 'Device Number', fieldName: 'deviceNumber', type: 'phone' },
        { label: 'Device Level', fieldName: 'deviceLevel', type: 'text' },
        { label: 'Device Type', fieldName: 'deviceType', type: 'text' },
        { type: 'action', typeAttributes: { rowActions: [
            { label: 'View', name: 'view' },
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ] } }
    ];

    get iconName() {
        return this.isExpanded ? 'utility:chevronup' : 'utility:chevrondown';
    }

    toggle() {
        this.isExpanded = !this.isExpanded;
        this.dispatchEvent(new CustomEvent('togglecontact', {
            detail: { orgId: this.orgId, contactId: this.contact.id }
        }));
    }

    handleRowAction(event) {
        this.dispatchEvent(new CustomEvent('rowaction', { detail: event.detail }));
    }
}