import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getTopicData from '@salesforce/apex/TopicController.getTopicData';
import saveTopics from '@salesforce/apex/TopicController.saveTopics';
import removeTopic from '@salesforce/apex/TopicController.removeTopic';
import searchGlobalTopics from '@salesforce/apex/TopicController.searchGlobalTopics';

export default class Topicreplication extends LightningElement {
    @api recordId;
    @track topics = []; 
    @track searchResults = [];
    @track isLoading = false; 
    @track errorMessage = '';
    @track isExpanded = false;
    
    INITIAL_LIMIT = 10;
    topicInput = '';
    isDropdownOpen = false;
    wiredTopicResponse; 

    @wire(getTopicData, { recordId: '$recordId' })
    wiredGetTopics(response) {
        this.wiredTopicResponse = response;
        if (response.data) {
            let textValue = response.data.topicText || '';
            this.topics = textValue ? textValue.split(';').map(t => t.trim()).filter(t => !!t) : [];
            this.errorMessage = '';
        }
    }

    @wire(searchGlobalTopics, { searchTerm: '$topicInput' })
    wiredSearchResults({ data }) {
        if (data) { this.searchResults = data; }
    }

    get topicCount() { return this.topics.length; }
    
    get comboboxClass() {
        return `slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ${this.isDropdownOpen ? 'slds-is-open' : ''}`;
    }

    get showAddNew() {
        return this.topicInput?.length > 1 && !this.topics.includes(this.topicInput);
    }
    /**
     * Getter to return the list of topics to display based on expansion state
     */
    get visibleTopics() {
        if (this.isExpanded || this.topics.length <= this.INITIAL_LIMIT) {
            return this.topics;
        }
        return this.topics.slice(0, this.INITIAL_LIMIT);
    }

    get showMoreButton() {
        return !this.isExpanded && this.topics.length > this.INITIAL_LIMIT;
    }

    get showLessButton() {
        return this.isExpanded && this.topics.length > this.INITIAL_LIMIT;
    }

    handleToggleExpand() {
        this.isExpanded = !this.isExpanded;
    }

    
    handleChange(event) {
        this.topicInput = event.target.value;
        this.isDropdownOpen = true;
    }

    handleFocus() {
        if (this.topicInput.length > 0) this.isDropdownOpen = true;
    }

    handleBlur() {
        // Delay to allow handleSelect/addTopic to fire before hiding dropdown
        setTimeout(() => { this.isDropdownOpen = false; }, 250);
    }

    handleSelect(event) {
        // Look for data-value on the element or its parent
        this.topicInput = event.currentTarget.querySelector('[data-value]').dataset.value;
        this.addTopic();
    }

    addTopic() {
        const newTopic = this.topicInput.trim();
        if (!newTopic || this.topics.includes(newTopic)) return;

        const originalTopics = [...this.topics];
        this.topics = [...this.topics, newTopic]; // Optimistic UI
        this.isLoading = true;
        this.topicInput = '';

        saveTopics({ recordId: this.recordId, topicInput: newTopic })
            .then(() => {
                this.showNotification('Success', `Topic "${newTopic}" added`, 'success');
                return refreshApex(this.wiredTopicResponse);
            })
            .catch(error => {
                this.topics = originalTopics; // Rollback
                this.errorMessage = error.body?.message || 'Error saving topic';
            })
            .finally(() => { this.isLoading = false; });
    }

    handleRemove(event) {
        const topicName = event.target.label;
        const originalTopics = [...this.topics];

        this.topics = this.topics.filter(t => t !== topicName); // Optimistic UI
        this.isLoading = true;

        removeTopic({ recordId: this.recordId, topicName: topicName })
            .then(() => {
                this.showNotification('Success', 'Topic removed', 'success');
                return refreshApex(this.wiredTopicResponse);
            })
            .catch(() => {
                this.topics = originalTopics; // Rollback
                this.showNotification('Error', 'Failed to remove topic', 'error');
            })
            .finally(() => { this.isLoading = false; });
    }

    showNotification(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}