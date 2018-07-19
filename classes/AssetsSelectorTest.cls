@isTest
public class AssetsSelectorTest{

    public static Set<Id> getAssetsIds()
    {
        Set<Id> assetIds;
        List<Account> listAccount = TestDataFactory.createAccounts(1, 'Consumer');
        for(Account accountObj : listAccount)
        {
            List<Asset> listAsset = TestDataFactory.createAssets(1, accountObj);
            assetIds = new Map<Id, Asset>(listAsset).KeySet();
        }

        return assetIds;
    }

    public static Set<Id> getAccountsIds()
    {
        List<Account> listAccount = TestDataFactory.createAccounts(1, 'Consumer');
        for(Account accountObj : listAccount)
        {
            List<Asset> listAsset = TestDataFactory.createAssets(1, accountObj);
        }

        Set<Id> accountIds = new Map<Id, Account>(listAccount).KeySet();
        return accountIds;
    }

    @isTest
    public static void SelectById_Test()
    {
        AssetsSelector assetSelector = new AssetsSelector();
        List<Asset> listAsset = assetSelector.SelectById(getAssetsIds());
        
        System.assert(listAsset.size() == 1);
    }

    @isTest
    public static void SelectByAccountId_Test()
    {
        AssetsSelector assetSelector = new AssetsSelector();
        List<Asset> listAsset = assetSelector.SelectByAccountId(getAccountsIds());

        System.assert(listAsset.size() >= 1);
    }

    @isTest
    public static void SelectByIdWithActiveSuspension_Test()
    {
        AssetsSelector assetSelector = new AssetsSelector();
        List<Asset> listAsset = assetSelector.SelectByIdWithActiveSuspension(getAssetsIds());

        System.assert(listAsset.size() >= 1);
    }

}