@isTest
public class ContactControllerV2Test {
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
    public static void getContactsTests(){
        //Test pagination no filters
        List<Contact>contacts = ContactControllerV2.getContacts(0,10,null,null,null);
        System.assertEquals(10,contacts.size());
        //Test firstName Filter
        contacts = ContactControllerV2.getContacts(0,10,'Do not find contacts',null,null);
        System.assertEquals(0,contacts.size());
        //Test LastName Filter
        contacts = ContactControllerV2.getContacts(0,10,null,'Do not find contacts',null);
        System.assertEquals(0,contacts.size());
        //Test account industry filter
        contacts = ContactControllerV2.getContacts(0,10,null,null,'Do not find contacts');
        System.assertEquals(0,contacts.size());
    }
    @isTest
    public static void getFieldsTests(){
        Map<string,string> fields = ContactControllerV2.getFields();
        List<string> toSelect = new List<string>();
        for(string key:fields.keySet()){
            System.assertNotEquals('id', key.toLowerCase());
            System.assertNotEquals('externalid__c', key.toLowerCase());
            toSelect.add(key);
        }
        ContactControllerV2.updateFieldSelection(toSelect);
        List<UserField__c> selected =ContactControllerV2.getUserFieldsSelection();
        System.assertEquals(toSelect.size(), selected.size());
    }
    @isTest
    public static void sendToOtherOrgTests(){
        ContactControllerV2.updateFieldSelection(new List<string>{'firstname,lastname'});
        List<string> contactsId = new List<string>();
        List<Contact> result = ContactControllerV2.sendToOtherOrg(contactsId);
        System.assertEquals(null, result);
        for(Contact c:[Select Id From Contact Limit :21]){
            contactsId.add(c.Id);
        }
        result = ContactControllerV2.sendToOtherOrg(contactsId);
        System.assertEquals(null, result);
        contactsId.remove(1);
        Test.setMock(HttpCalloutMock.class, new ContactSyncCalloutMock(false,null,false));
        Test.startTest();
        result = ContactControllerV2.sendToOtherOrg(contactsId);
        Test.stopTest();
        System.assertEquals(contactsId.size(), result.size());
    }
}