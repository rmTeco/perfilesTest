<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SCP_Certa_GC__Actualizar_valor</fullName>
        <field>SCP_Certa_GC__Campo_para_sumar_en_oportunidad__c</field>
        <formula>SCP_Certa_GC__FCV__c</formula>
        <name>Actualizar valor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SCP_Certa_GC__Actualizar_valor_totales_por_mes</fullName>
        <field>SCP_Certa_GC__Cargo_totales_por_mes_Total_sumable__c</field>
        <formula>SCP_Certa_GC__Cargos_Totales_por_Mes__c</formula>
        <name>Actualizar valor totales por mes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SCP_Certa_GC__Igualar Valores FCV</fullName>
        <actions>
            <name>SCP_Certa_GC__Actualizar_valor</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SCP_Certa_GC__Actualizar_valor_totales_por_mes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
