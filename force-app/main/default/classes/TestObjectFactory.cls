/**
* Author: Sukesh Subash
* Date: 26/12/2025
* Description: Factory class to generate bulk test data for Account and User objects.
*/
@isTest
public class TestObjectFactory {
    
    /**
* Method Name: getAccountRecords
* Description: Creates a specified number of Account records with a specific rating.
*/
    public static List<Account> getAccountRecords(String rating, Integer count) {
        if (count == null || count <= 0) {
            return new List<Account>();
        }
        
        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            Account acc = new Account();
            acc.Name = 'Test Acc ' + i;
            acc.Rating = rating;
            accList.add(acc);
        }
        
        insert accList;
        return accList;
    }
    
    /**
* Method Name: createStandardUser
* Description: Creates a test user with Standard User profile.
*/
    public static User createStandardUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'tusr',
            Email = 'testuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + DateTime.now().getTime() + '@testorg.com'
        );
        insert u;
        return u;
    }
    /**
* Method Name: getCaseRecords
* Description: get the case records with respective data that being passed to the method.
*/
    public static List<Case> getCaseRecords(String status, Integer count) {
        if (count == null || count <= 0) {
            return new List<Case>();
        }
        
        List<Case> caseList = new List<Case>();
        for (Integer i = 0; i < count; i++) {
            caseList.add(new Case(
                Subject = 'Original Case ' + i,
                Status = status,
                Origin = 'Web'
            ));
        }
        insert caseList;
        return caseList;
    }
        
    }