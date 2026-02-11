/**
 * @description Lightning Web Component for displaying ESCC Devices in a hierarchical tree structure
 * Implements filtering, pagination, and CSV export functionality
 * @author Victor Marquez
 * @date 2025-10-11
 * @see designs/eisacEsccDevices/specs.md for complete design specifications
 */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getDeviceData from '@salesforce/apex/EisacEsccDevicesController.getDeviceData';
import exportToCSV from '@salesforce/apex/EisacEsccDevicesController.exportToCSV';

export default class EisacEsccDevices extends NavigationMixin(LightningElement) {
    // Public property for component title (configurable in App Builder)
    @api title = 'ESCC Devices';

    // Filter options
    @track filters = {
        eisac: true,
        myOrg: true,
        mine: true
    };

    // Pagination
    @track pageSize = 10;
    @track currentPage = 1;
    @track totalPages = 0;
    @track totalOrganizations = 0;

    // Data
    @track organizations = [];
    @track isLoading = false;
    @track error = null;

    // Page size options for dropdown
    pageSizeOptions = [
        { label: '10', value: 10 },
        { label: '25', value: 25 },
        { label: '50', value: 50 }
    ];

    /**
     * @description Lifecycle hook - called when component is inserted into DOM
     */
    connectedCallback() {
        this.loadDeviceData();
    }

    /**
     * @description Computed property for active filter type
     * @returns {String} Current filter type ('eisac', 'myorg', or 'mine')
     */
    get activeFilter() {
        if (this.filters.mine && !this.filters.eisac && !this.filters.myOrg) {
            return 'mine';
        } else if (this.filters.myOrg && !this.filters.eisac && !this.filters.mine) {
            return 'myorg';
        }
        return 'eisac';
    }

    /**
     * @description Computed property to check if there's no data
     * @returns {Boolean} True if no organizations found
     */
    get hasNoData() {
        return !this.isLoading && this.organizations.length === 0;
    }

    /**
     * @description Computed property to check if previous page button should be disabled
     * @returns {Boolean} True if on first page
     */
    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }

    /**
     * @description Computed property to check if next page button should be disabled
     * @returns {Boolean} True if on last page
     */
    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    /**
     * @description Computed property for pagination display text
     * @returns {String} Pagination text like "1-7 of 7"
     */
    get paginationText() {
        if (this.totalOrganizations === 0) {
            return '0 of 0';
        }
        const start = ((this.currentPage - 1) * this.pageSize) + 1;
        const end = Math.min(this.currentPage * this.pageSize, this.totalOrganizations);
        return `${start}-${end} of ${this.totalOrganizations}`;
    }

    /**
     * @description Computed property for page number display
     * @returns {String} Page number like "1 of 1"
     */
    get pageNumberText() {
        return `${this.currentPage} of ${this.totalPages || 1}`;
    }

    /**
     * @description Loads device data from Apex controller
     */
    async loadDeviceData() {
        this.isLoading = true;
        this.error = null;

        try {
            const result = await getDeviceData({
                filterType: this.activeFilter,
                pageSize: this.pageSize,
                pageNumber: this.currentPage
            });

            this.organizations = result.organizations.map(org => ({
                ...org,
                _cssClass: 'org-row',
                _chevronIcon: 'utility:chevronright'
            }));

            this.totalOrganizations = result.totalOrganizations;
            this.totalPages = result.totalPages;
            this.currentPage = result.currentPage;

        } catch (error) {
            this.error = error;
            this.showErrorToast('Error fetching devices', error.body?.message || error.message);
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * @description Handles filter checkbox changes
     * @param {Event} event Change event from checkbox
     */
    handleFilterChange(event) {
        const filterName = event.target.dataset.filter;
        this.filters[filterName] = event.target.checked;

        // Reset to first page when filter changes
        this.currentPage = 1;
        this.loadDeviceData();
    }

    /**
     * @description Handles page size dropdown change
     * @param {Event} event Change event from combobox
     */
    handlePageSizeChange(event) {
        this.pageSize = parseInt(event.detail.value, 10);
        this.currentPage = 1; // Reset to first page
        this.loadDeviceData();
    }

    /**
     * @description Handles previous page button click
     */
    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadDeviceData();
        }
    }

    /**
     * @description Handles next page button click
     */
    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.loadDeviceData();
        }
    }

    /**
     * @description Handles organization row click to expand/collapse
     * @param {Event} event Click event
     */
    handleOrganizationClick(event) {
        const orgId = event.currentTarget.dataset.id;
        const orgIndex = this.organizations.findIndex(org => org.id === orgId);

        if (orgIndex !== -1) {
            this.organizations[orgIndex].isExpanded = !this.organizations[orgIndex].isExpanded;
            this.organizations[orgIndex]._chevronIcon = this.organizations[orgIndex].isExpanded
                ? 'utility:chevrondown'
                : 'utility:chevronright';
            this.organizations = [...this.organizations]; // Trigger reactivity
        }
    }

    /**
     * @description Handles contact row click to expand/collapse
     * @param {Event} event Click event
     */
    handleContactClick(event) {
        const orgId = event.currentTarget.dataset.orgId;
        const contactId = event.currentTarget.dataset.contactId;

        const orgIndex = this.organizations.findIndex(org => org.id === orgId);
        if (orgIndex !== -1) {
            const contactIndex = this.organizations[orgIndex].contacts.findIndex(
                contact => contact.id === contactId
            );

            if (contactIndex !== -1) {
                this.organizations[orgIndex].contacts[contactIndex].isExpanded =
                    !this.organizations[orgIndex].contacts[contactIndex].isExpanded;
                this.organizations = [...this.organizations]; // Trigger reactivity
            }
        }
    }

    /**
     * @description Handles edit action for a device
     * @param {Event} event Click event
     */
    handleEditDevice(event) {
        const deviceId = event.currentTarget.dataset.deviceId;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: deviceId,
                objectApiName: 'Resilient_Communication_Device__c',
                actionName: 'edit'
            }
        });
    }

    /**
     * @description Handles add new device button click
     */
    handleAddDevice() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Resilient_Communication_Device__c',
                actionName: 'new'
            }
        });
    }

    /**
     * @description Handles export to CSV button click
     */
    async handleExportCSV() {
        try {
            const csvData = await exportToCSV({ filterType: this.activeFilter });

            // Create blob and download
            const blob = new Blob([csvData], { type: 'text/csv;charset=utf-8;' });
            const link = document.createElement('a');
            const url = URL.createObjectURL(blob);

            link.setAttribute('href', url);
            link.setAttribute('download', `escc_devices_${new Date().getTime()}.csv`);
            link.style.visibility = 'hidden';

            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            this.showSuccessToast('Success', 'Devices exported successfully');

        } catch (error) {
            this.showErrorToast('Error exporting CSV', error.body?.message || error.message);
        }
    }

    /**
     * @description Shows error toast notification
     * @param {String} title Toast title
     * @param {String} message Toast message
     */
    showErrorToast(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: 'error',
                mode: 'sticky'
            })
        );
    }

    /**
     * @description Shows success toast notification
     * @param {String} title Toast title
     * @param {String} message Toast message
     */
    showSuccessToast(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: 'success'
            })
        );
    }

    /**
     * @description Returns chevron icon name based on expanded state
     * @param {Boolean} isExpanded Expanded state
     * @returns {String} Icon name
     */
    getChevronIcon(isExpanded) {
        return isExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }
}