public with sharing class KB_KnowledgeViewController {

	public KB_Article__kav articleSelected{get;set;}
	public Boolean voted {get; set;}

	public KB_KnowledgeViewController() {
		voted= false;
	}

	public PageReference search(){
		System.debug('search');
	   	string KBid=apexpages.currentpage().getparameters().get('id');
    	System.debug('kbid: ' +KBid);
    	articleSelected=[Select id, KnowledgeArticleId, Title, Summary, UrlName, KB_Body__c, KB_Attachment__Body__s, KB_Attachment__Length__s, KB_Attachment__ContentType__s, KB_Attachment__Name__s from KB_Article__kav WHERE PublishStatus='online' and KnowledgeArticleId =:KBid limit 1 UPDATE VIEWSTAT];
		Vote vote;
		
		try{
			vote=[SELECT Id, IsDeleted, ParentId, Type, CreatedDate, CreatedById FROM Vote where PARENTID=:articleSelected.KnowledgeArticleId and  CreatedById =:UserInfo.getUserId()];
        }catch(exception e){
        	vote=null;
        	
        }
        voted=(vote!=null);
        
        System.debug('voted: ' +voted);
        return null;

    }
    public PageReference changeRating(){
    	string rating = apexpages.currentpage().getparameters().get('ratingNumber');
    	System.debug('ratingNumber: ' +apexpages.currentpage().getparameters().get('ratingNumber'));
        System.debug('rating: ' +rating);
		Vote vote= new Vote();
		vote.ParentId=articleSelected.KnowledgeArticleId;
		vote.Type=rating;
		try{
			insert vote;
			voted= true;
		}catch(exception e){
			voted= true;
			System.debug('ERROR:' + e);
        }
        System.debug('vote: ' +vote);
        return null;
    }
}