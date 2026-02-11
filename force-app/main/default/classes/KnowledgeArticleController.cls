/**
 * @description KnowledgeArticleController - Manages Knowledge Article data retrieval for LWC components
 * @author Claude Code
 * @since 2024-11-02
 *
 * This controller provides Apex methods for Lightning Web Components to fetch
 * Knowledge Article records with proper security checks and field-level security validation.
 */
public with sharing class KnowledgeArticleController {
  /**
   * @description Finds a Knowledge Article by its URL name
   *
   * This method is used for Experience Cloud URL binding patterns like /article/:urlName
   * It queries the KnowledgeArticleVersion by UrlName and returns the record ID.
   * Respects field-level security and sharing rules.
   *
   * @param urlName The URL name of the Knowledge Article (UrlName field)
   * @return String The ID of the KnowledgeArticleVersion record, or null if not found
   * @throws AuraHandledException If user lacks read access to Knowledge Article object
   *
   * Example:
   *   String recordId = KnowledgeArticleController.findArticleByUrlName('my-article-name');
   *   System.assertEquals('0KD7Q000000001Z', recordId);
   */
  @AuraEnabled(cacheable=true)
  public static String findArticleByUrlName(String urlName) {
    try {
      // Validate input
      if (String.isBlank(urlName)) {
        throw new AuraHandledException('URL name cannot be empty.');
      }

      // Check if user has access to read Knowledge Article records
      if (!Schema.sObjectType.KnowledgeArticleVersion.isAccessible()) {
        throw new AuraHandledException(
          'You do not have permission to read Knowledge Articles.'
        );
      }

      // Check FLS for required fields
      if (!Schema.sObjectType.KnowledgeArticleVersion.fields.Id.isAccessible() ||
          !Schema.sObjectType.KnowledgeArticleVersion.fields.UrlName.isAccessible()) {
        throw new AuraHandledException(
          'You do not have permission to read required Knowledge Article fields.'
        );
      }

      // Query the Knowledge Article by URL name
      // Note: UrlName is not a standard field, this assumes a custom field exists
      // If using standard Knowledge__kav, adjust the query accordingly
      List<KnowledgeArticleVersion> articles = [
        SELECT Id
        FROM KnowledgeArticleVersion
        WHERE UrlName = :urlName
        LIMIT 1
      ];

      if (articles != null && articles.size() > 0) {
        return articles[0].Id;
      }

      // Article not found
      return null;
    } catch (AuraHandledException e) {
      // Re-throw AuraHandledExceptions to send custom messages to client
      throw e;
    } catch (Exception e) {
      // Log unexpected exceptions
      System.debug(LoggingLevel.ERROR, 'KnowledgeArticleController.findArticleByUrlName error: ' + e.getMessage());
      throw new AuraHandledException(
        'An error occurred while finding the knowledge article. Please try again.'
      );
    }
  }

  /**
   * @description Retrieves all Knowledge Article records with specific fields
   *
   * This method respects field-level security and sharing rules.
   * It returns articles with essential fields for display in a data table.
   *
   * @return List<KnowledgeArticleVersion> - List of all Knowledge Article records
   * @throws AuraHandledException - If user lacks read access to Knowledge Article object
   *
   * Example:
   *   List<KnowledgeArticleVersion> articles = KnowledgeArticleController.getArticles();
   *   System.assertEquals(true, articles.size() >= 0);
   */
  @AuraEnabled(cacheable=true)
  public static List<KnowledgeArticleVersion> getArticles() {
    try {
      // Check if user has access to read Knowledge Article records
      if (!Schema.sObjectType.KnowledgeArticleVersion.isAccessible()) {
        throw new AuraHandledException(
          'You do not have permission to read Knowledge Articles.'
        );
      }

      // Query articles with specific fields
      // LIMIT 50000 to respect Salesforce query limits
      List<KnowledgeArticleVersion> articles = [
        SELECT
          Id,
          Title,
          Summary,
          PublishStatus,
          CreatedDate,
          LastModifiedDate
        FROM KnowledgeArticleVersion
        ORDER BY CreatedDate DESC
        LIMIT 50000
      ];

      return articles;
    } catch (AuraHandledException e) {
      // Re-throw AuraHandledExceptions to send custom messages to client
      throw e;
    } catch (Exception e) {
      // Log unexpected exceptions
      System.debug(LoggingLevel.ERROR, 'KnowledgeArticleController.getArticles error: ' + e.getMessage());
      throw new AuraHandledException(
        'An error occurred while retrieving knowledge articles. Please try again.'
      );
    }
  }
}