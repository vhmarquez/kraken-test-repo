public with sharing class VibeAccountTableController {
    public class PagedResult {
        @AuraEnabled public List<Account> records;
        @AuraEnabled public Integer totalRecords;
        @AuraEnabled public Integer pageNumber;
        @AuraEnabled public Integer pageSize;
        public PagedResult(List<Account> recs, Integer total, Integer pageNum, Integer size) {
            this.records = recs;
            this.totalRecords = total;
            this.pageNumber = pageNum;
            this.pageSize = size;
        }
    }

    @AuraEnabled(cacheable=true)
    public static PagedResult getAccounts(Integer pageNumber, Integer pageSize, String sortBy, String sortDirection, String searchKey) {
        // Defaults and guards
        Integer safePageSize = (pageSize == null || pageSize <= 0) ? 10 : pageSize;
        Integer safePageNumber = (pageNumber == null || pageNumber <= 0) ? 1 : pageNumber;

        // Whitelist allowed sort fields to avoid SOQL injection
        Set<String> allowedSorts = new Set<String>{ 'Name', 'Type', 'Industry', 'Phone', 'Website', 'CreatedDate', 'LastModifiedDate' };
        String safeSortBy = (sortBy != null && allowedSorts.contains(sortBy)) ? sortBy : 'Name';
        String safeSortDirection = (sortDirection != null && sortDirection.equalsIgnoreCase('DESC')) ? 'DESC' : 'ASC';

        // Build WHERE clause using bind variables
        String likeKey = null;
        Boolean hasSearch = (searchKey != null && String.valueOf(searchKey).trim().length() > 0);
        if (hasSearch) {
            likeKey = '%' + String.valueOf(searchKey).trim() + '%';
        }

        String baseWhere = '';
        if (hasSearch) {
            baseWhere = ' WHERE (Name LIKE :likeKey OR Phone LIKE :likeKey OR Website LIKE :likeKey)';
        }

        // Count total records
        Integer totalRecords;
        if (hasSearch) {
            totalRecords = (Integer)Database.countQuery('SELECT COUNT() FROM Account' + baseWhere);
        } else {
            totalRecords = (Integer)Database.countQuery('SELECT COUNT() FROM Account');
        }

        Integer offsetSize = (safePageNumber - 1) * safePageSize;

        // Build the dynamic query for page data
        String query =
            'SELECT Id, Name, Type, Industry, Phone, Website ' +
            'FROM Account' +
            baseWhere +
            ' ORDER BY ' + safeSortBy + ' ' + safeSortDirection +
            ' LIMIT :safePageSize OFFSET :offsetSize';

        // Run query with binds
        List<Account> rows;
        if (hasSearch) {
            rows = Database.query(query);
        } else {
            rows = Database.query(query);
        }

        return new PagedResult(rows, totalRecords, safePageNumber, safePageSize);
    }
}