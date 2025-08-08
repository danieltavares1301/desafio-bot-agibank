public with sharing class AccountRepository {
    
    public List<Account> findAllAccounts() {
        return [
            SELECT Id, Name, Industry, CustomerId__c
            FROM Account
        ];
    }

    public Account findAccountById(Id accountId) {
        return [
            SELECT Id, Name, Industry, CustomerId__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
    }

    public Account findAccountByCustomerId(String customerId) {
        List<Account> rows = [
            SELECT Id, Name, Industry, CustomerId__c
            FROM Account
            WHERE CustomerId__c = :customerId
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    public void insertAccounts(List<Account> accounts) {
        insert accounts;
    }

    public void updateAccounts(List<Account> accounts) {
        update accounts;
    }

    public void deleteAccounts(List<Account> accounts) {
        delete accounts;
    }
}