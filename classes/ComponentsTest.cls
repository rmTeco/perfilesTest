@isTest
public class ComponentsTest{

    @isTest
    public static void testMethod1(){
        //Components comp = new Components();
        List<vlocity_cmt__OmniScript__c> lstOS = new List<vlocity_cmt__OmniScript__c>();
        lstOS = Components.OSList();
        //Id OSId = [SELECT Id FROM vlocity_cmt__OmniScript__c].Id;
        
        String OSId = 'a1zc0000003XiG0AAK';
        vlocity_cmt__OmniScript__c OS = new vlocity_cmt__OmniScript__c(Name='test', vlocity_cmt__Type__c='Sales', vlocity_cmt__SubType__c='Renew', vlocity_cmt__IsActive__c=true, vlocity_cmt__IsProcedure__c=true);
        insert OS;
        Set<Id> ids = new Set<Id>();
        ids=Components.IPSet();
        List<Id> lstId = new List<Id>(ids);   
        Components.Element el = new Components.Element();
        Components.DRInfo dr = new Components.DRInfo();
        Components.dataRaptorExtract();
        Components.dataRaptorLoad();
        Components.IPElement();
        vlocity_cmt__Element__c elem = new vlocity_cmt__Element__c(Name='TestElem', vlocity_cmt__OmniScriptId__c=lstId.get(0), vlocity_cmt__PropertySet__c='{"HTMLTemplateId":"","bundle":"ta-sales-DR-getOrder","controlWidth":12,"dataRaptor Input Parameters":[{"element":"IdOrder","inputParam":"Id"}],"extraPayload":{},"failureAbortLabel":"Abort","failureAbortMessage":"Are you sure?","failureNextLabel":"Continue","inProgressMessage":"In Progress","label":null,"message":{},"postMessage":"Done","redirectNextLabel":"Next","redirectNextWidth":3,"redirectPageName":"","redirectPreviousLabel":"Previous","redirectPreviousWidth":3,"redirectTemplateUrl":"vlcAcknowledge.html","remoteOptions":{"postTransformBundle":"","preTransformBundle":""},"remoteTimeout":30000,"responseJSONNode":"","responseJSONPath":"","show":null,"showPersistentComponent":[false,false],"ssm":false,"validationRequired":"None","wpm":false}', vlocity_cmt__Type__c='DataRaptor Extract Action');
        insert elem;
        vlocity_cmt__Element__c elem2 = new vlocity_cmt__Element__c(Name='TestElem2', vlocity_cmt__OmniScriptId__c=lstId.get(0), vlocity_cmt__PropertySet__c='{"HTMLTemplateId":"","controlWidth":12,"extraPayload":{},"failureAbortLabel":"Abort","failureAbortMessage":"Are you sure?","failureNextLabel":"Continue","inProgressMessage":"In Progress","label":null,"message":{},"postMessage":"Done","postTransformBundle":"","preTransformBundle":"","redirectNextLabel":"Next","redirectNextWidth":3,"redirectPageName":"","redirectPreviousLabel":"Previous","redirectPreviousWidth":3,"redirectTemplateUrl":"vlcAcknowledge.html","remoteClass":"taSalesOrderPaymentInteraction","remoteMethod":"SendPayment","remoteOptions":{"IdOrder":"%IdOrder%","postTransformBundle":"","preTransformBundle":""},"remoteTimeout":30000,"responseJSONNode":"","responseJSONPath":"","sendJSONNode":"","sendJSONPath":"","show":null,"showPersistentComponent":[false,false],"ssm":false,"svgIcon":"","svgSprite":"","validationRequired":"None","wpm":false}', vlocity_cmt__Type__c='Remote Action');
        insert elem2;
        vlocity_cmt__Element__c elem3 = new vlocity_cmt__Element__c(Name='TestElem3', vlocity_cmt__OmniScriptId__c=lstId.get(0), vlocity_cmt__PropertySet__c='{"HTMLTemplateId":"","controlWidth":12,"extraPayload":{},"failureAbortLabel":"Abort","failureAbortMessage":"Are you sure?","failureNextLabel":"Continue","inProgressMessage":"In Progress","integrationProcedureKey":"IFS_S439","label":null,"message":{},"postMessage":"Done","postTransformBundle":"","preTransformBundle":"","redirectNextLabel":"Next","redirectNextWidth":3,"redirectPageName":"","redirectPreviousLabel":"Previous","redirectPreviousWidth":3,"redirectTemplateUrl":"vlcAcknowledge.html","remoteOptions":{"postTransformBundle":"","preTransformBundle":""},"remoteTimeout":30000,"responseJSONNode":"","responseJSONPath":"","sendJSONNode":"","sendJSONPath":"","show":{"group":{"operator":"AND","rules":[{"condition":"=","data":"9999","field":"PaymentTypeRadio"}]}},"showPersistentComponent":[false,false],"ssm":false,"svgIcon":"","svgSprite":"","validationRequired":"None","wpm":false}', vlocity_cmt__Type__c='Integration Procedure Action');
        insert elem3;
        vlocity_cmt__Element__c elem4 = new vlocity_cmt__Element__c(Name='TestElem4', vlocity_cmt__OmniScriptId__c=lstId.get(0), vlocity_cmt__PropertySet__c='{"HTMLTemplateId":"","bundle":"ta-sales-DR-IU-Contact-Document","controlWidth":12,"failureAbortLabel":"Abort","failureAbortMessage":"Are you sure?","failureNextLabel":"Continue","inProgressMessage":"In Progress","label":null,"message":{},"postMessage":"Done","postTransformBundle":"","redirectNextLabel":"Next","redirectNextWidth":3,"redirectPageName":"","redirectPreviousLabel":"Previous","redirectPreviousWidth":3,"redirectTemplateUrl":"vlcAcknowledge.html","remoteTimeout":30000,"sendJSONNode":"","sendJSONPath":"","show":{"group":{"operator":"AND","rules":[{"condition":"<>","data":null,"field":"FinalDocumentMethod"},{"condition":"<>","data":null,"field":"Contact:Id"},{"condition":"=","data":"true","field":"IdentityValidated"}]}},"showPersistentComponent":[false,false],"ssm":false,"validationRequired":null,"wpm":false}', vlocity_cmt__Type__c='DataRaptor Post Action');
        insert elem4;
        //SELECT vlocity_cmt__InterfaceFieldAPIName__c, vlocity_cmt__InterfaceObjectName__c, Name, vlocity_cmt__DomainObjectAPIName__c, vlocity_cmt__DomainObjectCreationOrder__c, vlocity_cmt__DomainObjectFieldAPIName__c, vlocity_cmt__MapId__c FROM vlocity_cmt__DRMapItem__c
        vlocity_cmt__DRMapItem__c extract = new vlocity_cmt__DRMapItem__c(vlocity_cmt__InterfaceFieldAPIName__c='orderItemsWithAttrs:attrs:ICCID', Name='Test DR Extract', vlocity_cmt__MapId__c='xOM Comptel Down RequestCustoma0v6C000000DYoVQAWItem7', vlocity_cmt__DomainObjectFieldAPIName__c='CreateRequest:RequestParameters:PAR_ICCID', vlocity_cmt__DomainObjectCreationOrder__c=1.0, vlocity_cmt__DomainObjectAPIName__c='json');
        insert extract;
        vlocity_cmt__DRMapItem__c load = new vlocity_cmt__DRMapItem__c(vlocity_cmt__InterfaceFieldAPIName__c='orderItemsWithAttrs:attrs:ICCID', Name='Test DR Load', vlocity_cmt__MapId__c='xOM Comptel Down RequestCustoma0v6C000000DYoVQAWItem8', vlocity_cmt__DomainObjectFieldAPIName__c='CreateRequest:RequestParameters:PAR_ICCID', vlocity_cmt__DomainObjectCreationOrder__c=1.0, vlocity_cmt__DomainObjectAPIName__c='json');
        insert load;
        Components.dataRaptorExtract();
        Components.dataRaptorLoad();
        //List<vlocity_cmt__Element__c> lstelem = [SELECT Id, Name, vlocity_cmt__Type__c, vlocity_cmt__ParentElementId__c, vlocity_cmt__PropertySet__c, vlocity_cmt__Active__c, vlocity_cmt__OmniScriptId__c, vlocity_cmt__OmniScriptId__r.vlocity_cmt__ProcedureKey__c FROM vlocity_cmt__Element__c ORDER BY vlocity_cmt__Order__c]; 
        //System.debug('@@@ lst ' + lstelem);
        Components.OSElement(lstId.get(0));
    }
    
    @isTest
    public static void testMethod2(){
        Map<String,Id> maptest = new Map<String,Id>();
        maptest = Components.getClass();
    }
}