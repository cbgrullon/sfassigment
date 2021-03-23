global class ContactSyncCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
        HttpResponse response = new HttpResponse();
        string body = req.getBody();
        if(req.getHeader('content-type') != 'application/json'|| body == ''){
            response.setStatusCode(400);
            response.setBody('');
            return response;
        }
        ContactSync.uploadContactsRequest requestObj = (ContactSync.uploadContactsRequest)JSON.deserialize(body,ContactSync.uploadContactsRequest.class);
        List<Contact> contacts = requestObj.contacts;
        List<ContactSync.upsertResult> result = new List<ContactSync.upsertResult>();
        Integer index = 1;
        for(Contact c:contacts){
            ContactSync.upsertResult ur = new ContactSync.upsertResult();
            ur.IsSuccess = c.LastName != '' && c.ExternalId__c != '';
            if(ur.IsSuccess)
                ur.ErrorMessage = 'Invalid fields';
            ur.InternalId = 'InternalId'+string.valueOf(index);
            ur.ExternalId = c.ExternalId__c;
            index++;
        }
        response.setStatusCode(200);
        response.setHeader('content-type','application/json');
        response.setBody(JSON.serialize(result));
        return response;
    }
}