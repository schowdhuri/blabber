import 'dart:convert';
import 'dart:typed_data';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

enum MessageType {
  ConnectRequest,
  ConnectSuccess,
  ConnectFail,
  MessageReceived,
  SendRequest,
  SendSuccess,
  UploadServiceDiscovery,
  UploadServiceDiscoverySuccess,
  UploadServiceDiscoveryFailure,
  GetUploadSlot,
  GetUploadSlotSuccess,
  GetUploadSlotFailure,
  UploadFile,
  UploadFileSuccess,
  UploadFileFailure,
  SendFail,
  SendFile,
  SendFileSuccess,
  SendFileFailure,
  ShareSendPort,
  GetVCard,
  GetVCardSuccess,
  GetVCardFailure,
  SaveVCard,
  SaveVCardSuccess,
  SaveVCardFailure,
  VCardReceived,
  VCardError,
  SavePushToken,
}

class ConnectPayload {
  final String host;
  final int port;
  final String username;
  final String password;
  final String key;

  ConnectPayload({
    this.host,
    this.port,
    this.username,
    this.password,
    this.key,
  });
}

class ConnectResponsePayload {
  final String key;
  final ResponseStatus status;

  ConnectResponsePayload({
    this.key,
    this.status,
  });
}

class ChatMessagePayload {
  final String key;
  final String fromUsername;
  final String toUsername;
  final String message;
  ChatMessagePayload({
    this.fromUsername,
    this.toUsername,
    this.message,
    this.key,
  });
}

class UploadServiceDiscoveryRequest {
  final String key;
  final String fromUsername;
  UploadServiceDiscoveryRequest({this.key, this.fromUsername});
}

class UploadServiceDiscoveryResponse {
  final String key;
  final int maxFileSize;
  UploadServiceDiscoveryResponse({this.key, this.maxFileSize});
}

class UploadFileRequest {
  final String key;
  final String filePath;
  final int size;
  final String url;
  UploadFileRequest({this.key, this.filePath, this.size, this.url});
}

class UploadFileResponse {
  final String key;
  final String url;
  UploadFileResponse({this.key, this.url});
}

class FileMessagePayload extends ChatMessagePayload {
  final String filename;
  final String filetype;

  FileMessagePayload({
    this.filename,
    this.filetype,
    String fromUsername,
    String toUsername,
    String message,
    String key,
  }) : super(
          fromUsername: fromUsername,
          toUsername: toUsername,
          message: message,
          key: key,
        );
}

class UploadSlotRequest {
  final String key;
  final String filename;
  final int size;
  final String contentType;
  final String fromUsername;

  UploadSlotRequest({
    this.key,
    this.filename,
    this.size,
    this.contentType,
    this.fromUsername,
  });
}

class UploadSlotResponse {
  final String key;
  final String getUrl;
  final String putUrl;

  UploadSlotResponse({
    this.key,
    this.getUrl,
    this.putUrl,
  });
}

class GetVCardPayload {
  final String fromUsername;
  final String toUsername;
  final String id;
  GetVCardPayload({this.fromUsername, this.toUsername, this.id});
}

class SaveVCardPayload {
  final String id;
  final Uint8List imageData;
  final String jabberId;
  final String fullName;

  SaveVCardPayload({
    this.id,
    this.imageData,
    this.jabberId,
    this.fullName,
  });

  String get b64ImageData => base64Encode(imageData);
}

class VCardResponsePayload {
  final xmpp.VCard vCard;
  final String key;

  VCardResponsePayload({this.vCard, this.key});
}

class SavePushTokenPayload {
  final String pushToken;
  final String id;
  SavePushTokenPayload({this.pushToken, this.id});
}

class IsolateMessage {
  final MessageType type;
  final dynamic payload;

  IsolateMessage({this.type, this.payload});
}

class ClientResponse {
  final ResponseStatus status;
  final dynamic payload;
  ClientResponse({this.status, this.payload});
}

enum ResponseStatus { Pending, Success, Fail }
