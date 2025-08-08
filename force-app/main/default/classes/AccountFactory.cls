public with sharing class AccountFactory {
    public Account createAccount(String customerId, String customerName) {
        return new Account(
            Name = customerName,
            CustomerId__c = customerId
        );
    }
}