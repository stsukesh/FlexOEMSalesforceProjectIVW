/**
 * Author: Sukesh Subash
 * Date: 29/12/2025
 * Description: Test class for AccountTriggers and AccountTriggerHandler to ensure 
 * billing address is correctly copied to shipping address.
 */
@isTest
Public with sharing class AccountHandlerTest {
    
    
    //Methods to Test the copy billing -> Shipping addresss:

    /**
     * Method Name: getPositiveBillingCopyTest
     * Description: Positive test to ensure billing address copies to shipping on insert.
     */
    @isTest
    static void getPositiveBillingCopyTest() {
        Account acc = new Account(
            Name = 'Positive Test Acc',
            BillingStreet = '11 Brigade Road',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '560001',
            BillingCountry = 'India'
        );

        Test.startTest();
        insert acc;
        Test.stopTest();

        // SOQL assigned to List object
        List<Account> resultList = [SELECT ShippingStreet, ShippingCity FROM Account WHERE Id = :acc.Id LIMIT 1];
        
        System.assertEquals('11 Brigade Road', resultList[0].ShippingStreet, 'Shipping Street should match Billing Street');
        System.assertEquals('Bangalore', resultList[0].ShippingCity, 'Shipping City should match Billing City');
    }

    /**
     * Method Name: updatePositiveBillingChangeTest
     * Description: Positive test to ensure shipping updates when billing address changes.
     */
    @isTest
    static void updatePositiveBillingChangeTest() {
        Account acc = new Account(Name = 'Update Test Acc', BillingStreet = 'Old Street');
        insert acc;

        acc.BillingStreet = 'New Street';

        Test.startTest();
        update acc;
        Test.stopTest();

        List<Account> resultList = [SELECT ShippingStreet FROM Account WHERE Id = :acc.Id LIMIT 1];
        System.assertEquals('New Street', resultList[0].ShippingStreet, 'Shipping Street should update to match new Billing Street');
    }

    /**
     * Method Name: getNegativeNullBillingTest
     * Description: Negative test to ensure logic handles accounts with null billing fields.
     */
    @isTest
    static void getNegativeNullBillingTest() {
        // Creating account without billing info
        Account acc = new Account(Name = 'Null Billing Acc');

        Test.startTest();
        insert acc;
        Test.stopTest();

        List<Account> resultList = [SELECT ShippingStreet FROM Account WHERE Id = :acc.Id LIMIT 1];
        System.assertEquals(null, resultList[0].ShippingStreet, 'Shipping Street should remain null if Billing Street is null');
    }

    /**
     * Method Name: updateNegativeNoChangeTest
     * Description: Negative test to ensure no logic errors when updating unrelated fields.
     */
    @isTest
    static void updateNegativeNoChangeTest() {
        Account acc = new Account(Name = 'No Change Acc', BillingStreet = 'Constant St');
        insert acc;

        // Change an unrelated field
        acc.Phone = '123456789';

        Test.startTest();
        update acc;
        Test.stopTest();

        List<Account> resultList = [SELECT ShippingStreet FROM Account WHERE Id = :acc.Id LIMIT 1];
        System.assertEquals('Constant St', resultList[0].ShippingStreet, 'Shipping address should remain intact');
    }

    /**
     * Method Name: getBulkInsertTest
     * Description: Bulk test to ensure the trigger is bulkified as per standards.
     */
    @isTest
    static void getBulkInsertTest() {
        List<Account> accountList = new List<Account>();
        
        for (Integer i = 0; i < 200; i++) {
            accountList.add(new Account(
                Name = 'Bulk Acc ' + i,
                BillingStreet = 'Street ' + i
            ));
        }

        Test.startTest();
        insert accountList; // Bulkified DML
        Test.stopTest();

        List<Account> resultList = [SELECT Id FROM Account WHERE ShippingStreet LIKE 'Street %'];
        System.assertEquals(200, resultList.size(), 'All 200 records should have shipping address populated');
    }
    //=============================================
    //--END for copy billing -> Shipping addresss--
    //==============================================
    
    
}