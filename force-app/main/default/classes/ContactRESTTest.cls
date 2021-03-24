@isTest
public class ContactRESTTest {
    private static List<Contact> GetContactsForTest(boolean includeExternalId,boolean includeLastName, Integer quantity){
        List<Contact> toReturn = new List<Contact>();
        for(Integer i=1;i<=quantity;i++){
            Contact toAdd = new Contact();
            if(includeExternalId)
                toAdd.ExternalId__c = 'ExternalId:'+string.valueOf(i);
            if(includeLastName)
                toAdd.LastName = 'LastName'+string.valueOf(i);
            toReturn.add(toAdd);
        }
        return toReturn;
    }
    @isTest
    public static void runWithoutExternalId(){
        List<Contact> contacts = GetContactsForTest(false,false,200);
        List<contactREST.upsertResultItem> result = ContactREST.handlePost(contacts);
        for(contactREST.upsertResultItem ur:result){
            System.assertEquals(false, ur.IsSuccess);
        }
    }
    @isTest
    public static void runWithoutLastName(){
        List<Contact> contacts = GetContactsForTest(true,false,200);
        List<contactREST.upsertResultItem> result = ContactREST.handlePost(contacts);
        for(contactREST.upsertResultItem ur:result){
            System.assertEquals(false, ur.IsSuccess);
        }
    }
    @isTest
    public static void runForSuccess(){
        List<Contact> contacts = GetContactsForTest(true,true,200);
        List<contactREST.upsertResultItem> result = ContactREST.handlePost(contacts);
        for(contactREST.upsertResultItem ur:result){
            System.assertEquals(true, ur.IsSuccess);
        }
    }
}