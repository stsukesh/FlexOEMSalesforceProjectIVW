import { LightningElement, api } from 'lwc';
import getTopicField from '@salesforce/apex/TopicController.getTopicField';
import saveTopics from '@salesforce/apex/TopicController.saveTopics';
import removeTopic from '@salesforce/apex/TopicController.removeTopic';

export default class Topicreplication extends LightningElement {
    @api recordId;
    errorTimeout;

    topicInput = '';
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
                this.topics = result
                    ? result.split(';').map(t => t.trim())
                    : [];
                this.topicCount = this.topics.length;
            })
            .catch(() => {
                this.topics = [];
                this.topicCount = 0;
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

    const exists = this.topics.some(
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

    // Optimistic UI update
    this.topics = [...this.topics, newTopic];
    this.topicCount = this.topics.length;
    this.topicInput = '';

    saveTopics({
        recordId: this.recordId,
        topicInput: newTopic
    }).catch(error => {
        this.topics = this.topics.filter(t => t !== newTopic);
        this.topicCount = this.topics.length;
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

        // Optimistic UI update
        this.topics = this.topics.filter(t => t !== topicName);
        this.topicCount = this.topics.length;

        removeTopic({
            recordId: this.recordId,
            topicName
        }).catch(() => {
            // Rollback
            this.topics = [...this.topics, topicName];
            this.topicCount = this.topics.length;
            this.errorMessage = 'Unable to remove topic';
        });
    }
}