public with sharing class ContractFactory {
    private static final Integer DEFAULT_CONTRACT_TERM = 24;
    private static final String DEFAULT_STATUS = 'Draft';

    public Contract createContract(Id accountId, String customerName) {
        return new Contract(
            AccountId   = accountId,
            Status      = DEFAULT_STATUS,
            StartDate   = Date.today(),
            ContractTerm= DEFAULT_CONTRACT_TERM,
            Name        = 'Contrato - ' + customerName
        );
    }
}