public class ContactSyncBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    public string query{get;set;}
    public ContactSyncBatch(string query) {
        this.query = query;
    }
    public Database.queryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context,List<sObject> contacts){
        for(sObject sobj: contacts){
            string id = (string)sobj.get('Id');
            sobj.put('ExternalId__c',id);
            sobj.put('Id',null);
        }
        ContactSync.SyncContacts(contacts);
    }
    public void finish(Database.BatchableContext BC){
    }
}