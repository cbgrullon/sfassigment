public class ContactControllerV2 {
    public ContactControllerV2() {

    }
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Integer skip,Integer take, string firstNameFilter,string lastNameFilter,string industryFilter){
        List<Contact> result = new List<Contact>();
        //result.HaveMore = false;
        //Initialize LastName != '' for the first filter and because LastName is required
        string empty = '';
        string whereClause = 'Where Id != :empty';
        if(!StringNullOrEmptyOrWhiteSpace(firstNameFilter)){
            string likeFirstName = getLikeFilter(firstNameFilter);
            whereClause+=' And (FirstName = :firstNameFilter Or FirstName Like :likeFirstName)';
        }
        if(!StringNullOrEmptyOrWhiteSpace(lastNameFilter)){
            string likeLastName = getLikeFilter(lastNameFilter);
            whereClause += ' And (LastName = :lastNameFilter Or LastName Like :likeLastName)';
        }
        if(!StringNullOrEmptyOrWhiteSpace(industryFilter)){
            string likeIndustry = getLikeFilter(industryFilter);
            whereClause += ' And (Account.Industry = :industryFilter Or Account.Industry Like :likeIndustry)';
        }
        string query = 'Select Id, FirstName, LastName, AccountIndustry__c From Contact '+whereClause;
        //Integer count = Database.countQuery(countQuery);
        query += ' Limit :take OFFSET :skip';
        result = Database.Query(query);
        return result;
    }
    @AuraEnabled(cacheable=true)
    public static Map<string,string> getFields(){
        SObjectType contactType = Schema.getGlobalDescribe().get('Contact');
        Map<string,Schema.SObjectField> contactFields = contactType.getDescribe().fields.getMap();
        Map<string,string> toReturn = new Map<string,string>();
        for(string key:contactFields.keySet()){
            Schema.SObjectField field = contactFields.get(key);
            DescribeFieldResult describeField =field.getDescribe();
            DisplayType fieldType= describeField.getType();
            if(fieldType == DisplayType.Id || 
                fieldType == DisplayType.Reference || 
                fieldType == DisplayType.DataCategoryGroupReference ||
                describeField.isExternalId() ||
                describeField.isCalculated() ||
                !describeField.isAccessible())
                continue;
            toReturn.put(key,describeField.getLabel());
        }
        return toReturn;
    }
    @AuraEnabled(cacheable=true)
    public static List<UserField__c> getUserFieldsSelection(){
        return [Select Id,Name From UserField__c Where OwnerId = :UserInfo.getUserId()];
    }
    @AuraEnabled
    public static void updateFieldSelection(List<string> fields){
        List<UserField__c> records = [Select Id From UserField__c Where OwnerId = :UserInfo.getUserId()];
        delete records;
        records = new List<UserField__c>();
        for(string field:fields){
            records.add(new UserField__c(Name = field));
        }
        insert records;
    }
    @AuraEnabled
    public static List<Contact> sendToOtherOrg(List<string> contactsId){
        if(contactsId.size() == 0)
            return null;
        List<UserField__c> fieldsToSend = [Select Name From UserField__c Where OwnerId = :UserInfo.getUserId()];
        string query = 'Select Id';
        for(UserField__c uf: fieldsToSend){
            query+=','+uf.Name;
        }
        query += ' From Contact Where Id In :contactsId';
        List<sObject> sobjs = Database.Query(query);
        List<Contact> toSend = new List<Contact>();
        for(sObject sobj:sobjs){
            Contact c = (Contact)sobj;
            c.ExternalId__c = c.Id;
            c.Id = null;
            toSend.add(c);
        }
        ContactSync.SyncContacts(toSend);
        return [Select Id,FirstName,LastName, LastSyncMessage__C,LastSyncDate__c From Contact Where Id in :contactsId];
    }
    public class ContactPaginationRequestDTO{
        public Integer Skip{get;set;}
        public Integer Take{get;set;}
        public string FirstNameFilter{get;set;}
        public string LastNameFilter{get;set;}
        public string IndustryFilter{get;set;}
    }
    public class ContactPaginationResponseDTO{
        public List<Contact> Items{get;set;}
        public boolean HaveMore{get;set;}
        public Integer Count{get;set;}
    }
    private static boolean StringNullOrEmptyOrWhiteSpace(string value){
        if(value == null)
            return true;
        if(value.trim() == '')
            return true;
        return false;
    }
    private static string getLikeFilter(string value){
        return '%'+string.escapeSingleQuotes(value)+'%';
    }
}