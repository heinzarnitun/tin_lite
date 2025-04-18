import 'package:twitter_api_v2/twitter_api_v2.dart' as v2;
import 'dart:io';

//a service class to handle posting messages with or without images
class TwitterService {
  //private instance of the twitter api
  final v2.TwitterApi _twitter;
//constructor to create a twitterservice instance
  //accepts either pre-built oauthtokens or individual key/secret/token strings
  TwitterService({
    v2.OAuthTokens? oauthTokens,
    String? consumerKey,
    String? consumerSecret,
    String? accessToken,
    String? accessTokenSecret,
  }) : _twitter = v2.TwitterApi(
    bearerToken: '', // required parameter, even if empty
   //if no 0authtokens provided, try creating them from keys
    oauthTokens: oauthTokens ?? (consumerKey != null && consumerSecret != null && accessToken != null && accessTokenSecret != null
        ? v2.OAuthTokens(
      consumerKey: consumerKey,
      consumerSecret: consumerSecret,
      accessToken: accessToken,
      accessTokenSecret: accessTokenSecret,
    )
        : null),
  );

  //post a message to twitter
  //if image path is provided it uploads the image first before the message
  Future<void> postTweet(String text, {String? imagePath}) async {
    try {
      String? mediaId;
      //if there is an image, upload first
      if (imagePath != null) {
        final uploadedMedia = await _twitter.media.uploadMedia(
          file: File(imagePath), //convert to file object
        );
        mediaId = uploadedMedia.data.id; //get the uploaded media id
      }
//create message with or without image
      await _twitter.tweets.createTweet(
        text: text,
        media: mediaId != null
            ? v2.TweetMediaParam(mediaIds: [mediaId])
            : null,
      );
    } on v2.TwitterUploadException catch (e) {
      //handle image upload errors
      print('Twitter upload failed: ${e.message}');
      rethrow;
    } on v2.TwitterException catch (e) {
      //handle other twitter related errors
      print("Twitter post failed: $e");
      rethrow;
    }
  }
}