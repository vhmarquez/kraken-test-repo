import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTreeData from '@salesforce/apex/ESCCDeviceControllerPlus.getTreeData';
import getTotalCount from '@salesforce/apex/ESCCDeviceControllerPlus.getTotalCount';
import getCSVData from '@salesforce/apex/ESCCDeviceControllerPlus.getCSVData';

export default class EsccDeviceTreeGridPlus extends NavigationMixin(LightningElement) {
    @track treeData = [];
    @track selectedViews = new Set();
    @track pageSize = 10;
    @track currentPage = 1;
    @track totalRecords = 0;
    @track isLoading = false;
    @track expandedOrgs = new Set();
    @track expandedContacts = new Map();

    viewDisplayContacts = 'Display Contacts';
    viewEISAC = 'E-ISAC';
    viewMyOrg = 'My Org';
    viewMine = 'Mine';
    
    pageSizeOptions = [
        { label: '10', value: 10 },
        { label: '25', value: 25 },
        { label: '50', value: 50 }
    ];
    
    get enhancedTreeData() {
        return this.treeData.map(org => ({
            ...org,
            orgIcon: this.expandedOrgs.has(org.id) ? 'utility:chevrondown' : 'utility:chevronright',
            isExpanded: this.expandedOrgs.has(org.id)
        }));
    }
    
    get selectedViewsArray() {
        return Array.from(this.selectedViews);
    }
    
    get variantDisplayContacts() {
        return this.selectedViews.has(this.viewDisplayContacts) ? 'brand' : 'neutral';
    }
    
    get variantEISAC() {
        return this.selectedViews.has(this.viewEISAC) ? 'brand' : 'neutral';
    }
    
    get variantMyOrg() {
        return this.selectedViews.has(this.viewMyOrg) ? 'brand' : 'neutral';
    }
    
    get variantMine() {
        return this.selectedViews.has(this.viewMine) ? 'brand' : 'neutral';
    }
    
    get offset() {
        return (this.currentPage - 1) * this.pageSize;
    }
    
    get totalPages() {
        return Math.ceil(this.totalRecords / this.pageSize);
    }
    
    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }
    
    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }
    
    get currentRowCount() {
        if (!this.treeData) return 0;
        let count = 0;
        this.treeData.forEach(org => {
            org.children.forEach(contact => {
                count += contact.children.length;
            });
        });
        return count;
    }
    
    get rowRange() {
        const start = this.offset + 1;
        const end = Math.min(this.offset + this.currentRowCount, this.totalRecords);
        return `${start}-${end} of ${this.totalRecords}`;
    }
    
    get pageInfo() {
        return `${this.currentPage} of ${this.totalPages}`;
    }
    
    @wire(getTotalCount, { viewFilters: '$selectedViewsArray' })
    wiredTotalCount({ error, data }) {
        if (data) {
            this.totalRecords = data;
        } else if (error) {
            // Handle error
        }
    }
    
    @wire(getTreeData, { viewFilters: '$selectedViewsArray', limitSize: '$pageSize', offset: '$offset' })
    wiredTreeData({ error, data }) {
        if (data) {
            this.treeData = data;
        } else if (error) {
            // Handle error
        }
    }
    
    handleViewChange(event) {
        const view = event.target.dataset.view;
        if (this.selectedViews.has(view)) {
            this.selectedViews.delete(view);
        } else {
            this.selectedViews.add(view);
        }
        this.selectedViews = new Set(this.selectedViews); // Trigger reactivity
        this.currentPage = 1;
    }
    
    handlePageSizeChange(event) {
        this.pageSize = parseInt(event.detail.value, 10);
        this.currentPage = 1;
    }
    
    handlePrevious() {
        if (!this.isPreviousDisabled) this.currentPage--;
    }
    
    handleNext() {
        if (!this.isNextDisabled) this.currentPage++;
    }
    
    toggleOrg(event) {
        const id = event.target.dataset.id;
        if (this.expandedOrgs.has(id)) {
            this.expandedOrgs.delete(id);
        } else {
            this.expandedOrgs.add(id);
        }
        this.expandedOrgs = new Set(this.expandedOrgs);
    }
    
    toggleContact(event) {
        const orgId = event.detail.orgId;
        const id = event.detail.contactId;
        let contactSet = this.expandedContacts.get(orgId) || new Set();
        if (contactSet.has(id)) {
            contactSet.delete(id);
        } else {
            contactSet.add(id);
        }
        this.expandedContacts.set(orgId, contactSet);
        this.expandedContacts = new Map(this.expandedContacts);
    }
    
    handleAddNew() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Resilient_Communication_Device__c',
                actionName: 'new'
            }
        });
    }
    
    async handleExport() {
        this.isLoading = true;
        try {
            const csv = await getCSVData({ viewFilters: this.selectedViewsArray });
            const blob = new Blob([csv], { type: 'text/csv' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'resilient_devices.csv';
            a.click();
            URL.revokeObjectURL(url);
        } catch (error) {
            // Handle error
        } finally {
            this.isLoading = false;
        }
    }
    
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'view':
            case 'edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.id,
                        objectApiName: 'Resilient_Communication_Device__c',
                        actionName: actionName
                    }
                });
                break;
            case 'delete':
                // Implement delete logic, e.g., imperative Apex call
                break;
        }
    }
}