import { LightningElement,wire } from 'lwc';
import getContacts from '@salesforce/apex/ContactControllerV2.getContacts';
import FirstNameField from '@salesforce/schema/Contact.FirstName';
import LastNameField from '@salesforce/schema/Contact.LastName';
import AccountIndustryField from '@salesforce/schema/Contact.Account.Industry';
import getFields from '@salesforce/apex/ContactControllerV2.getFields';
export default class ContactListToSync extends LightningElement {
    columns = [
        {label: 'First Name',fieldName:FirstNameField.fieldApiName, type: 'text'},
        {label: 'Last Name',fieldName:LastNameField.fieldApiName, type: 'text'},
        {label: 'Account Industry',fieldName:'AccountIndustry', type: 'text'}
    ];
    firstName;
    lastName;
    industry;
    skip = 0;
    take= 10;
    isLoading = true;
    selectedContacts = [];
    contacts = [];
    haveMore = false;
    connectedCallback(){
        this.loadContacts(true);
        // getFields({}).then(response=>{
        //     console.log(response)
        // }).catch(err=>{
        //     console.error(err)
        // });
    }
    loadContacts(override){
        this.isLoading = true;
        getContacts({
            skip:this.skip,
            take: this.take,
            firstNameFilter:this.firstName,
            lastNameFilter:this.lastName,
            industryFilter:this.industry
        }).then(response=>{
            //this.haveMore = response.HaveMore;
            if(override)
                this.contacts=response;
            else{
                let newContacts = [...this.contacts,...response];
                // for(let i =0;i<response.lenght;i++){
                //     const item = response[i];
                //     newContacts.push(item);
                // }
                this.contacts = newContacts;
            }
            this.isLoading = false;
        }).catch(error=>{
            console.error(error);
            this.isLoading = false;
        });
    }
    handleFilterChange(event){
        this[event.target.name] = event.target.value;
        this.skip = 0;
        this.loadContacts(true);
    }
    handleLoadMore(event){
        if(!this.isLoading){
            this.skip += this.take;
            this.loadContacts(false);
        }
    }
    handleSelectedRow(event){
        let toAppend = [];
        for(let i =0;i<event.detail.selectedRows.length;i++){
            const item = event.detail.selectedRows[i];
            console.log(item)
            let finded = this.selectedContacts.find((contact)=>{
                return contact.Id === item.Id;
            });
            if(finded)
                continue;
            toAppend.push(item);
        }
        this.selectedContacts = [...this.selectedContacts,...toAppend];
        console.log(this.selectedContacts);
    }
}