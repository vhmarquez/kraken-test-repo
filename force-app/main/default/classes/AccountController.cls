/**
 * @description AccountController - Manages Account data retrieval for LWC components
 * @author Claude Code
 * @since 2024-11-02
 *
 * This controller provides Apex methods for the accountTable LWC component to fetch
 * Account records with proper security checks and field-level security validation.
 */
public with sharing class AccountController {
  /**
   * @description Retrieves all Account records with specific fields
   *
   * This method respects field-level security and sharing rules.
   * It returns accounts with essential fields for display in a data table.
   *
   * @return List<Account> - List of all Account records with Id, Name, Industry, Phone, AnnualRevenue, and Type
   * @throws AuraHandledException - If user lacks read access to Account object
   *
   * Example:
   *   List<Account> accounts = AccountController.getAccounts();
   *   System.assertEquals(true, accounts.size() >= 0);
   */
  @AuraEnabled(cacheable=true)
  public static List<Account> getAccounts() {
    try {
      // Check if user has access to read Account records
      if (
        !Schema.sObjectType.Account.isAccessible() ||
        !Schema.sObjectType.Account.fields.Id.isAccessible() ||
        !Schema.sObjectType.Account.fields.Name.isAccessible() ||
        !Schema.sObjectType.Account.fields.Industry.isAccessible() ||
        !Schema.sObjectType.Account.fields.Phone.isAccessible() ||
        !Schema.sObjectType.Account.fields.AnnualRevenue.isAccessible() ||
        !Schema.sObjectType.Account.fields.Type.isAccessible()
      ) {
        throw new AuraHandledException(
          'You do not have permission to read Account records.'
        );
      }

      // Query accounts with specific fields
      // LIMIT 50000 to respect governor limits and Salesforce query limits
      List<Account> accounts = [
        SELECT
          Id,
          Name,
          Industry,
          Phone,
          AnnualRevenue,
          Type
        FROM Account
        ORDER BY Name ASC
        LIMIT 50000
      ];

      return accounts;
    } catch (AuraHandledException e) {
      // Re-throw AuraHandledExceptions to send custom messages to client
      throw e;
    } catch (Exception e) {
      // Log unexpected exceptions
      System.debug(LoggingLevel.ERROR, 'AccountController.getAccounts error: ' + e.getMessage());
      throw new AuraHandledException(
        'An error occurred while retrieving accounts. Please try again.'
      );
    }
  }
}