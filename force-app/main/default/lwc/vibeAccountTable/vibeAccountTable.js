import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccounts from '@salesforce/apex/VibeAccountTableController.getAccounts';

export default class VibeAccountTable extends LightningElement {
    // Table
    columns = [
        {
            label: 'Name',
            fieldName: 'recordUrl',
            type: 'url',
            sortable: true,
            typeAttributes: { label: { fieldName: 'Name' }, target: '_self' }
        },
        { label: 'Type', fieldName: 'Type', type: 'text', sortable: true },
        { label: 'Industry', fieldName: 'Industry', type: 'text', sortable: true },
        { label: 'Phone', fieldName: 'Phone', type: 'phone', sortable: true },
        { label: 'Website', fieldName: 'Website', type: 'url', sortable: true }
    ];

    @track rows = [];
    @track loading = false;

    // Pagination/sort
    pageNumber = 1;
    pageSize = 10;
    totalRecords = 0;
    totalPages = 0;

    sortBy = 'Name';
    sortDirection = 'ASC';
    searchKey = ''; // scaffolded; not exposed in UI yet

    connectedCallback() {
        this.fetchPage();
    }

    get isFirstPage() {
        return this.pageNumber <= 1;
    }
    get isLastPage() {
        return this.totalPages === 0 || this.pageNumber >= this.totalPages;
    }
    get rangeStart() {
        if (this.totalRecords === 0) return 0;
        return (this.pageNumber - 1) * this.pageSize + 1;
    }
    get rangeEnd() {
        const end = this.pageNumber * this.pageSize;
        return end > this.totalRecords ? this.totalRecords : end;
    }

    async fetchPage() {
        this.loading = true;
        try {
            const result = await getAccounts({
                pageNumber: this.pageNumber,
                pageSize: this.pageSize,
                sortBy: this.sortBy,
                sortDirection: this.sortDirection,
                searchKey: this.searchKey
            });

            this.totalRecords = result?.totalRecords ?? 0;
            this.pageNumber = result?.pageNumber ?? this.pageNumber;
            this.pageSize = result?.pageSize ?? this.pageSize;
            this.totalPages = this.pageSize > 0 ? Math.ceil(this.totalRecords / this.pageSize) : 0;

            const data = (result?.records ?? []).map((r) => ({
                ...r,
                recordUrl: '/' + r.Id
            }));
            this.rows = data;
        } catch (e) {
            // Basic error surfacing: console + toast
            // eslint-disable-next-line no-console
            console.error(e);
            this.showToast('Error', this.reduceError(e), 'error');
        } finally {
            this.loading = false;
        }
    }

    handleFirst() {
        if (this.isFirstPage) return;
        this.pageNumber = 1;
        this.fetchPage();
    }
    handlePrevious() {
        if (this.isFirstPage) return;
        this.pageNumber = this.pageNumber - 1;
        this.fetchPage();
    }
    handleNext() {
        if (this.isLastPage) return;
        this.pageNumber = this.pageNumber + 1;
        this.fetchPage();
    }
    handleLast() {
        if (this.isLastPage) return;
        this.pageNumber = this.totalPages;
        this.fetchPage();
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        // Map url field back to Name sort
        this.sortBy = sortedBy === 'recordUrl' ? 'Name' : sortedBy;
        this.sortDirection = sortDirection?.toUpperCase() === 'DESC' ? 'DESC' : 'ASC';
        this.pageNumber = 1;
        this.fetchPage();
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    reduceError(error) {
        // Standard LWC error normalizer
        if (Array.isArray(error?.body)) {
            return error.body.map((e) => e.message).join(', ');
        } else if (typeof error?.body?.message === 'string') {
            return error.body.message;
        }
        return error?.message || 'Unknown error';
    }
}