import { LightningElement, api } from 'lwc';
import getTopicField from '@salesforce/apex/TopicController.getTopicField';
import saveTopics from '@salesforce/apex/TopicController.saveTopics';
import removeTopic from '@salesforce/apex/TopicController.removeTopic';

export default class Topicreplication extends LightningElement {
    @api recordId;
    errorTimeout;

    topicInput = '';
    // Full list of topics (authoritative)
    allTopics = [];
    // Filtered/visible topics
    topics = [];
    topicCount = 0;
    errorMessage = '';

    /* =========================
       INIT
       ========================= */
    connectedCallback() {
        this.loadTopics();
    }
    // renderedCallback(){
    //     this.loadTopics();
    
    // }

    /* =========================
       LOAD TOPICS (INITIAL ONLY)
       ========================= */
    loadTopics() {
        getTopicField({ recordId: this.recordId })
            .then(result => {
                this.allTopics = result
                    ? result.split(';').map(t => t.trim()).filter(t => !!t)
                    : [];
                this.applyFilter();
            })
            .catch(() => {
                this.allTopics = [];
                this.applyFilter();
            });
    }

    /* =========================
       INPUT HANDLING
       ========================= */
   handleChange(event) {
    const newValue = event.target.value;

    //  Clear error when user changes input
    if (this.topicInput !== newValue) {
        this.errorMessage = '';
        if (this.errorTimeout) {
            clearTimeout(this.errorTimeout);
            this.errorTimeout = null;
        }
    }

    this.topicInput = newValue;
    // Apply client-side search filter on each change
    this.applyFilter();
}

    handleKeyDown(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            this.addTopic();
        }
    }

    /* =========================
       ADD TOPIC 
       ========================= */
   addTopic() {
    const newTopic = this.topicInput.trim();
    if (!newTopic) return;

    // Check duplicate against the full list
    const exists = this.allTopics.some(
        t => t.toLowerCase() === newTopic.toLowerCase()
    );

    if (exists) {
        this.errorMessage = 'A topic with that name already exists.';

        if (this.errorTimeout) {
            clearTimeout(this.errorTimeout);
        }

        this.errorTimeout = setTimeout(() => {
            this.errorMessage = '';
            this.errorTimeout = null;
        }, 5000);

        return;
    }

    // Clear error & timer on valid add
    this.errorMessage = '';
    if (this.errorTimeout) {
        clearTimeout(this.errorTimeout);
        this.errorTimeout = null;
    }

    // Optimistic UI update against the full list
    this.allTopics = [...this.allTopics, newTopic];
    // Clear input before applying filter (so list re-filters with empty input to show all)
    this.topicInput = '';
    this.applyFilter();

    saveTopics({
        recordId: this.recordId,
        topicInput: newTopic
    }).catch(error => {
        // Rollback in full list, then re-apply filter
        this.allTopics = this.allTopics.filter(t => t !== newTopic);
        this.applyFilter();
        this.errorMessage =
            error?.body?.message || 'Unable to add topic';
    });
}

    /* =========================
       REMOVE TOPIC (OPTIMISTIC)
       ========================= */
    handleRemove(event) {
        const topicName = event.currentTarget.dataset.name;
        if (!topicName) return;

        this.errorMessage = '';

        // Optimistic UI update on the full list
        this.allTopics = this.allTopics.filter(t => t !== topicName);
        this.applyFilter();

        removeTopic({
            recordId: this.recordId,
            topicName
        }).catch(() => {
            // Rollback on the full list, then re-apply filter
            this.allTopics = [...this.allTopics, topicName];
            this.applyFilter();
            this.errorMessage = 'Unable to remove topic';
        });
    }
    /* =========================
       FILTERING
       ========================= */
    applyFilter() {
        const query = (this.topicInput || '').toLowerCase().trim();

        if (!query) {
            this.topics = this.allTopics.slice();
        } else {
            this.topics = this.allTopics.filter(t =>
                (t || '').toLowerCase().includes(query)
            );
        }

        this.topicCount = this.topics.length;
    }
}
