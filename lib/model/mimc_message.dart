class MIMCMessage {
  int? sequence;
  String? toAccount;
  String? bizType;
  int timestamp = 0;
  String? fromAccount;
  int? topicId;
  String? payload;
  bool? isStore;
  bool? isConversation;
  MIMCMessage(
      {this.toAccount,
      this.bizType,
      this.sequence,
      this.timestamp = 0,
      this.fromAccount,
      this.topicId,
      this.isStore = true,
      this.payload,
      this.isConversation = true});

  MIMCMessage.fromJson(Map<dynamic, dynamic> json) {
    this.sequence = json['sequence'];
    this.toAccount = json['toAccount'];
    this.bizType = json['bizType'];
    this.fromAccount = json['fromAccount'];
    this.topicId = json['topicId'];
    this.timestamp = json['timestamp'] == null ? 0 : json['timestamp'];
    this.isStore = json['isStore'];
    this.payload = json['payload'];
    this.isConversation = json['isConversation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sequence'] = this.sequence;
    data['toAccount'] = this.toAccount;
    data['bizType'] = this.bizType;
    data['fromAccount'] = this.fromAccount;
    data['topicId'] = this.topicId;
    data['timestamp'] = this.timestamp;
    data['isStore'] = this.isStore;
    data['payload'] = this.payload;
    data['isConversation'] = this.isConversation;
    return data;
  }
}
