public class ContactSync {
    public static List<upsertResult> SyncContacts(List<Contact> contacts){
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
        return result;
    }
    public class ApiException extends Exception{
        public ApiException(Integer StatusCode,string body){
            this.StatusCode = StatusCode;
            this.Body = body;
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