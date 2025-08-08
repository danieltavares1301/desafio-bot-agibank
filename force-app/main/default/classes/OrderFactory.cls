public with sharing class OrderFactory {
    public Order createOrder(Id accountId, Id contractId, OrderAPIResponse apiResponse) {
        return new Order(
            AccountId     = accountId,
            ContractId    = contractId,
            Status        = apiResponse.status,
            EndDate       = DateUtils.parseDate(apiResponse.deliveryDate),
            EffectiveDate = Date.today(),
            OrderExternalId__c = apiResponse.orderNumber
        );
    }
}