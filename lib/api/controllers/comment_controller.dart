import 'dart:convert';
import 'package:travel_buddy_finder/api/models/comment_model.dart';
import 'package:travel_buddy_finder/core/constants/url.dart';
import 'package:travel_buddy_finder/core/network/api_client.dart';
import 'package:travel_buddy_finder/features/profile/data/current_user.dart';

class CommentController {
  // 1. GET Comments for a Trip (/get_comments?trip_id=4)
  Future<List<CommentItem>> getComments(dynamic tripId) async {
    try {
      final String cleanTripId = tripId.toString().trim();
      if (cleanTripId.isEmpty) return [];

      final endpoint =
          '${AppUrl.getComments}?trip_id=${Uri.encodeComponent(cleanTripId)}';
      final response = await ApiClient.get(endpoint);

      print('Get Comments Status: ${response.statusCode}');
      print('Get Comments Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];

        final dynamic data = jsonDecode(response.body);
        List rawComments = [];
        List rawReplies = [];

        if (data is List) {
          rawComments = data;
        } else if (data is Map) {
          if (data['data'] is List) {
            rawComments = data['data'];
          } else if (data['comments'] is List) {
            rawComments = data['comments'];
            if (data['replies'] is List) {
              rawReplies = data['replies'];
            }
          } else if (data['data'] is Map) {
            final Map dataMap = data['data'];
            if (dataMap['comments'] is List) {
              rawComments = dataMap['comments'];
            }
            if (dataMap['replies'] is List) {
              rawReplies = dataMap['replies'];
            }
          }
        }

        // Separate root comments and standalone replies (in case flat list was returned)
        final List<CommentItem> rootComments = [];
        final List<CommentReply> extraReplies = [];

        // Parse any replies from dedicated 'replies' list
        for (final r in rawReplies.whereType<Map>()) {
          extraReplies.add(CommentReply.fromJson(Map<String, dynamic>.from(r)));
        }

        for (final item in rawComments.whereType<Map>()) {
          final map = Map<String, dynamic>.from(item);
          final parentId = map['parent_id'] ?? map['parentId'];
          if (parentId != null &&
              parentId.toString().trim().isNotEmpty &&
              parentId.toString().trim() != '0') {
            // This is a reply in a flat list
            extraReplies.add(CommentReply.fromJson(map));
          } else {
            rootComments.add(CommentItem.fromJson(map));
          }
        }

        // Attach extra replies to their corresponding parent comment
        if (extraReplies.isNotEmpty) {
          for (final reply in extraReplies) {
            if (reply.commentId != null) {
              final parent = rootComments.firstWhere(
                (c) => c.id == reply.commentId,
                orElse: () => CommentItem(
                  id: '',
                  name: '',
                  username: '',
                  text: '',
                  time: '',
                ),
              );
              if (parent.id.isNotEmpty &&
                  !parent.replies.any((r) => r.id == reply.id)) {
                parent.addReply(reply);
              }
            }
          }
        }

        return rootComments;
      }
    } catch (e) {
      print('Get Comments Error: $e');
    }
    return [];
  }

  // 2. POST Add Comment (/add_comment)
  Future<({bool success, String message, CommentItem? comment, dynamic data})>
      addComment({
    required dynamic tripId,
    required String comment,
  }) async {
    try {
      final String cleanTripId = tripId.toString().trim();
      final String cleanComment = comment.trim();

      if (cleanTripId.isEmpty || cleanComment.isEmpty) {
        return (
          success: false,
          message: 'Trip ID and comment text are required',
          comment: null,
          data: null,
        );
      }

      final int? intTripId = int.tryParse(cleanTripId);

      final Map<String, dynamic> body = {
        'trip_id': intTripId ?? cleanTripId,
        'tripId': intTripId ?? cleanTripId,
        'comment': cleanComment,
        'comment_text': cleanComment,
        'text': cleanComment,
        'content': cleanComment,
        'message': cleanComment,
        if (CurrentUser.activeUser?.id != null && CurrentUser.activeUser!.id > 0)
          'user_id': CurrentUser.activeUser!.id,
        if (CurrentUser.username.isNotEmpty)
          'username': CurrentUser.username.replaceAll('@', ''),
        if (CurrentUser.name.isNotEmpty)
          'name': CurrentUser.name,
      };

      print('=== [POST] /add_comment ===');
      print('Payload: $body');

      bool isResponseSuccessful(int statusCode, dynamic parsed) {
        if (statusCode != 200 && statusCode != 201) return false;
        if (parsed is Map) {
          final status = parsed['status'];
          final success = parsed['success'];
          if (status == false ||
              status == 'error' ||
              status == 'failed' ||
              status == 400 ||
              status == 422 ||
              status == 500) {
            return false;
          }
          if (success == false || success == 0) {
            return false;
          }
          return true;
        }
        return statusCode == 200 || statusCode == 201;
      }

      // Attempt 1: JSON body
      var response = await ApiClient.post(
        AppUrl.addComment,
        body: body,
        isJson: true,
      );

      print('Add Comment (JSON) Status: ${response.statusCode}');
      print('Add Comment (JSON) Body: ${response.body}');

      dynamic data;
      try {
        if (response.body.isNotEmpty) data = jsonDecode(response.body);
      } catch (_) {}

      bool isSuccess = isResponseSuccessful(response.statusCode, data);

      // Attempt 2: Form-urlencoded if JSON failed
      if (!isSuccess) {
        print('Retrying /add_comment with x-www-form-urlencoded...');
        final formResponse = await ApiClient.post(
          AppUrl.addComment,
          body: body,
          isJson: false,
        );
        print('Add Comment (Form) Status: ${formResponse.statusCode}');
        print('Add Comment (Form) Body: ${formResponse.body}');

        dynamic formData;
        try {
          if (formResponse.body.isNotEmpty) formData = jsonDecode(formResponse.body);
        } catch (_) {}

        if (isResponseSuccessful(formResponse.statusCode, formData)) {
          response = formResponse;
          data = formData;
          isSuccess = true;
        }
      }

      if (response.body.isEmpty) {
        return (
          success: isSuccess,
          message: isSuccess
              ? 'Comment added successfully'
              : 'Server returned status ${response.statusCode}',
          comment: null,
          data: null,
        );
      }

      final String msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['error'] != null)
              ? data['error'].toString()
              : (isSuccess ? 'Comment posted successfully' : 'Failed to post comment');

      CommentItem? parsedComment;
      if (data is Map) {
        final dynamic rawComment = data['comment'] ??
            data['data'] ??
            (data['id'] != null ? data : null);
        if (rawComment is Map) {
          parsedComment =
              CommentItem.fromJson(Map<String, dynamic>.from(rawComment));
        }
      }

      return (
        success: isSuccess,
        message: msg,
        comment: parsedComment,
        data: data,
      );
    } catch (e) {
      print('Add Comment Error: $e');
      return (
        success: false,
        message: 'Network error adding comment: $e',
        comment: null,
        data: null,
      );
    }
  }

  // 3. POST Reply Comment (/reply_comment)
  Future<({bool success, String message, CommentReply? reply, dynamic data})>
      replyComment({
    required dynamic commentId,
    required String reply,
    dynamic tripId,
  }) async {
    try {
      final String cleanCommentId = commentId.toString().trim();
      final String cleanReply = reply.trim();

      if (cleanCommentId.isEmpty || cleanReply.isEmpty) {
        return (
          success: false,
          message: 'Comment ID and reply text are required',
          reply: null,
          data: null,
        );
      }

      final int? intCommentId = int.tryParse(cleanCommentId);
      final int? intTripId =
          tripId != null ? int.tryParse(tripId.toString().trim()) : null;

      // NOTE: Do NOT send 'id': intCommentId! The commentId is the PARENT comment ID,
      // not the new reply's primary key ID.
      final Map<String, dynamic> body = {
        'comment_id': intCommentId ?? cleanCommentId,
        'commentId': intCommentId ?? cleanCommentId,
        'parent_id': intCommentId ?? cleanCommentId,
        if (tripId != null) ...{
          'trip_id': intTripId ?? tripId.toString().trim(),
          'tripId': intTripId ?? tripId.toString().trim(),
        },
        'reply': cleanReply,
        'reply_comment': cleanReply,
        'replay': cleanReply,
        'replay_comment': cleanReply,
        'comment': cleanReply,
        'text': cleanReply,
        'content': cleanReply,
        'message': cleanReply,
        if (CurrentUser.activeUser?.id != null && CurrentUser.activeUser!.id > 0)
          'user_id': CurrentUser.activeUser!.id,
        if (CurrentUser.username.isNotEmpty)
          'username': CurrentUser.username.replaceAll('@', ''),
        if (CurrentUser.name.isNotEmpty)
          'name': CurrentUser.name,
      };

      print('=== [POST] /reply_comment ===');
      print('Payload: $body');

      bool isResponseSuccessful(int statusCode, dynamic parsed) {
        if (statusCode != 200 && statusCode != 201) return false;
        if (parsed is Map) {
          final status = parsed['status'];
          final success = parsed['success'];
          if (status == false ||
              status == 'error' ||
              status == 'failed' ||
              status == 400 ||
              status == 422 ||
              status == 500) {
            return false;
          }
          if (success == false || success == 0) {
            return false;
          }
          return true;
        }
        return statusCode == 200 || statusCode == 201;
      }

      // Attempt 1: JSON body
      var response = await ApiClient.post(
        AppUrl.replyComment,
        body: body,
        isJson: true,
      );

      print('Reply Comment (JSON) Status: ${response.statusCode}');
      print('Reply Comment (JSON) Body: ${response.body}');

      dynamic data;
      try {
        if (response.body.isNotEmpty) data = jsonDecode(response.body);
      } catch (_) {}

      bool isSuccess = isResponseSuccessful(response.statusCode, data);

      // Attempt 2: Form-urlencoded if JSON failed (for vanilla PHP $_POST)
      if (!isSuccess) {
        print('Retrying /reply_comment with x-www-form-urlencoded...');
        final formResponse = await ApiClient.post(
          AppUrl.replyComment,
          body: body,
          isJson: false,
        );
        print('Reply Comment (Form) Status: ${formResponse.statusCode}');
        print('Reply Comment (Form) Body: ${formResponse.body}');

        dynamic formData;
        try {
          if (formResponse.body.isNotEmpty) {
            formData = jsonDecode(formResponse.body);
          }
        } catch (_) {}

        if (isResponseSuccessful(formResponse.statusCode, formData)) {
          response = formResponse;
          data = formData;
          isSuccess = true;
        }
      }

      // Attempt 3: Query parameters if still failing
      if (!isSuccess) {
        final queryParams = <String, String>{
          'comment_id': cleanCommentId,
          'reply': cleanReply,
          'reply_comment': cleanReply,
          if (tripId != null) 'trip_id': tripId.toString().trim(),
        };
        final queryEndpoint = Uri(
          path: AppUrl.replyComment,
          queryParameters: queryParams,
        ).toString();

        print('Retrying /reply_comment with query params: $queryEndpoint');
        final queryResponse = await ApiClient.post(
          queryEndpoint,
          body: body,
          isJson: false,
        );
        print('Reply Comment (Query) Status: ${queryResponse.statusCode}');
        print('Reply Comment (Query) Body: ${queryResponse.body}');

        dynamic qData;
        try {
          if (queryResponse.body.isNotEmpty) {
            qData = jsonDecode(queryResponse.body);
          }
        } catch (_) {}

        if (isResponseSuccessful(queryResponse.statusCode, qData)) {
          response = queryResponse;
          data = qData;
          isSuccess = true;
        }
      }

      if (response.body.isEmpty) {
        return (
          success: isSuccess,
          message: isSuccess
              ? 'Reply added successfully'
              : 'Server returned status ${response.statusCode}',
          reply: null,
          data: null,
        );
      }

      final String msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (data is Map && data['error'] != null)
              ? data['error'].toString()
              : (isSuccess
                  ? 'Reply posted successfully'
                  : 'Failed to post reply (Status: ${response.statusCode})');

      CommentReply? parsedReply;
      if (data is Map) {
        final dynamic rawReply = data['reply'] ??
            data['reply_comment'] ??
            data['data'] ??
            (data['id'] != null ? data : null);
        if (rawReply is Map) {
          parsedReply =
              CommentReply.fromJson(Map<String, dynamic>.from(rawReply));
        }
      }

      return (
        success: isSuccess,
        message: msg,
        reply: parsedReply,
        data: data,
      );
    } catch (e) {
      print('Reply Comment Error: $e');
      return (
        success: false,
        message: 'Network error posting reply: $e',
        reply: null,
        data: null,
      );
    }
  }
}
