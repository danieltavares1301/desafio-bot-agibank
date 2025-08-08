public with sharing class OrdersApiClient {

    public class IntegrationException extends Exception {}

    private static final String ENDPOINT =
        'callout:OrdersAPI/v1/8c76ff9b-3136-47ba-a939-ce4c4fca41be';

    /** Retorna um único pedido do payload para o número solicitado */
    public OrderAPIResponse getByNumber(String orderNumber){
        List<OrderAPIResponse> all = fetchAll();
        for (OrderAPIResponse o : all) {
            if (o.orderNumber == orderNumber) return o;
        }
        return null;
    }

    /** Busca toda a lista e converte p/ DTO */
    private List<OrderAPIResponse> fetchAll(){
        HttpResponse res;
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(ENDPOINT);
            req.setTimeout(5000);
            res = (new Http()).send(req);
        } catch (System.CalloutException ex) {
            throw new IntegrationException('Callout falhou: ' + ex.getMessage());
        }

        if (res == null || res.getStatusCode() != 200) {
            throw new IntegrationException('Status HTTP inválido: ' + (res != null ? res.getStatusCode() : -1));
        }

        List<Object> raw = (List<Object>) JSON.deserializeUntyped(res.getBody());
        List<OrderAPIResponse> dtos = new List<OrderAPIResponse>();
        for (Object o : raw) {
            Map<String,Object> m = (Map<String,Object>) o;
            OrderAPIResponse d = new OrderAPIResponse();
            d.orderNumber  = (String) m.get('orderNumber');
            d.status       = (String) m.get('status');
            d.deliveryDate = (String) m.get('deliveryDate');
            d.customerId   = (String) m.get('customerId');
            d.customerName = (String) m.get('customerName');
            dtos.add(d);
        }
        return dtos;
    }
}