global class ContactSyncSchedule implements Schedulable {
    global void execute(SchedulableContext sc){
        string query = 'Select Id ';
        Schema.FieldSet fieldSet = Schema.SObjectType.Contact.fieldSets.BatchFields;
        for(Schema.FieldSetMember member:fieldSet.getFields()){
            Schema.SObjectField sobjField = member.getSObjectField();
            Schema.DescribeFieldResult describeField = sobjField.getDescribe();
            DisplayType fieldType = describeField.getType();
            if(fieldType == DisplayType.Id || 
                fieldType == DisplayType.Reference || 
                fieldType == DisplayType.DataCategoryGroupReference ||
                describeField.isExternalId() ||
                describeField.isCalculated() ||
                !describeField.isAccessible() ||
                member.getFieldPath() == 'IsDeleted')
                continue;
            query += ','+ member.getFieldPath();
        }
        query += ' From Contact';
        ContactSyncBatch batch = new ContactSyncBatch(query);
        Database.executeBatch(batch,200);
    }
}