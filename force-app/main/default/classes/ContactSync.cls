public class ContactSync {
    public static Map<string,string> SyncContacts(List<Contact> contacts){
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
        Map<string,object> result = (Map<string,object>)JSON.deserializeUntyped(bodyString);
        Map<string,string> toReturn = new Map<string,string>();
        for(string key:result.keySet()){
            toReturn.put(key,(string)result.get(key));
        }
        return toReturn;
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
}