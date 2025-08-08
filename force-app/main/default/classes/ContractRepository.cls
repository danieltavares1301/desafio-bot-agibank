public with sharing class ContractRepository {

    public List<Contract> findAllContracts() {
        return [
            SELECT Id, Name, Status, StartDate, EndDate, ContractTerm, AccountId
            FROM Contract
        ];
    }

    public Contract findContractById(Id contractId) {
        return [
            SELECT Id, Name, Status, StartDate, EndDate, ContractTerm, AccountId
            FROM Contract
            WHERE Id = :contractId
            LIMIT 1
        ];
    }

    // Contratos por conta
    public List<Contract> findContractsByAccountId(Id accountId) {
        return [
            SELECT Id, Name, Status, StartDate, EndDate, ContractTerm, AccountId
            FROM Contract
            WHERE AccountId = :accountId
        ];
    }

    public void insertContracts(List<Contract> contracts) {
        insert contracts;
    }

    public void updateContracts(List<Contract> contracts) {
        update contracts;
    }

    public void deleteContracts(List<Contract> contracts) {
        delete contracts;
    }
}