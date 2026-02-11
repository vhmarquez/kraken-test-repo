import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import USER_PHOTO from '@salesforce/schema/User.FullPhotoUrl';
import createFeedItem from '@salesforce/apex/ChatterFeedController.createFeedItem';
import getFeedItems from '@salesforce/apex/ChatterFeedController.getFeedItems';
import likeFeedItem from '@salesforce/apex/ChatterFeedController.likeFeedItem';
import unlikeFeedItem from '@salesforce/apex/ChatterFeedController.unlikeFeedItem';

export default class CustomChatterFeed extends LightningElement {
    @api recordId;
    @track commentBody = '';
    @track feedItems = [];
    @track currentUserPhotoUrl;
    wiredFeedResult;
    formats = ['bold', 'italic', 'underline', 'strike', 'list', 'link', 'image', 'align', 'mention'];

    connectedCallback(){
        if(this.recordId == null) {
            this.recordId = '001ak00000iIU6QAAW';
        }
    }

    @wire(getRecord, { recordId: '$userId', fields: [USER_PHOTO] })
    wiredUser({ data }) {
        if (data) {
            this.currentUserPhotoUrl = data.fields.FullPhotoUrl.value;
        }
    }

    get userId() {
        return '005ak00000AdIlhAAF'; // Replace with dynamic import USER_ID from '@salesforce/user/Id';
    }

    @wire(getFeedItems, { recordId: '$recordId' })
    wiredFeedItems(result) {
        this.wiredFeedResult = result;
        const { data, error } = result;
        if (data) {
            this.feedItems = this.buildThreadedFeed(data);
        } else if (error) {
            this.showToast('Error', 'Failed to load feed: ' + error.body.message, 'error');
        }
    }

    buildThreadedFeed(flatItems) {
        // Create a deep copy to make data mutable
        const items = JSON.parse(JSON.stringify(flatItems));
        const itemMap = new Map();
        const roots = [];
        items.forEach(item => {
            item.replies = [];
            item.isLiked = item.FeedLikes?.size() > 0 && item.FeedLikes.some(like => like.CreatedById === this.userId) || false;
            item.likeCount = item.FeedLikes?.size() || 0;
            itemMap.set(item.Id, item);
        });
        items.forEach(item => {
            if (item.ParentId && item.ParentId !== this.recordId && itemMap.has(item.ParentId)) {
                itemMap.get(item.ParentId).replies.push(item);
            } else {
                roots.push(item);
            }
        });
        return roots;
    }

    handleBodyChange(event) {
        this.commentBody = event.target.value;
    }

    async handlePost(event) {
        const parentId = event?.detail?.parentId || this.recordId;
        if (!this.commentBody) {
            this.showToast('Warning', 'Comment body cannot be empty', 'warning');
            return;
        }
        try {
            await createFeedItem({ parentId, commentBody: this.commentBody });
            this.commentBody = '';
            await refreshApex(this.wiredFeedResult);
            this.showToast('Success', 'Comment posted successfully', 'success');
        } catch (error) {
            this.showToast('Error', 'Failed to post comment: ' + error.body.message, 'error');
        }
    }

    async handleReply(event) {
        this.commentBody = '';
        await this.handlePost({ detail: { parentId: event.detail.feedItemId } });
    }

    async handleLike(event) {
        const { feedItemId, isLiked } = event.detail;
        try {
            if (isLiked) {
                await unlikeFeedItem({ feedItemId });
            } else {
                await likeFeedItem({ feedItemId });
            }
            await refreshApex(this.wiredFeedResult);
        } catch (error) {
            this.showToast('Error', 'Failed to like/unlike: ' + error.body.message, 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}