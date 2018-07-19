<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SalesAlertApprovalADV</fullName>
        <description>rejection and return Approval ADV</description>
        <protected>false</protected>
        <recipients>
            <field>ApprovalUserMail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Sales_ADV_rejection_and_return</template>
    </alerts>
    <rules>
        <fullName>SalesAnullOrderWithTangibleItems</fullName>
        <active>false</active>
        <formula>NOT(ISNULL(EffectiveDate))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SalesNotificAprobalADV</fullName>
        <actions>
            <name>SalesAlertApprovalADV</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.OrderApprovalStatus__c</field>
            <operation>equals</operation>
            <value>Devuelto al Vendedor,Rechazada por ADV</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.SaleMotivoRechazoADV__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>workflow rule created for solution the requirement of history , the what require send notification email for user with profile of agent.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
