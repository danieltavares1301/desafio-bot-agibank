@IsTest
private class OrderTrackingControllerTest {

    @TestSetup
    static void setupData() {
        Account acc = new Account(Name='Pré Cliente', CustomerId__c='CUST-1');
        insert acc;

        Contract con = new Contract(
            AccountId = acc.Id,
            Status    = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12,
            Name      = 'Contrato Prévio'
        );
        insert con;

        Order ord = new Order(
            AccountId       = acc.Id,
            ContractId      = con.Id,
            Status          = 'Draft',
            EffectiveDate   = Date.today(),
            OrderExternalId__c = '12345'  // será localizado e atualizado no cenário 3
        );
        insert ord;
    }

    // ===================== Mocks de Callout =====================
    private class MockOk implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse r = new HTTPResponse();
            r.setStatusCode(200);
            r.setHeader('Content-Type','application/json');
            r.setBody(
                '[' +
                // existente no @TestSetup → será atualizado
                '{"orderNumber":"12345","status":"Pedido enviado","deliveryDate":"15/08/2025",' +
                '"customerId":"CUST-1","customerName":"João Silva"},' +
                // ainda não existe → será criado no cenário 2
                '{"orderNumber":"22222","status":"Em rota de entrega","deliveryDate":"16/08/2025",' +
                '"customerId":"CUST-NEW","customerName":"Maria Nova"}' +
                ']'
            );
            return r;
        }
    }
    /** 200 OK – não contém o pedido buscado (simula não encontrado) */
    private class MockNotFound implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse r = new HTTPResponse();
            r.setStatusCode(200);
            r.setHeader('Content-Type','application/json');
            r.setBody(
                '[{"orderNumber":"56789","status":"Pedido entregue","deliveryDate":"08/08/2025",' +
                '"customerId":"CUST-2","customerName":"Maria Silva"}]'
            );
            return r;
        }
    }
    /** 500 – Falha de integração */
    private class MockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse r = new HTTPResponse();
            r.setStatusCode(500);
            r.setBody('ERRO');
            return r;
        }
    }

    // ===================== Helper =====================
    private static OrderTrackingController.Request makeReq(String orderNumber, Boolean readOnly){
        OrderTrackingController.Request rq = new OrderTrackingController.Request();
        rq.orderNumber = orderNumber;
        rq.readOnly    = readOnly;
        return rq;
    }


    /** Cenário 1: readOnly = true (sem DML) */
    @IsTest
    static void test_readOnly_success() {
        Test.setMock(HttpCalloutMock.class, new MockOk());

        Integer accBefore = [SELECT COUNT() FROM Account];
        Integer conBefore = [SELECT COUNT() FROM Contract];
        Integer ordBefore = [SELECT COUNT() FROM Order];

        Test.startTest();
        List<OrderTrackingController.Response> out =
            OrderTrackingController.getOrderStatus(new List<OrderTrackingController.Request>{
                makeReq('12345', true)
            });
        Test.stopTest();

        System.assertEquals('Pedido enviado', out[0].status);
        System.assertEquals('15/08/2025',     out[0].deliveryDate);
        System.assertEquals(accBefore, [SELECT COUNT() FROM Account],  'Não deve criar/alterar Account');
        System.assertEquals(conBefore, [SELECT COUNT() FROM Contract], 'Não deve criar/alterar Contract');
        System.assertEquals(ordBefore, [SELECT COUNT() FROM Order],    'Não deve criar/alterar Order');
    }

    /** Cenário 2: readOnly = false e pedido 22222 NÃO existe → cria Account, Contract, Order */
    @IsTest
    static void test_sync_create_chain() {
        Test.setMock(HttpCalloutMock.class, new MockOk());

        Test.startTest();
        OrderTrackingController.getOrderStatus(new List<OrderTrackingController.Request>{
            makeReq('22222', false)
        });
        Test.stopTest();

        // Account criada?
        Account acc = [
            SELECT Id, Name, CustomerId__c
            FROM Account
            WHERE CustomerId__c = 'CUST-NEW'
            LIMIT 1
        ];
        System.assertNotEquals(null, acc, 'Deve criar Account para CUST-NEW');

        Contract con = [
            SELECT Id, AccountId
            FROM Contract
            WHERE AccountId = :acc.Id
            LIMIT 1
        ];
        System.assertEquals(acc.Id, con.AccountId, 'Contract deve referenciar a Account criada');

        Order ord = [
            SELECT Id, AccountId, ContractId, Status, EndDate, OrderExternalId__c
            FROM Order
            WHERE ContractId = :con.Id
            LIMIT 1
        ];
        System.assertEquals(acc.Id, ord.AccountId);
        System.assertEquals(con.Id, ord.ContractId);
        System.assertEquals('22222', ord.OrderExternalId__c);
        System.assertEquals('Em rota de entrega', ord.Status);
        System.assertEquals(Date.newInstance(2025, 8, 16), ord.EndDate);
    }

    /** Cenário 3: readOnly = false e pedido 12345 JÁ existe → atualiza Order */
    @IsTest
    static void test_sync_update_existing_order() {
        Test.setMock(HttpCalloutMock.class, new MockOk());

        Order before = [
            SELECT Id, Status, EndDate
            FROM Order
            WHERE OrderExternalId__c = '12345'
            LIMIT 1
        ];
        System.assertNotEquals(null, before, 'Pré-condição: Order 12345 deve existir');

        Test.startTest();
        OrderTrackingController.getOrderStatus(new List<OrderTrackingController.Request>{
            makeReq('12345', false)
        });
        Test.stopTest();

        Order updated = [
            SELECT Status, EndDate
            FROM Order
            WHERE Id = :before.Id
        ];
        System.assertEquals('Pedido enviado', updated.Status);
        System.assertEquals(Date.newInstance(2025, 8, 15), updated.EndDate);
    }

    /** Cenário 4: falha de integração */
    @IsTest
    static void test_integration_failure() {
        Test.setMock(HttpCalloutMock.class, new MockError());

        Test.startTest();
        List<OrderTrackingController.Response> out =
            OrderTrackingController.getOrderStatus(new List<OrderTrackingController.Request>{
                makeReq('99999', true)
            });
        Test.stopTest();

        System.assertEquals('Falha na integração', out[0].status);
        System.assertEquals(null, out[0].deliveryDate);
    }

    /** Cenário 5: pedido não encontrado na API */
    @IsTest
    static void test_order_not_found_in_api() {
        Test.setMock(HttpCalloutMock.class, new MockNotFound());

        Test.startTest();
        List<OrderTrackingController.Response> out =
            OrderTrackingController.getOrderStatus(new List<OrderTrackingController.Request>{
                makeReq('12345', true)
            });
        Test.stopTest();

        System.assertEquals('Pedido não encontrado', out[0].status);
        System.assertEquals(null, out[0].deliveryDate);
    }
}