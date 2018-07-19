global with sharing class ta_sales_locationSearch implements vlocity_cmt.VlocityOpenInterface
{
	public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
	{
		if(methodName.equals('PopulateLocationsTypeAHeadbyOptions'))
		{
			PopulateLocationsTypeAHeadbyOptions(input, outMap, options);
		}
		if(methodName.equals('PopulateStreetsTypeAHead'))
		{
			PopulateStreetsTypeAHead(input, outMap, options);
		}
		if(methodName.equals('validateAdressRange'))
		{
			validateAdressRange(input, outMap, options);
		}
		if(methodName.equals('GenerarCodigoPostal'))
		{
			GenerarCodigoPostal(input, outMap, options);
		}
	// 	if(methodName.equals('PopulateLocations'))
	// 	{
	// 		PopulateLocations(input, outMap, options);
	// 	}
	// 	if(methodName.equals('PopulateLocationsTypeAHead'))
	// 	{
	// 		PopulateLocationsTypeAHead(input, outMap, options);
	// 	}
	// 	if(methodName.equals('getPostalcodeFromStreetRange'))
	// 	{
	// 		PopulateLocationsTypeAHead(input, outMap, options);
	// 	}
	// 	if(methodName.equals('PopulateStateLocationsPickupAvailable'))
	// 	{
	// 		PopulateStateLocationsPickupAvailable(input, outMap, options);
	// 	}
	// 	if(methodName.equals('PopulateCityLocationsPickupAvailable'))
	// 	{
	// 		PopulateCityLocationsPickupAvailable(input, outMap, options);
	// 	}
	// 	if(methodName.equals('PopulateLocationsNewTypeAHead'))
	// 	{
	// 		PopulateLocationsNewTypeAHead(input, outMap, options);
	// 	}
		return true;
	}
	//Metodo Utilizado para cargar la lista de Localidad
	public void PopulateLocationsTypeAHeadbyOptions(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
	{
		try
		{
			String state = (String) options.get('State');
			String Province = (String) options.get('Provincia');
			List<Location__c> locations = new List<Location__c>();
			If(state != null)
			{
				locations = [SELECT Id,
												Name,
												Postal_Code__c,
												LocationCode__c
											FROM Location__c
											WHERE StateCode__c = :state
											ORDER BY Name
											];
			}
			else
			{
				locations = [SELECT Id,
												Name,
												Postal_Code__c,
												LocationCode__c
											FROM Location__c
											WHERE StateCode__c = :Province
											ORDER BY Name
											];
			}
			outMap.put('locations', locations);
		}
		catch(Exception e)
		{
			System.debug('Exception Msg: ' + e.getMessage());
			System.debug('Exception Cause: ' + e.getCause());
			System.debug('Exception Stack Trace: ' + e.getStackTraceString());
			throw e;
		}
	}
	//Metodo Utilizado para cargar el campo de Calle
	public void PopulateStreetsTypeAHead(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
	{
		try
		{
			String locationId = (String) options.get('LocationId');
			if (!String.IsBlank(locationId))
			{
				List<Street__c> streets = [SELECT Id,
												Name,
												StreetCode__c,
												Postal_Code__c,
												Range_From__c,
												Range_To__c
											FROM Street__c
											WHERE Parent_Street__c = null
											AND Location__C = :locationId
											ORDER BY Name
											];
				outMap.put('streets', streets);
			}
		}
		catch(Exception e)
		{
			System.debug('Exception Msg: ' + e.getMessage());
			System.debug('Exception Cause: ' + e.getCause());
			System.debug('Exception Stack Trace: ' + e.getStackTraceString());
			throw e;
		}
	}
	//metodo encargado de generar el codigo podtsl dedes un remote action del OS
	public void GenerarCodigoPostal(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
	{
		String strCalleId = (String) options.get('CalleId');
		String strlocationId = (String) options.get('LocalidadId');
		String strAlturaIngresada = (String) options.get('AlturaNum');
		if(strCalleId != '' && strlocationId != '' && strAlturaIngresada != '')
		{
			List<Street__c> lstStreet = [ SELECT Id,
												Name,
												StreetCode__c,
												Postal_Code__c,
												Range_From__c,
												Range_To__c
											FROM Street__c
											WHERE Parent_Street__c = null
											AND Location__C = :strlocationId
											ORDER BY Name
										];
			system.debug('lstStreet ===> '+lstStreet);
			for(Street__c objStreet : lstStreet)
			{
				String strCodigoPostal;
				String intAltura1;
				String intAltura2;
				intAltura1 = String.valueOf(objStreet.Range_From__c);
				intAltura2 = String.valueOf(objStreet.Range_To__c);
				if(/*intAltura1 >= intAlturaIngresada && intAltura2 <= intAlturaIngresada ||*/ intAltura1 == strAlturaIngresada && intAltura2 == strAlturaIngresada)
				{
					strCodigoPostal = String.valueOf(objStreet.Postal_Code__c);
					outMap.put('ShippingCodigoPostal', strCodigoPostal);
				}
				else
				{
					outMap.put('ShippingCodigoPostal', '');
				}
			}
		}
	}
	//Metodo encargado de realizar la creacion de los asset2 y actuaizar las cuentas y contactos
	public void validateAdressRange(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
	{
		String strProvinciaId = (String) options.get('ProvinciaId');
		String strCalleId = (String) options.get('CalleId');
		String strlocationId = (String) options.get('LocalidadId');
		String strAlturaIngresada = (String) options.get('AlturaNum');
		String strCodigoPostal = (String) options.get('CodigoPostal');
		String strTipoZona = (String) options.get('TipoZona');
		String strIdAccount = (String)Options.get('accountId');
		String strIdContact = (String)Options.get('contactId');
		
		Address2__c objAddress2;
		if(strCalleId != '' && strlocationId != '' && strAlturaIngresada != '' && strCodigoPostal != '')
		{
			objAddress2 = new Address2__c();
			Street__c objStreet = [ SELECT Id,
												Name,
												Location__c,
												Postal_Code__c,
												Range_From__c,
												Range_To__c,
												Location__r.Name,
												Location__r.StateCode__c,
												Location__r.StateName__c
											FROM Street__c
											WHERE Parent_Street__c = null
											AND Location__C =: strlocationId
											AND Id =: strCalleId
											ORDER BY Name
										];
			objAddress2.Account_Owner__c = strIdAccount;
			objAddress2.Address_Number__c = Decimal.valueOf(strAlturaIngresada);
			objAddress2.Contact_Owner__c = strIdContact;
			objAddress2.Location_ID__c = strlocationId;
			objAddress2.Location_Name__c = objStreet.Location__r.Name;
			//objAddress2.Province_ID__c = strProvinciaId;
			objAddress2.Province__c = objStreet.Location__r.StateCode__c;
			objAddress2.Street_ID__c = strCalleId;
			objAddress2.Street_Name__c = objStreet.Name;
			objAddress2.Tipo_de_Zona__c = strTipoZona;
			if(strCodigoPostal != objStreet.Postal_Code__c)
			{
				objAddress2.ZIP_Code__c = strCodigoPostal;
				objaddress2.Validado__c = True; 
			}
			else
			{
				objAddress2.ZIP_Code__c = strCodigoPostal;
			}
			insert objAddress2;
		}
		List<Account> lstAccount = [ Select Id,
											Billing_Address__c,
											Shipping_Address__c,
											RecordType.DeveloperName
										From Account
										WHERE Id =: strIdAccount
									];
		for(Account objAccount : lstAccount)
		{
			if(objAccount.RecordType.DeveloperName == 'Consumer')
			{
				objAccount.Shipping_Address__c = objAddress2.Id;
			}
			else
			{
				objAccount.Billing_Address__c = objAddress2.Id;
			}
			update objAccount;
		}
		
		/*Integer intNumAltura = Integer.valueof(options.get('addressnumber'));
		String strIdStreet = (String) Options.get('streetId');
		String strIdAccount = (String)Options.get('accountId');
		String strIdContact = (String)Options.get('contactId');
		/*Map<String, Object> mapLsAccount = option.get('AccountData');
			String strZone = mapLsAccount.get('BillingTipoDeZona');
			String strZone = mapLsAccount.get('ShippingTipoDeZona');*/


		/*List<Street__c> lstStreets = new List<Street__c>();
		lstStreets = [ Select Id,
							Name,
							Range_From__c,
							Range_To__c,
							Postal_Code__c,
							Location__c
						From Street__c
						WHERE Id =: strIdStreet
						//AND Location__c =: strIdLocalidad
						];
		System.debug('lstStreets ===>'+lstStreets);

		/*try
		{
			Double addressnumber = Double.valueof( options.get('addressnumber'));
			String streetId = (string) Options.get('streetId');
			String postalcode = (String) Options.get('postalcode');
			boolean isvalidated = false;
			Street__C street1;
			try
			{
				street1 = [SELECT id, name,Range_From__c , Range_To__c, Postal_Code__c,  (Select id, name, Postal_Code__c, Range_From__c , Range_To__c FROM Streets__r WHERE Range_From__c <=: addressnumber and Range_To__c >=:addressnumber ) FROM Street__c WHERE id =: streetId];
			}
			catch (Exception e)
			{}
			boolean isunnamedstreet = (boolean) options.get('validateexceptions');
			if(isunnamedstreet == true)
			{
				isvalidated= true;
			}
			if (street1 != null)
			{
				if ( (street1.Range_From__c <= addressnumber &&  addressnumber <= street1.Range_To__c) && postalcode == street1.Postal_Code__c )
				{
					isvalidated = true;
				}
				else
				if (street1.Streets__r.Size() >0 && postalcode == street1.Streets__r[0].Postal_Code__c)
				{
					isvalidated = true;
				}
			}
			if (isvalidated == true)
			{
				outMap.put('addressvalidated',  true);
			}
			else
			{
				outMap.put('addressvalidated',  false);
			}
		}
		catch (Exception e)
		{
			outMap.put('error', e.getMessage());
		}*/
	}
	// public void PopulateLocations(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
	// {
	// 	try
	// 	{
	// 		Map<String, List<Map<String, String>>> dependency = new Map<String,List<Map<String, String>>>();
	// 		for (Location__c rel : [SELECT Id, Name, LocationCode__c, StateCode__c FROM Location__c ORDER BY Name])
	// 		{
	// 			if (!dependency.containsKey(rel.StateCode__c))
	// 			{
	// 				dependency.put(rel.StateCode__c, new List<Map<String, String>>());
	// 			}
	// 			Map<String, String> tempMap = new Map<String, String>();
	// 			tempMap.put('name', rel.LocationCode__c);
	// 			tempMap.put('value', rel.Name);
	// 			dependency.get(rel.StateCode__c).add(tempMap);
	// 		}
	// 		outMap.put('dependency', dependency);
	// 	}
	// 	catch(Exception e)
	// 	{
	// 		System.debug('Exception Msg: ' + e.getMessage());
	// 		System.debug('Exception Cause: ' + e.getCause());
	// 		System.debug('Exception Stack Trace: ' + e.getStackTraceString());
	// 		throw e;
	// 	}
	// }
	// public void PopulateLocationsTypeAHead(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
	// {
	// 	try
	// 	{
	// 		Map<String, Object> accountData = (Map<String, Object>) input.get('AccountData');
	// 		String state = (String) accountData.get('State');
	// 		List<Location__c> locations = [SELECT Id,
	// 												Name,
	// 												Postal_Code__c,
	// 												LocationCode__c
	// 										  FROM Location__c
	// 										  WHERE StateCode__c = :state
	// 										  ORDER BY Name];
	// 		outMap.put('locations', locations);
	// 	}
	// 	catch(Exception e)
	// 	{
	// 		System.debug('Exception Msg: ' + e.getMessage());
	// 		System.debug('Exception Cause: ' + e.getCause());
	// 		System.debug('Exception Stack Trace: ' + e.getStackTraceString());
	// 		throw e;
	// 	}
	// }
	// public void getPostalcodeFromStreetRange(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
	// {
		/*//altura Ingresada en el omni
		Integer intRangeFrom = Integer.valueof(options.get('AlturaValue'));
		system.debug('intRangeFrom ====>'+intRangeFrom);
		//Id de Localidad seleccionada en el omni
		String strIdLocalidad = (String) Options.get('LocationId');
		system.debug('intRangeFrom ====>'+intRangeFrom);
		List<Street__c> lstStreets = new List<Street__c>();
		lstStreets = [ Select Id,
							  Name,
							  Range_From__c,
							  Range_To__c,
							  Postal_Code__c,
							  Location__c
					   From Street__c
					   WHERE Location__c =: strIdLocalidad
					  ];
		System.debug('lstStreets ===>'+lstStreets);
		IF(intRangeFrom != null)
		{
		  for(Street__c objStreet : lstStreets)
		  {
			If(objStreet.Range_From__c == intRangeFrom)
			{
			  outMap.put('PostalCode', objStreet.Postal_Code__c);
			  System.debug('PostalCode ===> '+objStreet.Postal_Code__c);
			}
		  }
		}*/
	// 	Double addressnumber = Double.valueof( options.get('addressnumber'));
	// 	String streetId = (string) Options.get('streetId');
	// 	Street__C street1 = [SELECT id, name,Range_From__c , Range_To__c, Postal_Code__c, (Select id, name,Range_From__c , Range_To__c, Postal_Code__c  FROM Streets__r WHERE Range_From__c <=: addressnumber and Range_To__c >=:addressnumber ) FROM Street__c WHERE id =: streetId];
	// 	if (street1 != null)
	// 	{
	// 		if  (street1.Range_From__c <= addressnumber &&  addressnumber <= street1.Range_To__c)
	// 		{
	// 			outMap.put('PostalCode', street1.Postal_Code__c);
	// 		}
	// 		else
	// 		if (street1.Streets__r.Size() >0)
	// 		{
	// 			outMap.put('PostalCode', street1.Streets__r[0].Postal_Code__c);
	// 		}
	// 	}
	// }
	// public void PopulateStateLocationsPickupAvailable(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
	// {
	// 	System.debug('Populate State Locations');
	// 	Map<String, String> statePicklistValues = new Map<String, String>();
	// 	List<Map<String, String>> returnedPicklistValues = new List<Map<String, String>>();
	// 	//Gets the value of the Points of Sale available for Store Pickup
	// 	List<vlocity_cmt__BusinessSite__c> businessSitesList = [SELECT vlocity_cmt__State__c FROM vlocity_cmt__BusinessSite__c WHERE PointOfSaleStorePickupEnabled__c = true];
	// 	Set<String> stateAvailable = new Set<String>();
	// 	for (vlocity_cmt__BusinessSite__c businessSite : businessSitesList)
	// 	{
	// 		if (businessSite.vlocity_cmt__State__c != null && businessSite.vlocity_cmt__State__c != '')
	// 		{
	// 			stateAvailable.add(businessSite.vlocity_cmt__State__c);
	// 		}
	// 	}
	// 	//Gets the value of the states
	// 	List<Schema.PicklistEntry> statePicklistEntries = Account.BillingStateCode.getDescribe().getPicklistValues();
	// 	statePicklistEntries = sortPicklistEntryListByLabel(statePicklistEntries);
	// 	for (Schema.PicklistEntry picklistEntry : statePicklistEntries)
	// 	{
	// 		if (stateAvailable.contains(picklistEntry.getValue()))
	// 		{
	// 			if (!statePicklistValues.containsKey(picklistEntry.getValue()))
	// 			{
	// 				statePicklistValues.put(picklistEntry.getValue(), picklistEntry.getLabel());
	// 			}
	// 			Map<String, String> tempMap = new Map<String, String>();
	// 			tempMap.put('name', picklistEntry.getValue());
	// 			tempMap.put('value', statePicklistValues.get(picklistEntry.getValue()));
	// 			returnedPicklistValues.add(tempMap);
	// 		}
	// 	}
	// 	outMap.put('options', returnedPicklistValues);
	// }
	// public void PopulateCityLocationsPickupAvailable(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
	// {
	// 	System.debug('Populate Locations');
	// 	Map<String, List<Map<String, String>>> returnedPicklistValues = new Map<String, List<Map<String, String>>>();
	// 	//Gets the value of the Points of Sale available for Store Pickup
	// 	List<vlocity_cmt__BusinessSite__c> businessSitesList = [SELECT vlocity_cmt__City__c FROM vlocity_cmt__BusinessSite__c WHERE PointOfSaleStorePickupEnabled__c = true];
	// 	Set<String> cityAvailable = new Set<String>();
	// 	for (vlocity_cmt__BusinessSite__c businessSite : businessSitesList)
	// 	{
	// 		if (businessSite.vlocity_cmt__City__c != null && businessSite.vlocity_cmt__City__c != '')
	// 		{
	// 			cityAvailable.add(businessSite.vlocity_cmt__City__c);
	// 		}
	// 	}
	// 	//Gets the value of the states
	// 	List<Location__c> cityPicklistValues = [SELECT Name, LocationCode__c, StateCode__c FROM Location__c ORDER BY Name];
	// 	for (Location__c location : cityPicklistValues)
	// 	{
	// 		if (cityAvailable.contains(location.LocationCode__c))
	// 		{
	// 			if (!returnedPicklistValues.containsKey(location.StateCode__c))
	// 			{
	// 				returnedPicklistValues.put(location.StateCode__c, new List<Map<String, String>>());
	// 			}
	// 			Map<String, String> tempMap = new Map<String, String>();
	// 			tempMap.put('name', location.LocationCode__c);
	// 			tempMap.put('value', location.Name);
	// 			returnedPicklistValues.get(location.StateCode__c).add(tempMap);
	// 		}
	// 	}
	// 	outMap.put('dependency', returnedPicklistValues);
	// }
	// private List<Schema.PicklistEntry> sortPicklistEntryListByLabel(List<Schema.PicklistEntry> stringListEntries)
	// {
	// 	System.debug('Sort List');
	// 	List<String> auxListToSort = new List<String>();
	// 	List<Schema.PicklistEntry> sortedListToReturn = new List<PicklistEntry>();
	// 	for (Schema.PicklistEntry picklistEntry : stringListEntries)
	// 	{
	// 		auxListToSort.add(picklistEntry.getLabel());
	// 	}
	// 	auxListToSort.sort();
	// 	for (String label : auxListToSort)
	// 	{
	// 		for (Schema.PicklistEntry picklistEntry : stringListEntries)
	// 		{
	// 			if (picklistEntry.getLabel().equals(label))
	// 			{
	// 				sortedListToReturn.add(picklistEntry);
	// 			}
	// 		}
	// 	}
	// 	return sortedListToReturn;
	// }
	// public void PopulateLocationsNewTypeAHead(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options)
	// {
	// 	try
	// 	{
	// 		String state = (String) options.get('state');
	// 		List<Location__c> locations = [SELECT Name, LocationCode__c
	// 										FROM Location__c WHERE StateCode__c = :state
	// 										ORDER BY Name];
	// 		outMap.put('locations', locations);
	// 	}
	// 	catch (Exception e)
	// 	{}
	// }
}