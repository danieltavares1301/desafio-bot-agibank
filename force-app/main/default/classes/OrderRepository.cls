public with sharing class OrderRepository {

    public List<Order> findAllOrders() {
        return [
            SELECT Id, OrderNumber, Status, EndDate, EffectiveDate, AccountId, ContractId, OrderExternalId__c
            FROM Order
        ];
    }

    public Order findOrderById(Id orderId) {
        List<Order> rows = [
            SELECT Id, OrderNumber, Status, EndDate, EffectiveDate, AccountId, ContractId, OrderExternalId__c
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    // Se sua org usa o campo padrão OrderNumber para busca
    public Order findOrderByOrderNumber(String orderNumber) {
        List<Order> rows = [
            SELECT Id, OrderNumber, Status, EndDate, EffectiveDate, AccountId, ContractId, OrderExternalId__c
            FROM Order
            WHERE OrderNumber = :orderNumber
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    // Usado pelo Service → era aqui que estourava a exceção
    public Order findOrderByExternalId(String externalId) {
        List<Order> rows = [
            SELECT Id, OrderNumber, Status, EndDate, EffectiveDate, AccountId, ContractId, OrderExternalId__c
            FROM Order
            WHERE OrderExternalId__c = :externalId
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    public void insertOrders(List<Order> orders) { insert orders; }
    public void updateOrders(List<Order> orders) { update orders; }
    public void deleteOrders(List<Order> orders) { delete orders; }
}