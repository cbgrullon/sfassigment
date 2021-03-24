//This class has to be in the Organization B
@restResource(urlMapping='/contactREST')
global class ContactREST {
    @httpPost
    global static List<upsertResultItem> handlePost(List<Contact> contacts){
        List<upsertResultItem> toReturn = new List<upsertResultItem>();
        Schema.DescribeFieldResult describeField = Contact.ExternalId__c.getDescribe();
        Schema.sObjectField field = describeField.getSObjectField();
        List<Database.UpsertResult> upsertResults = Database.upsert(contacts,field,false);
        for(Integer index =0;index< upsertResults.size(); index++){
            Database.UpsertResult upsertResult = upsertResults[index];
            Contact contact = contacts[index];
            upsertResultItem item = new upsertResultItem();
            item.IsSuccess = upsertResult.isSuccess();
            if(!item.IsSuccess){
                Database.Error error = upsertResult.getErrors()[0];
                item.ErrorMessage = error.getMessage();
            }
            item.InternalId = upsertResult.getId();
            item.ExternalId = contact.ExternalId__c;
            toReturn.add(item);
        }
        return toReturn;
    }
    global class upsertResultItem{
        public string InternalId{get;set;}
        public string ExternalId{get;set;}
        public boolean IsSuccess{get;set;}
        public string ErrorMessage{get;set;}
    }
}