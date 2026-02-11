import { LightningElement, api, track } from 'lwc';

export default class ChatterFeedTile extends LightningElement {
    @api feedItem;
    @api currentUserPhotoUrl;
    @track showReplyEditor = false;
    @track replyBody = '';
    formats = ['bold', 'italic', 'underline', 'strike', 'list', 'link', 'image', 'align', 'mention'];

    get likeIcon() {
        return this.feedItem.isLiked ? 'utility:like' : 'utility:dislike';
    }

    get defaultAvatar() {
        return '/img/icon/profile32.png'; // Use Salesforce default or your org’s static resource
    }

    handleReplyClick() {
        this.showReplyEditor = !this.showReplyEditor;
    }

    handleReplyBodyChange(event) {
        this.replyBody = event.target.value;
    }

    postReply() {
        if (!this.replyBody) return;
        this.dispatchEvent(new CustomEvent('reply', { 
            detail: { feedItemId: this.feedItem.Id, body: this.replyBody } 
        }));
        this.replyBody = '';
        this.showReplyEditor = false;
    }

    toggleLike() {
        const isLiked = !this.feedItem.isLiked;
        this.dispatchEvent(new CustomEvent('like', { 
            detail: { feedItemId: this.feedItem.Id, isLiked } 
        }));
    }

    handleReply(event) {
        this.dispatchEvent(new CustomEvent('reply', { detail: event.detail }));
    }

    handleLike(event) {
        this.dispatchEvent(new CustomEvent('like', { detail: event.detail }));
    }
}