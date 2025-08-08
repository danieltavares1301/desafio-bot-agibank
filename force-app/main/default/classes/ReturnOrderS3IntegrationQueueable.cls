public class ReturnOrderS3IntegrationQueueable implements Queueable, Database.AllowsCallouts {
        private final ReturnOrder returnOrderRecord;
        private final String endpointUrl;

        public ReturnOrderS3IntegrationQueueable(ReturnOrder returnOrderRecord, String endpointUrl) {
            this.returnOrderRecord = returnOrderRecord;
            this.endpointUrl = endpointUrl;
        }

        public void execute(QueueableContext context) {
            Map<String, Object> payload = new Map<String, Object>();
            payload.put('id', returnOrderRecord.Id);
            payload.put('returnOrderNumber', returnOrderRecord.ReturnOrderNumber);
            payload.put('orderId', returnOrderRecord.OrderId);
            payload.put('accountId', returnOrderRecord.AccountId);
            payload.put('description', returnOrderRecord.Description);
            payload.put('createdDate', String.valueOf(returnOrderRecord.CreatedDate));
            payload.put('lastModifiedDate', String.valueOf(returnOrderRecord.LastModifiedDate));

            String body = JSON.serialize(payload);

            try {
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint(endpointUrl);
                req.setHeader('Content-Type', 'application/json');
                req.setBody(body);

                // APENAS SIMULAÇÃO, então não executa
                Http http = new Http();
                //HTTPResponse resp = http.send(req);

            } catch (Exception ex) {
                
            }
        }
    }