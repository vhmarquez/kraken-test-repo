import { LightningElement, track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

export default class AccountTable extends LightningElement {
  // Pagination Settings
  pageSize = 10;
  @track currentPage = 1;
  @track totalRecords = 0;
  @track totalPages = 0;

  // Data Management
  @track data = [];
  @track allAccounts = [];
  @track isLoading = false;
  @track error = null;

  // Computed Properties
  get isEmpty() {
    return !this.isLoading && this.totalRecords === 0 && !this.error;
  }

  get isFirstPage() {
    return this.currentPage === 1;
  }

  get isLastPage() {
    return this.currentPage === this.totalPages;
  }

  // Datatable Column Definitions
  get columns() {
    return [
      {
        label: 'Account Name',
        fieldName: 'Name',
        type: 'text',
        sortable: false,
        cellAttributes: {
          class: { fieldName: 'nameClass' }
        }
      },
      {
        label: 'Industry',
        fieldName: 'Industry',
        type: 'text',
        sortable: false
      },
      {
        label: 'Phone',
        fieldName: 'Phone',
        type: 'phone',
        sortable: false
      },
      {
        label: 'Annual Revenue',
        fieldName: 'AnnualRevenue',
        type: 'currency',
        sortable: false,
        cellAttributes: {
          alignment: 'left'
        }
      },
      {
        label: 'Type',
        fieldName: 'Type',
        type: 'text',
        sortable: false
      }
    ];
  }

  /**
   * Lifecycle: Component initialization
   */
  connectedCallback() {
    this.loadAccounts();
  }

  /**
   * Fetches all accounts from Apex controller
   */
  async loadAccounts() {
    this.isLoading = true;
    this.error = null;

    try {
      // Call Apex method to get all accounts
      const result = await getAccounts();

      if (result && result.length > 0) {
        this.allAccounts = result;
        this.totalRecords = result.length;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        this.currentPage = 1;

        // Load first page of data
        this.updatePageData();
      } else {
        this.allAccounts = [];
        this.totalRecords = 0;
        this.totalPages = 0;
        this.data = [];
      }
    } catch (error) {
      this.error = this.formatErrorMessage(error);
      console.error('Error fetching accounts:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Updates the data property with current page records
   */
  updatePageData() {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = startIndex + this.pageSize;

    // Slice the array to get the current page records
    this.data = this.allAccounts.slice(startIndex, endIndex);
  }

  /**
   * Navigation: Move to next page
   */
  handleNextPage() {
    if (!this.isLastPage) {
      this.currentPage += 1;
      this.updatePageData();
      this.scrollToTop();
    }
  }

  /**
   * Navigation: Move to previous page
   */
  handlePreviousPage() {
    if (!this.isFirstPage) {
      this.currentPage -= 1;
      this.updatePageData();
      this.scrollToTop();
    }
  }

  /**
   * Error Handling: Retry loading accounts
   */
  handleRetry() {
    this.loadAccounts();
  }

  /**
   * Utility: Scroll to top of component
   */
  scrollToTop() {
    // Scroll to the lightning-card top
    const card = this.template.querySelector('lightning-card');
    if (card) {
      card.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }

  /**
   * Utility: Format error messages for display
   */
  formatErrorMessage(error) {
    if (error.body && error.body.message) {
      return error.body.message;
    } else if (error.message) {
      return error.message;
    } else if (typeof error === 'string') {
      return error;
    }
    return 'An unexpected error occurred while loading accounts.';
  }
}