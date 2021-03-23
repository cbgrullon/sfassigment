public class ContactSyncBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    public string query{get;set;}
    public ContactSyncBatch(string query) {
        this.query = query;
    }
    public Database.queryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context,List<sObject> contacts){
        System.debug('llegue');
        try{
            for(sObject sobj: contacts){
                string id = (string)sobj.get('Id');
                sobj.put('ExternalId__c',id);
                sobj.put('Id',null);
            }
            Map<string,string> result =  ContactSync.SyncContacts(contacts);
            List<Contact> toUpdate = new List<Contact>();
            for(string key: result.keySet()){
                string value = result.get(key);
                toUpdate.add(new Contact(Id=key,LastSyncMessage__C=value,LastSyncDate__c = datetime.now()));
            }
            update toUpdate;
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    public void finish(Database.BatchableContext BC){
    }
}