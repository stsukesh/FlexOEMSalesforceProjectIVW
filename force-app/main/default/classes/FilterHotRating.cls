public class FilterHotRating {

    public static void getHotAccounts() {

        System.debug('Starting Hot Account query');

        List<Account> hotAccList = [
            SELECT Id, Name, Rating
            FROM Account
            WHERE Rating = 'Hot'
        ];
        System.debug('Queried Hot Accounts: ' + hotAccList);

        System.debug(' Total Hot Accounts Found = ' + hotAccList.size());
        System.debug('list are '+hotAccList);
        
    }
}