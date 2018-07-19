public with sharing class taCareAdjustments {
	
	  //@InvocableMethod(label='Escalar Caso Adjustment' description='Actualiza el OwnerId según el Mager del Parent WorkTeam en la gerarquía del Owner actual')
	  static public void escalarCaso(List<Case> cases) {
	  	System.debug('Escalar Caso Adjustment');
	  		
	  		try {
	  			if (cases != null && !cases.isEmpty()) {
	  				Case myCase = [SELECT Subject, Status, OwnerId FROM Case WHERE Id =: cases.get(0).Id];
	  				
	  				
	  				if(myCase.Subject == 'Inconvenientes con cargos tasados y facturados' && myCase.Status == 'En espera de ejecución') {
	  					System.debug('DERIVANDO EL CASO POR VENCIMIENTO DE SLA');
	  					User user = [select Work_Team__c from User where Id =: myCase.OwnerId];
	  					if(user.Work_Team__c != null){
	  						WorkTeam__c workTeam = [select Parent_Team__c from WorkTeam__c where Id =: user.Work_Team__c];
				  			
				  			if (workTeam.Parent_Team__c != null) {
				  				WorkTeam__c workTeamParet = [select Manager__c from WorkTeam__c where Id =: workTeam.Parent_Team__c];
				  				myCase.OwnerId = workTeamParet.Manager__c;
				  			}
	  					}
			  			
			  			myCase.Status = 'Derivada';
			  			update myCase;
	  				}
	  			}
	  			
	  		} catch (Exception e) {
	  			System.debug(e.getMessage());
	  		}
	  }
    
}