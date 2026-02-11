public with sharing class ChatterFeedController {
    @AuraEnabled(cacheable=true)
    public static List<FeedItem> getFeedItems(Id recordId) {
        try {
            // Fetch top-level posts
            List<FeedItem> topLevelItems = [
                SELECT Id, Body, CreatedBy.Name, CreatedDate, ParentId,
                       (SELECT Id, CreatedById FROM FeedLikes)
                FROM FeedItem 
                WHERE ParentId = :recordId
                ORDER BY CreatedDate DESC 
                LIMIT 100
            ];

            // Collect IDs of top-level posts to fetch replies
            Set<Id> parentFeedItemIds = new Set<Id>();
            for (FeedItem item : topLevelItems) {
                parentFeedItemIds.add(item.Id);
            }

            // Fetch replies
            List<FeedItem> replyItems = [
                SELECT Id, Body, CreatedBy.Name, CreatedDate, ParentId,
                       (SELECT Id, CreatedById FROM FeedLikes)
                FROM FeedItem 
                WHERE ParentId IN :parentFeedItemIds
                ORDER BY CreatedDate DESC 
                LIMIT 100
            ];

            // Combine top-level posts and replies
            List<FeedItem> allItems = new List<FeedItem>();
            allItems.addAll(topLevelItems);
            allItems.addAll(replyItems);
            return allItems;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to load feed: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void createFeedItem(Id parentId, String commentBody) {
        try {
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = commentBody; // Supports @mentions like @[userId]
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>{ textSegment };
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = parentId;
            ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
        } catch (Exception e) {
            throw new AuraHandledException('Failed to post comment: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void likeFeedItem(Id feedItemId) {
        try {
            ConnectApi.ChatterFeeds.likeFeedElement(null, feedItemId);
        } catch (Exception e) {
            throw new AuraHandledException('Failed to like comment: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void unlikeFeedItem(Id feedItemId) {
        try {
            ConnectApi.ChatterLikePage likes = ConnectApi.ChatterFeeds.getLikesForFeedElement(null, feedItemId);
            for (ConnectApi.ChatterLike chatterLike : likes.items) {
                if (chatterLike.user.id == UserInfo.getUserId()) {
                    ConnectApi.ChatterFeeds.deleteLike(null, chatterLike.id);
                    break;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Failed to unlike comment: ' + e.getMessage());
        }
    }
}