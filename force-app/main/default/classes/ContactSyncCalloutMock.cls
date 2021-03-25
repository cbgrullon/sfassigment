global class ContactSyncCalloutMock implements HttpCalloutMock{
    private boolean throwException;
    private boolean returnBadRequest;
    private string exceptionMessage;
    global ContactSyncCalloutMock(boolean throwException,string exceptionMessage,boolean returnBadRequest){
        this.throwException = throwException;
        this.exceptionMessage = exceptionMessage;
        this.returnBadRequest = returnBadRequest;
    }
    global HttpResponse respond(HttpRequest req){
        if(throwException)
            throw new System.CalloutException(exceptionMessage);
        HttpResponse response = new HttpResponse();
        if(returnBadRequest){
            response.setStatusCode(400);
            response.setBody('Bad Request');
            return response;
        }
        string body = req.getBody();
        ContactSync.uploadContactsRequest requestObj = (ContactSync.uploadContactsRequest)JSON.deserialize(body,ContactSync.uploadContactsRequest.class);
        List<Contact> contacts = requestObj.contacts;
        List<ContactSync.upsertResult> result = new List<ContactSync.upsertResult>();
        Integer index = 1;
        for(Contact c:contacts){
            ContactSync.upsertResult ur = new ContactSync.upsertResult();
            ur.IsSuccess = true;
            ur.InternalId = 'InternalId'+string.valueOf(index);
            ur.ExternalId = c.ExternalId__c;
            result.add(ur);
            index++;
        }
        response.setStatusCode(200);
        response.setHeader('content-type','application/json');
        response.setBody(JSON.serialize(result));
        return response;
    }
}