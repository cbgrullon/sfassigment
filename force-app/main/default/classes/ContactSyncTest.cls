@isTest
public class ContactSyncTest {
    private static string CRON_EXP = '0 0 0 15 3 ? 2022';
    private static string exceptionMessage = 'Dummy exception';
    @testSetup
    public static void loadData(){
        List<Contact> toInsert = new List<Contact>();
        for(Integer i = 1;i<=200;i++){
            string lastName = 'LastName'+ string.valueOf(i);
            toInsert.add(new Contact(LastName=lastName));
        }
        insert toInsert;
    }
    @isTest
    public static void testBatchForSuccess(){
        string query = 'Select Id,LastName From Contact';
        Test.setMock(HttpCalloutMock.class, new ContactSyncCalloutMock(false,exceptionMessage,false));
        Test.startTest();
        ContactSyncBatch batch = new ContactSyncBatch(query);
        Database.executeBatch(batch,200);
        Test.stopTest();
        for(Contact c:[Select Id,LastSyncMessage__c From Contact]){
            System.assertEquals(true, c.IsLastSyncSuccess__c);
        }
    }
    @isTest
    public static void testBatchForError(){
        string query = 'Select Id,LastName From Contact';
        Test.setMock(HttpCalloutMock.class, new ContactSyncCalloutMock(true,exceptionMessage,false));
        Test.startTest();
        ContactSyncBatch batch = new ContactSyncBatch(query);
        Database.executeBatch(batch,200);
        Test.stopTest();
        for(Contact c:[Select Id,LastSyncMessage__c From Contact]){
            System.assert(c.LastSyncMessage__c.contains(exceptionMessage));
        }
    }
    @isTest
    public static void testBatchForBadRequest(){
        string query = 'Select Id,LastName From Contact';
        Test.setMock(HttpCalloutMock.class, new ContactSyncCalloutMock(false,exceptionMessage,true));
        Test.startTest();
        ContactSyncBatch batch = new ContactSyncBatch(query);
        Database.executeBatch(batch,200);
        Test.stopTest();
        for(Contact c:[Select Id,LastSyncMessage__c From Contact]){
            System.assert(c.LastSyncMessage__c.contains('400'));
        }
    }
    @isTest
    public static void testSchedule(){
        Test.setMock(HttpCalloutMock.class, new ContactSyncCalloutMock(false,exceptionMessage,false));
        Test.startTest();
        System.schedule('Contact Integration Test',CRON_EXP,new ContactSyncSchedule());
        Test.stopTest();
    }
}