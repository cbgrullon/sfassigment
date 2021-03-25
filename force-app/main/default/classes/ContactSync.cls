public class ContactSync {
    public static void SyncContacts(List<Contact> contacts){
        try{
            Http client = new Http();
            HttpRequest request = new HttpRequest();
            uploadContactsRequest syncContactsRequest = new uploadContactsRequest();
            syncContactsRequest.contacts = contacts;
            request.setBody(JSON.serialize(syncContactsRequest));
            request.setEndpoint('callout:OtherOrg/services/apexrest/contactREST');
            request.setMethod('POST');
            request.setHeader('content-type', 'application/json');
            HttpResponse response = client.send(request);
            string bodyString = response.getBody();
            if(response.getStatusCode() != 200)
                throw new ApiException(response.getStatusCode(),response.getBody());
            List<upsertResult> result = (List<upsertResult>)JSON.deserialize(bodyString,List<upsertResult>.class);
            List<Contact> toUpdate = new List<Contact>();
            for(upsertResult ur:result){
                Contact c = new Contact();
                c.Id = ur.ExternalId;
                c.ExternalId__c = ur.InternalId;
                if(ur.ErrorMessage == null){
                    c.LastSyncMessage__C = 'Success';
                    c.IsLastSyncSuccess__c = true;
                }
                else
                    c.LastSyncMessage__C = ur.ErrorMessage;
                c.LastSyncDate__c = Datetime.now();
                toUpdate.add(c);
            }
            if(toUpdate.size() > 0)
                update toUpdate;
        }catch(Exception e){
            System.debug(e.getMessage()+' - '+e.getStackTraceString());
            List<Contact> toUpdate = new List<Contact>();
            for(Contact c:contacts){
                Contact item = new Contact();
                item.Id= c.ExternalId__c;
                item.LastSyncMessage__C = e.getMessage()+' - '+e.getStackTraceString();
                item.LastSyncDate__c = Datetime.now();
                toUpdate.add(item);
            }
            if(toUpdate.size() > 0)
                update toUpdate;
        }
        
    }
    public class ApiException extends Exception{
        public ApiException(Integer StatusCode,string body){
            this.StatusCode = StatusCode;
            this.Body = body;
            this.setMessage(string.valueOf(StatusCode)+' - '+body);
        }
        public integer StatusCode{get;set;}
        public string Body{get;set;}
    }
    public class uploadContactsRequest{
        public List<Contact> contacts{get;set;}
    }
    public class upsertResult{
        public string InternalId{get;set;}
        public string ExternalId{get;set;}
        public boolean IsSuccess{get;set;}
        public string ErrorMessage{get;set;}
    }
}