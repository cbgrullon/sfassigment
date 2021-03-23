public class ContactSync {
    public static void SyncContacts(List<Contact> contacts){
        Http client = new Http();
        HttpRequest request = new HttpRequest();
        request.setBody(JSON.serialize(contacts));
        request.setEndpoint('callout:OtherOrg/services/apexrest/contactREST');
        request.setMethod('POST');
        HttpResponse response = client.send(request);
        string bodyString = response.getBody();
        List<Contact> toUpdate = new List<Contact>();
        if(response.getStatusCode() != 200){
            for(Contact c:contacts){
                string message = string.valueOf(response.getStatusCode()) + ' - '+response.getBody();
                toUpdate.add(new Contact(Id=c.Id,LastSyncMessage__c=message,LastSyncDate__c=DateTime.now()));
            }
            update toUpdate;
            return;
        }
        Map<string,string> result = (Map<string,string>)JSON.deserealize(Map<string,string>.class,bodyString);
        for(string key:result.keySet()){
            string value = result.get(key);
            toUpdate.add(new Contact(Id=key,LastSyncMessage__c = value,LastSyncDate__c = DateTime.now()));
        }
        update toUpdate;
    }
}
