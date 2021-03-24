global class ContactSyncSchedule implements Schedulable {
    global void execute(SchedulableContext sc){
        string query = 'Select Id ';
        Schema.FieldSet fieldSet = Schema.SObjectType.Contact.fieldSets.BatchFields;
        for(Schema.FieldSetMember member:fieldSet.getFields()){
            query += ','+ member.getFieldPath();
        }
        query += ' From Contact';
        ContactSyncBatch batch = new ContactSyncBatch(query);
        Database.executeBatch(batch,200);
    }
}