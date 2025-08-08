public with sharing class ReturnOrderS3IntegrationController {

    public class Request { 
        @InvocableVariable(label='Return Order Id')
        public Id returnOrderId;

        @InvocableVariable(label='Endpoint de destino (Named Credential ou URL)')
        public String endpointUrl;
    }

    public class Response {
        @InvocableVariable(label='Return Order Id')
        public String returnOrderId;

        @InvocableVariable(label='Endpoint usado')
        public String endpoint;

        @InvocableVariable(label='Status')
        public String status;

        @InvocableVariable(label='Detalhe')
        public String detail;
    }

    @InvocableMethod(label='Send ReturnOrder to endpoint (simulation)' callout=true)
    public static List<Response> simulate(List<Request> requests) {
        List<Response> results = new List<Response>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        Set<Id> returnOrderIds = new Set<Id>();
        for (Request req : requests) {
            if (req != null && req.returnOrderId != null) {
                returnOrderIds.add(req.returnOrderId);
            }
        }

        if (returnOrderIds.isEmpty()) {
            return results;
        }

        Map<Id, ReturnOrder> idToReturnOrder = new Map<Id, ReturnOrder>([
            SELECT Id,
                   ReturnOrderNumber,
                   OrderId,
                   AccountId,
                   Description,
                   CreatedDate,
                   LastModifiedDate
            FROM ReturnOrder
            WHERE Id IN :returnOrderIds
        ]);

        for (Request req : requests) {
            Response res = new Response();
            res.returnOrderId = String.valueOf(req != null ? req.returnOrderId : null);

            if (req == null || req.returnOrderId == null) {
                res.status = 'ERROR';
                res.detail = 'Parâmetros inválidos: ReturnOrderId ausente.';
                results.add(res);
                continue;
            }

            ReturnOrder ro = idToReturnOrder.get(req.returnOrderId);
            if (ro == null) {
                res.status = 'ERROR';
                res.detail = 'ReturnOrder não encontrado.';
                results.add(res);
                continue;
            }

            String endpointUsed = req != null ? req.endpointUrl : null;
            res.endpoint = endpointUsed;

            System.enqueueJob(new ReturnOrderS3IntegrationQueueable(ro, endpointUsed));
            res.status = 'ENQUEUED';
            res.detail = 'Envio simulado enfileirado.';
            results.add(res);
        }

        return results;
    }
}