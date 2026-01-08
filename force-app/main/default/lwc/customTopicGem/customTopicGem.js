import { LightningElement, api, wire, track } from 'lwc';
import getAssignedTopics from '@salesforce/apex/TopicServiceGem.getAssignedTopics';
import createTopicAssignment from '@salesforce/apex/TopicServiceGem.createTopicAssignment';
import removeTopicAssignment from '@salesforce/apex/TopicServiceGem.removeTopicAssignment';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomTopicGem extends LightningElement {
    @api recordId;
    @track allTopics = [];
    @track filteredTopics = [];
    wiredResult;

    @wire(getAssignedTopics, { recordId: '$recordId' })
    wiredTopics(result) {
        this.wiredResult = result;
        if (result.data) {
            this.allTopics = result.data;
            this.filteredTopics = result.data;
        }
    }

    get topicCount() { return this.allTopics.length; }

    handleSearch(event) {
        const key = event.target.value.toLowerCase();
        this.filteredTopics = this.allTopics.filter(t => t.label.toLowerCase().includes(key));
    }

    async handleAddTopic(event) {
        const name = event.target.value;
        if (!name) return;
        try {
            await createTopicAssignment({ recordId: this.recordId, topicName: name });
            event.target.value = '';
            await refreshApex(this.wiredResult);
        } catch (error) {
            this.showError(error);
        }
    }

    async handleRemove(event) {
        const topicId = event.detail.item.name;
        try {
            await removeTopicAssignment({ recordId: this.recordId, topicId: topicId });
            await refreshApex(this.wiredResult);
        } catch (error) {
            this.showError(error);
        }
    }

    showError(error) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: error.body ? error.body.message : error.message,
            variant: 'error'
        }));
    }
}