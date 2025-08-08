public with sharing class OrderTrackingController {

    public class Request {
        @InvocableVariable(required=true) public String  orderNumber;
        @InvocableVariable               public Boolean readOnly;
    }
    public class Response {
        @InvocableVariable public String status;
        @InvocableVariable public String deliveryDate;
    }

    @InvocableMethod(label='Get Order' callout=true)
    public static List<Response> getOrderStatus(List<Request> reqs) {
        Request req = reqs[0];

        OrderTrackingService service = new OrderTrackingService(
            new OrdersApiClient(),
            new OrderRepository(),
            new AccountRepository(),
            new ContractRepository(),
            new OrderFactory(),
            new AccountFactory(),
            new ContractFactory()
        );

        OrderTrackingService.AppResponse r = service.handle(req.orderNumber, req.readOnly);

        Response out = new Response();
        out.status       = r.status;
        out.deliveryDate = r.deliveryDate;
        return new List<Response>{ out };
    }
}