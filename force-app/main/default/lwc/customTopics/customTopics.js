import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordTopics from '@salesforce/apex/TopicService.getRecordTopics';
import getTopicCount from '@salesforce/apex/TopicService.getTopicCount';
import searchTopics from '@salesforce/apex/TopicService.searchTopics';
import createTopicEnforcingCaseInsensitive from '@salesforce/apex/TopicService.createTopicEnforcingCaseInsensitive';
import assignTopicToRecord from '@salesforce/apex/TopicService.assignTopicToRecord';
import removeTopicFromRecord from '@salesforce/apex/TopicService.removeTopicFromRecord';
import followTopic from '@salesforce/apex/TopicService.followTopic';
import unfollowTopic from '@salesforce/apex/TopicService.unfollowTopic';
import { subscribe, unsubscribe, onError, setDebugFlag } from 'lightning/empApi';

export default class CustomTopics extends LightningElement {
    @api recordId;

    @track topics = [];
    @track count = 0;
    @track suggestions = [];
    @track showSuggestions = false;
    @track newTopic = '';
    @track filterKey = '';
    channelName = '/event/TopicEvent__e';
    subscription = null;

    get countLabel() {
        return `Count: ${this.count}`;
    }

    get createDisabled() {
        return !this.newTopic || !this.newTopic.trim();
    }

    connectedCallback() {
        this.refreshAll();
        this.subscribePE();
    }

    disconnectedCallback() {
        this.unsubscribePE();
    }

    async refreshAll() {
        try {
            // Authoritative data must come from server
            const [items, cnt] = await Promise.all([
                getRecordTopics({ recordId: this.recordId }),
                getTopicCount({ recordId: this.recordId })
            ]);
            // Recompute visibility from authoritative list only (no optimistic updates)
            const currFilter = (this.filterKey || '').toLowerCase();
            const list = Array.isArray(items) ? items : [];
            this.topics = list.map(t => {
                const visible = !currFilter || (t.name || '').toLowerCase().includes(currFilter);
                return { ...t, visible };
            });
            this.count = Number.isInteger(cnt) ? cnt : 0;
        } catch (e) {
            this.showError('Error loading topics', e?.body?.message || e.message);
        }
    }

    handleInputChange(event) {
        this.newTopic = event.detail.value || '';
        this.fetchSuggestions(this.newTopic);
    }

    handleKeydown(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            this.handleCreateTopic();
        }
    }

    async fetchSuggestions(key) {
        const term = (key || '').trim();
        if (!term) {
            this.suggestions = [];
            this.showSuggestions = false;
            return;
        }
        try {
            const res = await searchTopics({ searchKey: term });
            this.suggestions = res || [];
            this.showSuggestions = this.suggestions.length > 0;
        } catch (e) {
            // Do not toast on every keystroke; keep silent
            this.suggestions = [];
            this.showSuggestions = false;
        }
    }

    handleSuggestionClick(event) {
        const id = event.currentTarget?.dataset?.id;
        const name = event.currentTarget?.dataset?.name;
        if (id && name) {
            this.assignExisting(id, name);
        }
        this.showSuggestions = false;
    }

    async handleCreateTopic() {
        // Never assume or mutate UI state before server success
        const name = (this.newTopic || '').trim();
        const input = this.template.querySelector('lightning-input[data-role="createInput"]');
        if (!name) {
            if (input) {
                input.setCustomValidity('Topic name is required');
                input.reportValidity();
            }
            return;
        }
        try {
            const created = await createTopicEnforcingCaseInsensitive({ name });
            if (this.recordId && created?.id) {
                await assignTopicToRecord({ topicId: created.id, recordId: this.recordId });
            }
            this.newTopic = '';
            if (input) {
                input.setCustomValidity('');
                input.reportValidity();
            }
            // Always refetch authoritative list and count
            await this.refreshAll();
        } catch (e) {
            const msg = e?.body?.message || e.message || 'Failed to create topic';
            if (input) {
                input.setCustomValidity(msg);
                input.reportValidity();
            }
        }
    }

    async assignExisting(topicId) {
        try {
            await assignTopicToRecord({ topicId, recordId: this.recordId });
            // Refetch authoritative list and count
            await this.refreshAll();
        } catch (e) {
            const msg = e?.body?.message || e.message;
            // Inline error surface via toast is acceptable for assignment failures
            this.showError('Assign Topic', msg);
        }
    }

    async handleRemove(event) {
        const tid = event.currentTarget?.dataset?.id;
        if (!tid) return;
        try {
            await removeTopicFromRecord({ topicId: tid, recordId: this.recordId });
            // Refetch authoritative list and count
            await this.refreshAll();
        } catch (e) {
            const msg = e?.body?.message || e.message;
            this.showError('Remove Topic', msg);
        }
    }

    handleFilterChange(event) {
        this.filterKey = event.detail.value || '';
        const key = this.filterKey.toLowerCase();
        let anyVisible = false;
        this.topics = (this.topics || []).map(t => {
            const visible = !key || (t.name || '').toLowerCase().includes(key);
            if (visible) anyVisible = true;
            return { ...t, visible };
        });
        this.noVisible = !anyVisible && (this.topics || []).length > 0;
    }

    // Real-time via Platform Event
    subscribePE() {
        try {
            setDebugFlag(false);
            const messageCallback = (response) => {
                try {
                    const payload = response?.data?.payload || {};
                    const recId = payload.RecordId__c;
                    // Refresh if event pertains to this record or if we're in create mode (no recordId)
                    // We refresh on any topic event to ensure count is updated properly
                    if (!this.recordId || !recId || recId === this.recordId) {
                        this.refreshAll();
                    }
                } catch (e) {
                    // ignore
                }
            };
            subscribe(this.channelName, -1, messageCallback).then((resp) => {
                this.subscription = resp;
            });
            onError(() => {
                // ignore errors; component still works without real-time
            });
        } catch (e) {
            // ignore
        }
    }

    unsubscribePE() {
        try {
            if (this.subscription) {
                unsubscribe(this.subscription, () => {
                    this.subscription = null;
                });
            }
        } catch (e) {
            // ignore
        }
    }

    showSuccess(title, message) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant: 'success' }));
    }

    showError(title, message) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant: 'error' }));
    }

    async handleFollow(event) {
        const tid = event.currentTarget?.dataset?.id;
        if (!tid) return;
        try {
            await followTopic({ topicId: tid });
            // Refetch authoritative list to update isFollowed status
            await this.refreshAll();
        } catch (e) {
            const msg = e?.body?.message || e.message;
            this.showError('Follow Topic', msg);
        }
    }

    async handleUnfollow(event) {
        const tid = event.currentTarget?.dataset?.id;
        if (!tid) return;
        try {
            await unfollowTopic({ topicId: tid });
            // Refetch authoritative list to update isFollowed status
            await this.refreshAll();
        } catch (e) {
            const msg = e?.body?.message || e.message;
            this.showError('Unfollow Topic', msg);
        }
    }
}