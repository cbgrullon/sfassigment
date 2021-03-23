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
        string query = 'Select Id, FirstName, LastName, Account.Industry From Contact '+whereClause;
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
            toReturn.put(key,describeField.getLabel());
        }
        return toReturn;
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