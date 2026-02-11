import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import findArticleByUrlName from '@salesforce/apex/KnowledgeArticleController.findArticleByUrlName';

// Knowledge Article fields to query
const KNOWLEDGE_ARTICLE_FIELDS = [
  'KnowledgeArticleVersion.Id',
  'KnowledgeArticleVersion.Title',
  'KnowledgeArticleVersion.Summary',
  'KnowledgeArticleVersion.ArticleBody',
  'KnowledgeArticleVersion.PublishStatus',
  'KnowledgeArticleVersion.CreatedDate',
  'KnowledgeArticleVersion.LastModifiedDate',
  'KnowledgeArticleVersion.CreatedBy.Name',
  'KnowledgeArticleVersion.RecordType.Name',
  'KnowledgeArticleVersion.KnowledgeArticleId'
];

// Field mappings per record type
const FIELD_MAPPINGS_BY_RECORD_TYPE = {
  'FAQ': [
    { apiName: 'Question__c', label: 'Question', dataType: 'Text' },
    { apiName: 'AnswerDetails__c', label: 'Answer Details', dataType: 'RichText' }
  ],
  'How-To': [
    { apiName: 'ProcedureSteps__c', label: 'Procedure Steps', dataType: 'RichText' },
    { apiName: 'PrerequisitesText__c', label: 'Prerequisites', dataType: 'Text' },
    { apiName: 'TimeToComplete__c', label: 'Time to Complete', dataType: 'Text' }
  ],
  'Process': [
    { apiName: 'ProcessSteps__c', label: 'Process Steps', dataType: 'RichText' },
    { apiName: 'Owner__c', label: 'Process Owner', dataType: 'Text' },
    { apiName: 'OwnerEmail__c', label: 'Owner Email', dataType: 'Email' }
  ],
  'Troubleshooting': [
    { apiName: 'Problem__c', label: 'Problem', dataType: 'Text' },
    { apiName: 'Solution__c', label: 'Solution', dataType: 'RichText' },
    { apiType: 'ErrorCode__c', label: 'Error Code', dataType: 'Text' }
  ],
  'Product': [
    { apiName: 'ProductName__c', label: 'Product Name', dataType: 'Text' },
    { apiName: 'Version__c', label: 'Version', dataType: 'Text' },
    { apiName: 'Features__c', label: 'Features', dataType: 'RichText' }
  ]
};

export default class KnowledgeArticleViewer extends LightningElement {
  @api recordId;
  @api objectApiName = 'KnowledgeArticleVersion';
  @api urlName; // Optional: For Experience Cloud URL binding

  @track articleData = {};
  @track isLoading = false;
  @track error = null;
  @track additionalFields = [];
  @track relatedArticles = [];
  @track effectiveRecordId = null; // Direct property for @wire to watch

  richTextContentSet = false;

  // Getters for computed properties
  get isEmpty() {
    return !this.isLoading && !this.error && !this.articleData.Id;
  }

  get hasAdditionalFields() {
    return this.additionalFields && this.additionalFields.length > 0;
  }

  get hasRelatedArticles() {
    return this.relatedArticles && this.relatedArticles.length > 0;
  }

  get sanitizedArticleBody() {
    if (!this.articleData.ArticleBody) {
      return '';
    }
    return this.sanitizeHtml(this.articleData.ArticleBody);
  }

  get statusBadgeClass() {
    const baseClass = 'status-badge';
    const status = (this.articleData.PublishStatus || '').toLowerCase();

    switch (status) {
      case 'published':
        return `${baseClass} status-badge--published`;
      case 'draft':
        return `${baseClass} status-badge--draft`;
      case 'archived':
        return `${baseClass} status-badge--archived`;
      default:
        return baseClass;
    }
  }

  get createdDateFormatted() {
    return this.formatDate(this.articleData.CreatedDate);
  }

  get lastModifiedDateFormatted() {
    return this.formatDate(this.articleData.LastModifiedDate);
  }

  /**
   * Lifecycle: Component initialization
   */
  connectedCallback() {
    this.isLoading = true;
    console.log('[KnowledgeArticleViewer] connectedCallback started');
    console.log('[KnowledgeArticleViewer] recordId:', this.recordId);
    console.log('[KnowledgeArticleViewer] urlName:', this.urlName);
    console.log('[KnowledgeArticleViewer] window.location.pathname:', window.location.pathname);

    // Priority 1: Use explicit recordId if provided
    if (this.recordId) {
      console.log('[KnowledgeArticleViewer] Using explicit recordId:', this.recordId);
      this.effectiveRecordId = this.recordId;
      console.log('[KnowledgeArticleViewer] Set effectiveRecordId to:', this.effectiveRecordId);
      return;
    }

    // Priority 2: Try to extract URL name from property and resolve to recordId
    if (this.urlName) {
      console.log('[KnowledgeArticleViewer] Using explicit urlName property:', this.urlName);
      this.resolveArticleFromUrlName(this.urlName);
      return;
    }

    // Priority 3: Extract URL name from current page URL (Experience Cloud pattern: /article/:urlName)
    const extractedUrlName = this.extractUrlNameFromPageUrl();
    if (extractedUrlName) {
      console.log('[KnowledgeArticleViewer] Extracted URL name from page URL:', extractedUrlName);
      this.resolveArticleFromUrlName(extractedUrlName);
      return;
    }

    // No record ID or URL name found
    console.log('[KnowledgeArticleViewer] No record ID or URL name found - displaying error');
    this.isLoading = false;
    this.error = 'No record ID or article URL name provided to the component.';
  }

  /**
   * Lifecycle: Component rendered - set rich text content manually
   */
  renderedCallback() {
    console.log('[KnowledgeArticleViewer] renderedCallback called');
    console.log('[KnowledgeArticleViewer] articleData.ArticleBody:', this.articleData.ArticleBody ? 'present' : 'missing');
    console.log('[KnowledgeArticleViewer] richTextContentSet:', this.richTextContentSet);

    // Set rich text HTML content after rendering
    if (this.articleData.ArticleBody && !this.richTextContentSet) {
      console.log('[KnowledgeArticleViewer] Attempting to set rich text content...');
      const richTextElement = this.template.querySelector('[lwc:ref="richTextContent"]');
      console.log('[KnowledgeArticleViewer] richTextElement found:', !!richTextElement);

      if (richTextElement) {
        console.log('[KnowledgeArticleViewer] Setting innerHTML with sanitized article body');
        richTextElement.innerHTML = this.sanitizedArticleBody;
        this.richTextContentSet = true;
        console.log('[KnowledgeArticleViewer] Rich text content set successfully');
      } else {
        console.warn('[KnowledgeArticleViewer] Could not find richTextContent element');
      }
    }
  }

  /**
   * Wire service: Fetch knowledge article details
   */
  @wire(getRecord, {
    recordId: '$effectiveRecordId',
    fields: '$KNOWLEDGE_ARTICLE_FIELDS'
  })
  wireGetRecord({ error, data }) {
    console.log('[KnowledgeArticleViewer] @wire(getRecord) triggered');
    console.log('[KnowledgeArticleViewer] effectiveRecordId:', this.effectiveRecordId);
    console.log('[KnowledgeArticleViewer] wireGetRecord data:', data);
    console.log('[KnowledgeArticleViewer] wireGetRecord error:', error);

    if (data) {
      console.log('[KnowledgeArticleViewer] Article data received successfully');
      this.isLoading = false;
      this.handleArticleData(data);
    } else if (error) {
      console.error('[KnowledgeArticleViewer] Error fetching article:', error);
      this.isLoading = false;
      this.error = this.formatErrorMessage(error);
    } else {
      console.log('[KnowledgeArticleViewer] wireGetRecord: waiting for data or pending...');
    }
  }

  /**
   * Process article data and build field mappings
   */
  handleArticleData(data) {
    try {
      console.log('[KnowledgeArticleViewer] handleArticleData called');

      // Extract article data
      this.articleData = {
        Id: getFieldValue(data, 'KnowledgeArticleVersion.Id'),
        Title: getFieldValue(data, 'KnowledgeArticleVersion.Title'),
        Summary: getFieldValue(data, 'KnowledgeArticleVersion.Summary'),
        ArticleBody: getFieldValue(data, 'KnowledgeArticleVersion.ArticleBody'),
        PublishStatus: getFieldValue(data, 'KnowledgeArticleVersion.PublishStatus'),
        CreatedDate: getFieldValue(data, 'KnowledgeArticleVersion.CreatedDate'),
        LastModifiedDate: getFieldValue(data, 'KnowledgeArticleVersion.LastModifiedDate'),
        CreatedBy: getFieldValue(data, 'KnowledgeArticleVersion.CreatedBy'),
        RecordType: getFieldValue(data, 'KnowledgeArticleVersion.RecordType'),
        KnowledgeArticleId: getFieldValue(data, 'KnowledgeArticleVersion.KnowledgeArticleId')
      };

      console.log('[KnowledgeArticleViewer] Extracted article data:', this.articleData);

      // Validate article loaded
      if (!this.articleData.Id) {
        console.warn('[KnowledgeArticleViewer] No article ID found in data');
        this.error = 'Unable to load article details.';
        return;
      }

      console.log('[KnowledgeArticleViewer] Article loaded successfully with ID:', this.articleData.Id);

      // Build dynamic fields based on record type
      this.buildDynamicFields();
    } catch (error) {
      console.error('[KnowledgeArticleViewer] Error processing article data:', error);
      this.error = 'Error processing article data: ' + (error.message || error);
    }
  }

  /**
   * Build dynamic fields based on record type
   */
  buildDynamicFields() {
    try {
      const recordTypeName = this.articleData.RecordType?.Name || 'Default';
      console.log('[KnowledgeArticleViewer] buildDynamicFields - Record Type:', recordTypeName);

      const fieldMapping = FIELD_MAPPINGS_BY_RECORD_TYPE[recordTypeName] || [];
      console.log('[KnowledgeArticleViewer] Field mapping found:', fieldMapping.length, 'fields');

      // Map fields to display format
      this.additionalFields = fieldMapping.map(fieldConfig => {
        const value = this.articleData[fieldConfig.apiName] || '';
        console.log('[KnowledgeArticleViewer] Field:', fieldConfig.apiName, 'Value:', value);

        return {
          apiName: fieldConfig.apiName,
          label: fieldConfig.label,
          value: value,
          displayValue: this.formatFieldValue(value, fieldConfig.dataType),
          isUrl: fieldConfig.dataType === 'Email' || fieldConfig.dataType === 'Url'
        };
      });

      console.log('[KnowledgeArticleViewer] buildDynamicFields completed successfully');
    } catch (error) {
      console.error('[KnowledgeArticleViewer] Error building dynamic fields:', error);
    }
  }

  /**
   * Format field values based on data type
   */
  formatFieldValue(value, dataType) {
    if (!value) {
      return '—';
    }

    switch (dataType) {
      case 'Date':
        return this.formatDate(value);
      case 'DateTime':
        return this.formatDateTime(value);
      case 'Email':
        return value; // Keep as-is for mailto link
      case 'Url':
        return value;
      case 'Number':
        return Number(value).toLocaleString();
      case 'Currency':
        return new Intl.NumberFormat('en-US', {
          style: 'currency',
          currency: 'USD'
        }).format(value);
      case 'RichText':
      case 'Text':
      default:
        return value;
    }
  }

  /**
   * Format date to readable format
   */
  formatDate(dateString) {
    if (!dateString) {
      return '—';
    }

    try {
      const date = new Date(dateString);
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      });
    } catch (error) {
      return dateString;
    }
  }

  /**
   * Format date and time to readable format
   */
  formatDateTime(dateTimeString) {
    if (!dateTimeString) {
      return '—';
    }

    try {
      const date = new Date(dateTimeString);
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (error) {
      return dateTimeString;
    }
  }

  /**
   * Sanitize HTML content to prevent XSS
   */
  sanitizeHtml(htmlString) {
    console.log('[KnowledgeArticleViewer] sanitizeHtml called with length:', htmlString?.length || 0);

    if (!htmlString) {
      return '';
    }

    try {
      // Create a temporary DOM element to parse HTML
      const temp = document.createElement('div');
      temp.innerHTML = htmlString;

      console.log('[KnowledgeArticleViewer] HTML parsed, child nodes count:', temp.childNodes.length);

      // List of allowed tags
      const allowedTags = [
        'P', 'BR', 'STRONG', 'B', 'EM', 'I', 'U', 'S', 'STRIKE',
        'H1', 'H2', 'H3', 'H4', 'H5', 'H6',
        'UL', 'OL', 'LI',
        'A', 'IMG', 'DIV', 'SPAN', 'BLOCKQUOTE',
        'PRE', 'CODE', 'TABLE', 'TR', 'TD', 'TH', 'THEAD', 'TBODY'
      ];

      const allowedAttributes = {
        'A': ['href', 'title', 'target'],
        'IMG': ['src', 'alt', 'title', 'width', 'height'],
        'DIV': ['class'],
        'SPAN': ['class'],
        'TABLE': ['class'],
        'TR': ['class'],
        'TD': ['class'],
        'TH': ['class']
      };

      // Remove disallowed elements and attributes
      this.cleanNode(temp, allowedTags, allowedAttributes);

      const sanitized = temp.innerHTML;
      console.log('[KnowledgeArticleViewer] Sanitization complete, sanitized length:', sanitized.length);
      return sanitized;
    } catch (error) {
      console.error('[KnowledgeArticleViewer] Error during HTML sanitization:', error);
      return htmlString; // Return original if sanitization fails
    }
  }

  /**
   * Recursively clean DOM nodes to remove unsafe content
   */
  cleanNode(node, allowedTags, allowedAttributes) {
    if (node.nodeType === 3) {
      // Text node - keep as is
      return;
    }

    if (node.nodeType === 1) {
      // Element node
      const tagName = node.tagName.toUpperCase();

      if (!allowedTags.includes(tagName)) {
        // Replace disallowed tag with its text content
        const textContent = node.textContent;
        node.parentNode?.replaceChild(document.createTextNode(textContent), node);
        return;
      }

      // Remove disallowed attributes
      const allowedAttrs = allowedAttributes[tagName] || [];
      const attrs = Array.from(node.attributes);

      attrs.forEach(attr => {
        if (!allowedAttrs.includes(attr.name.toLowerCase())) {
          node.removeAttribute(attr.name);
        }

        // Additional security: check for javascript: protocol
        if (attr.value && attr.value.toLowerCase().includes('javascript:')) {
          node.removeAttribute(attr.name);
        }
      });

      // Recursively clean child nodes
      Array.from(node.childNodes).forEach(child => {
        this.cleanNode(child, allowedTags, allowedAttributes);
      });
    }
  }

  /**
   * Error Handling: Retry loading article
   */
  handleRetry() {
    console.log('[KnowledgeArticleViewer] Retry button clicked');
    this.isLoading = true;
    this.error = null;
    // Re-trigger @wire by toggling effectiveRecordId
    const currentId = this.effectiveRecordId;
    this.effectiveRecordId = null;
    // Use setTimeout to ensure the property change propagates
    setTimeout(() => {
      console.log('[KnowledgeArticleViewer] Restoring effectiveRecordId to:', currentId);
      this.effectiveRecordId = currentId;
    }, 0);
  }

  /**
   * Navigation: Handle related article click
   */
  handleRelatedArticleClick(event) {
    event.preventDefault();
    const articleId = event.currentTarget.getAttribute('data-id');

    // Dispatch custom event for parent component to handle navigation
    this.dispatchEvent(
      new CustomEvent('articlenavigation', {
        detail: { articleId },
        bubbles: true,
        composed: true
      })
    );
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
    return 'An unexpected error occurred while loading the article.';
  }

  /**
   * URL Binding: Extract URL name from Experience Cloud page URL
   * Handles URL pattern: /article/:urlName
   */
  extractUrlNameFromPageUrl() {
    try {
      const currentUrl = window.location.pathname;
      console.log('[KnowledgeArticleViewer] Attempting to extract URL name from pathname:', currentUrl);

      // Match /article/:urlName pattern
      const match = currentUrl.match(/\/article\/([^/?]+)/);
      console.log('[KnowledgeArticleViewer] Regex match result:', match);

      if (match && match[1]) {
        const urlName = decodeURIComponent(match[1]);
        console.log('[KnowledgeArticleViewer] Successfully extracted URL name:', urlName);
        return urlName;
      }

      console.log('[KnowledgeArticleViewer] No URL name found in current path');
    } catch (error) {
      console.error('[KnowledgeArticleViewer] Error extracting URL name from page URL:', error);
    }
    return null;
  }

  /**
   * URL Binding: Resolve article record ID from URL name
   * Calls Apex method to find KnowledgeArticleVersion by UrlName
   */
  async resolveArticleFromUrlName(urlName) {
    try {
      console.log('[KnowledgeArticleViewer] resolveArticleFromUrlName called with:', urlName);

      if (!urlName) {
        throw new Error('Invalid URL name provided');
      }

      this.isLoading = true;
      this.error = null;

      console.log('[KnowledgeArticleViewer] Calling Apex method findArticleByUrlName...');
      const recordId = await findArticleByUrlName({ urlName });

      console.log('[KnowledgeArticleViewer] Apex returned recordId:', recordId);

      if (recordId) {
        console.log('[KnowledgeArticleViewer] Article found! Setting effectiveRecordId:', recordId);
        this.effectiveRecordId = recordId;
        console.log('[KnowledgeArticleViewer] Setting effectiveRecordId triggers @wire(getRecord) automatically');
      } else {
        console.warn('[KnowledgeArticleViewer] No article found for URL name:', urlName);
        this.isLoading = false;
        this.error = `Knowledge Article "${urlName}" not found.`;
      }
    } catch (error) {
      console.error('[KnowledgeArticleViewer] Error resolving article from URL name:', error);
      this.isLoading = false;
      this.error = this.formatErrorMessage(error);
    }
  }
}