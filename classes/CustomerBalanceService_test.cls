@IsTest
public class CustomerBalanceService_test {

    @IsTest static void invoke_GetBillingAccountsBalance(){
     	String methodName = 'GetBillingAccountsBalance';

        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
		
        CustomerBalanceService customerBalance = new CustomerBalanceService();
        
        Map<String, Object> mapCuenta = new Map<String, Object>();
        Map<String, Object> balanceListMap = new Map<String, Object>();
        Map<String, Object> balanceMap = new Map<String, Object>();
        Map<String, Object> cicloFactListMap = new Map<String, Object>();
        Map<String, Object> cicloFactMap = new Map<String, Object>();
        Map<String, Object> billingItemMap = new Map<String, Object>();        

        dateTime dt = DateTime.ValueOf('2017-8-12 00:00:00');
        
        billingItemMap.put('balanceCuenta',1378);
        cicloFactMap.put('detalleItemCicloFacturacion',billingItemMap);
        cicloFactMap.put('detalleCicloFacturacion','test');
        cicloFactMap.put('fechaVencimientoFacturacion',dt);
        cicloFactListMap.put('cicloFacturacion',cicloFactMap);
        balanceMap.put('saldoPorTipoBalance', 1500);
        balanceMap.put('codTipoBalance','C_MAIN_BILLING_ACCOUNT');
        balanceListMap.put('balance',balanceMap);
        mapCuenta.put('saldoPorTipoBalance',1000);
        mapCuenta.put('codCuenta','3333333333');
        mapCuenta.put('listaDeBalances',balanceListMap);
        mapCuenta.put('listaCicloFacturacion',cicloFactListMap);
        Map<String, Object> mapOptions = new Map<String, Object>();
        mapOptions.put('infoBalance',mapCuenta);
        options.put('listaInfoBalance',mapOptions);
        
        Map<String, Object> mapTest = new Map<String, Object>();
        mapTest.put('AccountIntegrationId','3333333333');
		input.put('BillingAccounts',mapTest);
        
        Test.startTest();
        customerBalance.invokeMethod(methodName, input, outMap, options);
        Test.stopTest();
        
        system.assertNotEquals(null, outMap.get('BillingAccounts'));
    }
}