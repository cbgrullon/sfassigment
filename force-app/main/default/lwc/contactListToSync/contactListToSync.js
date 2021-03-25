import { LightningElement, wire, track } from 'lwc';
import getContacts from '@salesforce/apex/ContactControllerV2.getContacts';
import FirstNameField from '@salesforce/schema/Contact.FirstName';
import LastNameField from '@salesforce/schema/Contact.LastName';
import LastSyncMessageField from '@salesforce/schema/Contact.LastSyncMessage__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AccountIndustryField from '@salesforce/schema/Contact.AccountIndustry__c';
import getFields from '@salesforce/apex/ContactControllerV2.getFields';
import getUserFieldsSelection from '@salesforce/apex/ContactControllerV2.getUserFieldsSelection';
import updateFieldSelection from '@salesforce/apex/ContactControllerV2.updateFieldSelection';
import sendToOtherOrg from '@salesforce/apex/ContactControllerV2.sendToOtherOrg';
export default class ContactListToSync extends LightningElement {
    columns = [
        { label: 'First Name', fieldName: FirstNameField.fieldApiName, type: 'text' },
        { label: 'Last Name', fieldName: LastNameField.fieldApiName, type: 'text' },
        { label: 'Account Industry', fieldName: AccountIndustryField.fieldApiName, type: 'text' }
    ];
    syncResultColumns = [
        { label: 'First Name', fieldName: FirstNameField.fieldApiName, type: 'text' },
        { label: 'Last Name', fieldName: LastNameField.fieldApiName, type: 'text' },
        { label: 'Error Message', fieldName: LastSyncMessageField.fieldApiName, type: 'text' }
    ]
    firstName;
    lastName;
    industry;
    skip = 0;
    take = 10;
    isLoading = true;
    selectedContacts = [];
    contacts = [];
    haveMore = false;
    cantSync = true;
    showFieldSelectionModal = false;
    fields = [];
    maxRowSelection = 20;
    selectedFields = [];
    syncResult = [];
    showSyncResult = false;
    async handlePromise(promise, callback) {
        this.isLoading = true;
        try {
            let response = await promise;
            callback(response);
        } catch (error) {
            this.handleError(error);
        }
        this.isLoading = false;
    }
    handleError(e) {
        let event = new ShowToastEvent({
            title: 'An error has ocurred.',
            variant: 'error'
        });
        this.dispatchEvent(event);
        console.error(e);
    }
    connectedCallback() {
        this.loadContacts(true);
        // getFields({}).then(response=>{
        //     console.log(response)
        // }).catch(err=>{
        //     console.error(err)
        // });
    }
    async loadContacts(override) {
        this.handlePromise(getContacts({
            skip: this.skip,
            take: this.take,
            firstNameFilter: this.firstName,
            lastNameFilter: this.lastName,
            industryFilter: this.industry
        }),
            response => {
                if (override)
                    this.contacts = response;
                else {
                    let newContacts = [...this.contacts, ...response];
                    // for(let i =0;i<response.lenght;i++){
                    //     const item = response[i];
                    //     newContacts.push(item);
                    // }
                    this.contacts = newContacts;
                    if(response.length ===0){
                        let event = new ShowToastEvent({
                            title: 'No more records found',
                            variant: 'info'
                        });
                        this.dispatchEvent(event);
                    }
                }
            });
    }
    handleFilterChange(event) {
        this[event.target.name] = event.target.value;
        this.skip = 0;
        this.loadContacts(true);
    }
    handleLoadMore(event) {
        if (!this.isLoading) {
            this.skip += this.take;
            this.loadContacts(false);
        }
    }
    handleSelectedRow(event) {
        this.selectedContacts = [...event.detail.selectedRows];
        this.cantSync = this.selectedContacts == 0;
    }
    async handleSyncClick() {
        this.isLoading = true;
        try {
            let fields = await getFields({});
            let selectedFields = await getUserFieldsSelection({});

            let selectedValues = [];
            let options = [];
            Object.keys(fields).forEach(key => {
                let finded = selectedFields.find(f => f.Name.toLowerCase() === key.toLowerCase());
                if (finded)
                    selectedValues.push(key);
                options.push({ value: key, label: fields[key] });
            });
            this.fields = options;
            this.selectedFields = selectedValues;
        } catch (error) {
            this.handleError(error);
        }
        this.isLoading = false;
        this.showFieldSelectionModal = true;
    }
    closeFieldSelectionModal() {
        this.showFieldSelectionModal = false;
    }
    async handleFieldSelection(event) {
        this.selectedFields = event.detail.value;
        this.handlePromise(updateFieldSelection({ fields: this.selectedFields }), () => {
            let event = new ShowToastEvent({
                title: 'Fields updated in database',
                variant: 'success'
            });
            this.dispatchEvent(event);
        });
    }
    async handleConfirmSync() {
        this.showFieldSelectionModal = false;
        let ids = this.selectedContacts.map(sc => sc.Id);
        this.handlePromise(sendToOtherOrg({ contactsId: ids }), response => {
            if (response == null) {
                throw 'Controller returns null';
            }
            this.syncResult = response;
            this.showSyncResult = true;
            let event = new ShowToastEvent({
                title: 'Contacts synced',
                variant: 'success'
            });
            this.dispatchEvent(event);
        });
    }
    closeSyncModal() {
        this.showSyncResult = false;
    }
}