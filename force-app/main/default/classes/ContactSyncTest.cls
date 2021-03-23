@isTest
public class ContactSyncTest {
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
    public static void run(){
        string query = 'Select Id,LastName From Contact';
        ContactSyncCalloutMock mock = new ContactSyncCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        ContactSyncBatch batch = new ContactSyncBatch(query);
        Database.executeBatch(batch,200);
        Test.stopTest();
    }
}