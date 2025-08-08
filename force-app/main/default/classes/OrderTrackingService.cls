public with sharing class OrderTrackingService {

    public class AppResponse {
        public String status;
        public String deliveryDate;
    }

    private final OrdersApiClient     api;
    private final OrderRepository     orderRepo;
    private final AccountRepository   accRepo;
    private final ContractRepository  conRepo;
    private final OrderFactory        orderFactory;
    private final AccountFactory      accFactory;
    private final ContractFactory     conFactory;

    public OrderTrackingService(
        OrdersApiClient api,
        OrderRepository orderRepo,
        AccountRepository accRepo,
        ContractRepository conRepo,
        OrderFactory orderFactory,
        AccountFactory accFactory,
        ContractFactory conFactory
    ){
        this.api          = api;
        this.orderRepo    = orderRepo;
        this.accRepo      = accRepo;
        this.conRepo      = conRepo;
        this.orderFactory = orderFactory;
        this.accFactory   = accFactory;
        this.conFactory   = conFactory;
    }

    public AppResponse handle(String orderNumber, Boolean readOnly){
        AppResponse resp = new AppResponse();

        OrderAPIResponse dto;
        try {
            dto = api.getByNumber(orderNumber);
        } catch (OrdersApiClient.IntegrationException ex) {
            resp.status = 'Falha na integração';
            return resp;
        }

        if (dto == null) {
            resp.status = 'Pedido não encontrado';
            return resp;
        }

        resp.status       = dto.status;
        resp.deliveryDate = dto.deliveryDate;

        if (readOnly == true) {
            return resp; // sem DML
        }

        // Tenta achar Order pelo ExternalId
        Order existing = orderRepo.findOrderByExternalId(dto.orderNumber);
        if (existing != null) {
            existing.Status  = dto.status;
            existing.EndDate = DateUtils.parseDate(dto.deliveryDate);
            orderRepo.updateOrders(new List<Order>{ existing });
            return resp;
        }

        Account acc;
        try {
            acc = accRepo.findAccountByCustomerId(dto.customerId);
        } catch (Exception e) {
            acc = null;
        }
        if (acc == null) {
            acc = accFactory.createAccount(dto.customerId, dto.customerName);
            accRepo.insertAccounts(new List<Account>{ acc });
        }

        Contract con = conFactory.createContract(acc.Id, dto.customerName);
        conRepo.insertContracts(new List<Contract>{ con });

        Order newOrd = orderFactory.createOrder(acc.Id, con.Id, dto);
        orderRepo.insertOrders(new List<Order>{ newOrd });

        return resp;
    }
}