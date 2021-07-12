## Flutter_mimc 无脑暴力空安全版本
## 修改了_initMImcInvokeMethod，所以init方法无效，建议使用stringTokenInit初始化，更安全

```yaml
flutter_mimc:
    git:
      url: https://github.com/LLemonGreen/flutter_mimc.git
      ref: master
 ```

## 以下为原项目文档

## Flutter_mimc  v 1.0.2

[English] - [中文](./README_CN.md)

### thank@Xiaomi MIMC team's contribution
   Make IM easy

### features
* Single chat
* Ordinary group chat
* Infinite group chat
* Live stream（Not yet implemented）

## Use needs
 use`flutter_mimc`，It is recommended to read first[Xiaomi instant message cloud official document](https://admin.mimc.chat.xiaomi.net/docs/)，
 This helps you to use `flutter_mimc`。


# Install flutter_mimc
## import

`pubspec.yaml` Add the following dependency to the file:

```yaml
dependencies:
  flutter_mimc: ^${latestVersion}
```


## initialization
Use `flutter_mimc` Before, need to perform initialization：
 ```dart

    import 'package:flutter_mimc/flutter_mimc.dart';

     // The first（String generated by server authentication）recommend
     String tokenString = http.get(); // '{"code":200,"message":"success","data":{}}';
     FlutterMimc flutterMimc = await FlutterMimc.stringTokenInit(
          tokenString,
          debug: true,
     );
     
     // The Second（Write sensitive data on the client）
      FlutterMimc flutterMimc = await FlutterMimc.init(
           debug: true,
           appId: "xxxxxxxx",
           appKey: "xxxxxxxx",
           appSecret: "xxxxxxxx",
           appAccount: "xxxxxxxx"
     );

    /// init push api
    mImcPush = MIMCPush(mImcAppId: "2882303761517669588", mImcAppKey: "5111766983588", mImcAppSecret: "b0L3IOz/9Ob809v8H2FbVg==");


 ```
 
 
## Message body
  flutter_mimc Provide MIMCMessage model class
 ```dart
     MIMCMessage message = MIMCMessage();
     message.bizType = "bizType";      // Message type (developer custom)
     message.toAccount = "";           // Recipient account number (send single chat leave null)
     message.topicId = "";             // Specify the group ID to send (null when sending group chat)
     message.payload = "";             // Developer custom message body
 
     // Custom message body And Base64 encoding
     Map<String, dynamic> payloadMap = {
       "from_account": appAccount,
       "to_account": id,
       "biz_type": "text",
       "version": "0",
       "timestamp": DateTime.now().millisecondsSinceEpoch,
       "read": 0,
       "transfer_account": 0,
       "payload": content
     };

     // base64 Handling custom messages
     message.payload = base64Encode(utf8.encode(json.encode(payloadMap)));
     
     // Send a single chat
     var pid = await flutterMimc.sendMessage(message);
     
     // Send a normal group chat
     var gid = await flutterMimc.sendGroupMsg(message);
     
     // Send unlimited group chat
     var gid = flutterMimc.sendGroupMsg(message, isUnlimitedGroup: true);
 ```

  ## Example documentation tips
Some interface APIs are not shown in the examples below. You need to personally explore the complete demo code of the production test, or directly look at the source code. All the http interfaces in the official document have been packaged in the class library
 
 ## example
```dart

  FlutterMimc flutterMimc;
  final String appAccount = "100";         // My IM account
  String groupID = "21351198708203520";    // Ordinary group Account id
  String maxGroupID = "21360839299170304"; // Unlimited group Account id
  bool isOnline = false;
  List<Map<String, String>> logs = [];
  TextEditingController accountCtr = TextEditingController();
  TextEditingController contentCtr = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // init FlutterMimc
    initFlutterMimc();

  }

  // init
  void initFlutterMimc() async{
    flutterMimc = FlutterMimc.init(
      debug: true,
      appId: "xxxxxxxx",
      appKey: "xxxxxxxx",
      appSecret: "xxxxxxxx",
      appAccount: appAccount
    );
    addLog("init== init success ");
    listener();
  }

  // login
  void login() async{
    await flutterMimc.login();
  }

  // add log
  addLog(String content){
    print(content);
    logs.insert(0,{
      "date": DateTime.now().toIso8601String(),
      "content": content
    });
    setState(() {});
  }

  // logout
  void logout() async{
    await flutterMimc.logout();
  }

  ///  Send a single chat message or Send an online message
  /// [type] 0 Single 1 General group chat， 2 Infinite group, 3 online Single message
  void sendMessage(int type) async {
    String id = accountCtr.value.text;
    String content = contentCtr.value.text;

    if (id == null || id.isEmpty || content == null || content.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("id 或 content参数错误"),
        backgroundColor: Colors.pink,
      ));
      return;
    }

    // message body
    MIMCMessage message = MIMCMessage();
    message.bizType = "bizType";      // Message type (developer-defined)
    // message.toAccount = id;        // Receiver account (send a single chat to leave null)
    // message.topicId                // Specify the group ID to send (leave null when sending a group chat)

    // Custom message body
    Map<String, dynamic> payloadMap = {
      "from_account": appAccount,
      "to_account": id,
      "biz_type": "text",
      "version": "0",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "read": 0,
      "transfer_account": 0,
      "payload": content
    };

    // base64 Custom message body
    message.payload = base64Encode(utf8.encode(json.encode(payloadMap)));

    if (type == 0) {
      /// Single caht
      message.toAccount = id;
      addLog("send to$id: $content");
      var pid = await flutterMimc.sendMessage(message);
      print("pid====$pid");
    } else if (type == 1) {
      /// General group chat
      message.topicId = int.parse(id);
      addLog("send group chat: $content");
      var gid = await flutterMimc.sendGroupMsg(message);
      print("gid====$gid");
    } else if (type == 2) {
      /// Infinite group
      message.topicId = int.parse(id);
      addLog("send Infinite group chat: $content");
      flutterMimc.sendGroupMsg(message, isUnlimitedGroup: true);
    } else if (type == 3) {
      /// online message
      message.toAccount = id;
      addLog("send online message: $content");
      flutterMimc.sendOnlineMessage(message);
    }
    print(json.encode(message.toJson()));
    contentCtr.clear();
  }

  // get token
  void getToken() async{
    String token = await flutterMimc.getToken();
    addLog("Get token successfully：$token");
  }

  // Get current account
  void getAccount() async{
    String account = await flutterMimc.getAccount();
    addLog("Get current account successfully：$account");
  }

  // Get current status
  void getStatus() async{
    bool isOnline =  await flutterMimc.isOnline();
    addLog("Get current status：${isOnline ? 'Online' :'Offline'}");
  }

  // Create a group
  void createGroup() async{
    var res = await flutterMimc.createGroup("ios_group_name", appAccount);
    if (res.code == 200) {
      groupID = res.data['topicInfo']['topicId'];
      addLog("success ${res.toJson()}");
    } else {
      addLog("error :${res.message}");
    }
    accountCtr.text = groupID;
    setState(() {});
  }

  // query group
  void queryGroupInfo() async {
    var res = await flutterMimc.queryGroupInfo(groupID);
    if (res.code == 200) {
      groupID = res.data['topicInfo']['topicId'];
      addLog("success :${res.toJson()}");
    } else {
      addLog("error :${res.message}");
    }
  }

  // Querying Group Information
  void queryGroupsOfAccount() async {
    var res = await flutterMimc.queryGroupsOfAccount();
    if (res.code == 200) {
      addLog("success${res.toJson()}");
    } else {
      addLog("error:${res.message}");
    }
  }

  // Inviting users to join a group
  void joinGroup() async {
    var res =
        await flutterMimc.joinGroup(topicId: groupID, accounts: "101,102,103");
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error :${res.message}");
    }
  }

  // Non-group owner users leave the group
  void quitGroup() async {
    var res = await flutterMimc.quitGroup(groupID);
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error :${res.message}");
    }
  }

  // Group leader kicks members out of the group
  void kickGroup() async {
    var res = await flutterMimc.kickGroup(groupID, "101,102,103");
    if (res.code == 200) {
      addLog("success${res.toJson()}");
    } else {
      addLog("error :${res.message}");
    }
  }

  // Group owner updates group information
  void updateGroup() async {
    var res =
        await flutterMimc.updateGroup(topicId: groupID, topicName: "newName");
    if (res.code == 200) {
      addLog("success :${res.toJson()}");
    } else {
      addLog("error ${res.message}");
    }
  }

  // Group owner destroys group
  void dismissGroup() async {
    var res = await flutterMimc.dismissGroup(groupID);
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error :${res.message}");
    }
  }

  // Pull single chat message records (including multiple versions of the interface)
  void pullP2PHistory() async {
    int thisTimer = DateTime.now().millisecondsSinceEpoch;
    String fromAccount = appAccount;
    String toAccount = "101";
    String utcFromTime = (thisTimer - 85400000).toString();
    String utcToTime = thisTimer.toString();
    var res = await flutterMimc.pullP2PHistory(PullHistoryType.queryOnCount,
        toAccount: toAccount,
        fromAccount: fromAccount,
        utcFromTime: utcFromTime,
        utcToTime: utcToTime);
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error :${res.message}");
    }
  }

  // Pull group chat message records (including multiple versions of the interface)
  void pullP2THistory() async {
    int thisTimer = DateTime.now().millisecondsSinceEpoch;
    String account = appAccount;
    String topicId = groupID;
    String utcFromTime = (thisTimer - 86400000).toString();
    String utcToTime = thisTimer.toString();
    var res = await flutterMimc.pullP2THistory(PullHistoryType.queryOnCount,
        account: account,
        topicId: topicId,
        utcFromTime: utcFromTime,
        utcToTime: utcToTime);
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error :${res.message}");
    }
  }

  // Pull an infinitely large group of message records (including multiple versions of the interface)
  void pullP2UHistory() async {
    int thisTimer = DateTime.now().millisecondsSinceEpoch;
    String account = appAccount;
    String topicId = maxGroupID;
    String utcFromTime = (thisTimer - 86400000).toString();
    String utcToTime = thisTimer.toString();
    var res = await flutterMimc.pullP2UHistory(PullHistoryType.queryOnCount,
        account: account,
        topicId: topicId,
        utcFromTime: utcFromTime,
        utcToTime: utcToTime);
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error :${res.message}");
    }
  }

  // delete Unlimited Group
  void deleteUnlimitedGroup() async {
    var res = await flutterMimc.deleteUnlimitedGroup(topicId: maxGroupID);
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error :${res.message}");
    }
  }

  // create Unlimited Group
  void createUnlimitedGroup() async {
    var res =
        await flutterMimc.createUnlimitedGroup(topicName: "fuck group", extra: "");
    if (res.code == 200) {
      maxGroupID = res.data['topicId'];
      addLog("success ${res.toJson()}");
    } else {
      addLog("error :${res.message}");
    }
  }

  // join Unlimited Group
  void joinUnlimitedGroup() async {
    await flutterMimc.joinUnlimitedGroup("21395272047788032");
    addLog("join Unlimited Group $maxGroupID");
  }

  // quit Unlimited Group
  void quitUnlimitedGroup() async {
    await flutterMimc.quitUnlimitedGroup("21395272047788032");
    addLog("quit Unlimited Group $maxGroupID");
  }

  // dismiss Unlimited Group
  void dismissUnlimitedGroup() async {
    await flutterMimc.dismissUnlimitedGroup(maxGroupID);
    addLog("dismiss Unlimited Group $maxGroupID");
  }

  // query Unlimited Group Members
  void queryUnlimitedGroupMembers() async {
    var res = await flutterMimc.queryUnlimitedGroupMembers(topicId: maxGroupID);
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error :${res.message}");
    }
  }

  // query Unlimited Groups
  void queryUnlimitedGroups() async {
    var res = await flutterMimc.queryUnlimitedGroups();
    if (res.code == 200) {
      addLog("success${res.toJson()}");
    } else {
      addLog("error:${res.message}");
    }
  }

  // query Unlimited Group Online Users
  void queryUnlimitedGroupOnlineUsers() async {
    var res = await flutterMimc.queryUnlimitedGroupOnlineUsers(maxGroupID);
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error: ${res.message}");
    }
  }

  // query Unlimited GroupInfo
  void queryUnlimitedGroupInfo() async {
    var res = await flutterMimc.queryUnlimitedGroupInfo(maxGroupID);
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error: ${res.message}");
    }
  }

  // update Unlimited Group
  void updateUnlimitedGroup() async {
    var res = await flutterMimc.updateUnlimitedGroup(
        topicId: maxGroupID, topicName: "新大群名称1");
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error: ${res.message}");
    }
  }

  // get Contact
  void getContact() async {
    var res = await flutterMimc.getContact(isV2: true);
   if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error:${res.message}");
    }

  // set BlackList
  void setBlackList() async {
    var res = await flutterMimc.setBlackList("200");
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error: ${res.message}");
    }
  }

  // delete BlackList
  void deleteBlackList() async {
    var res = await flutterMimc.deleteBlackList("200");
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error: ${res.message}");
    }
  }

  // has BlackList
  void hasBlackList() async {
    var res = await flutterMimc.hasBlackList("200");
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error: ${res.message}");
    }
  }

  // set GroupBlackList
  void setGroupBlackList() async {
    var res = await flutterMimc.setGroupBlackList(
        blackTopicId: "21351198708203520", blackAccount: "102");
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error: ${res.message}");
    }
  }

  // delete GroupBlackList
  void deleteGroupBlackList() async {
    var res = await flutterMimc.deleteGroupBlackList(
        blackTopicId: "21351198708203520", blackAccount: "102");
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error: ${res.message}");
    }
  }

  // has GroupBlackList
  void hasGroupBlackList() async {
    var res = await flutterMimc.hasGroupBlackList(
        blackTopicId: "21351198708203520", blackAccount: "102");
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error: ${res.message}");
    }
  }

  // push P2PMessage
  void pushP2PMessage() async{
    var res = await mImcPush.pushP2PMessage(
      fromAccount: "100",
      toAccount: "101",
      msg: "data",
      fromResource: "keith");
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error:${res.message}");
    }
  }

  // push P2PMoreMessage
  void pushP2PMoreMessage() async{
    var res = await mImcPush.pushP2PMoreMessage(
      fromAccount: "100",
      toAccounts: ["101","102"],
      msg: "data",
      fromResource: "keith"
    );
    if (res.code == 200) {
      addLog("success ${res.toJson()}");
    } else {
      addLog("error: ${res.message}");
    }
  }

  // push P2TMessage
  void pushP2TMessage() async{
    var res = await mImcPush.pushP2TMessage(
        fromAccount: "100",
        topicId: "21351235479666688",
        msg: "data",
        fromResource: "keith"
    );
    if (res.code == 200) {
      addLog("success${res.toJson()}");
    } else {
      addLog("error:${res.message}");
    }
  }

  // push P2TMoreMessage
  void pushP2TMoreMessage() async{
    var res = await mImcPush.pushP2TMoreMessage(
        fromAccount: "100",
        topicIds: ["21351235479666688", "21351318392668160"],
        msg: "data",
        fromResource: "keith"
    );
    if (res.code == 200) {
      addLog("success${res.toJson()}");
    } else {
      addLog("error:${res.message}");
    }
  }

  // pushP2UMessage
  void pushP2UMessage() async{
    var res = await mImcPush.pushP2UMessage(
        fromAccount: "100",
        topicId: "21361055926583296",
        message: "data",
        fromResource: "keith"
    );
    if (res.code == 200) {
      addLog("success${res.toJson()}");
    } else {
      addLog("error:${res.message}");
    }
  }

  // pushP2UMoreMessage
  void pushP2UMoreMessage() async{
    var res = await mImcPush.pushP2UMoreMessage(
        fromAccount: "100",
        topicId: "21361055926583296",
        messages: ["data","data1"],
        fromResource: "keith"
    );
    if (res.code == 200) {
      addLog("success${res.toJson()}");
    } else {
      addLog("error:${res.message}");
    }
  }

  // push MultiTopic Message
  void pushMultiTopicMessage() async{
    var res = await mImcPush.pushMultiTopicMessage(
        fromAccount: "100",
        topicIds: ["21361055926583296"],
        message: "data",
        fromResource: "keith"
    );
    if (res.code == 200) {
      addLog("success${res.toJson()}");
    } else {
      addLog("error:${res.message}");
    }
  }

  // listener
  void listener() {
    // listener onlone status
    flutterMimc.addEventListenerStatusChanged().listen((status) {
      isOnline = status;
      if (status) {
        addLog("$appAccount====status====online");
      } else {
        addLog("$appAccount====status====offlone");
      }
      setState(() {});
    }).onError((err) {
      addLog(err);
    });

    // receive Single chat
    flutterMimc.addEventListenerHandleMessage().listen((MIMCMessage message) {
      String content = utf8.decode(base64.decode(message.payload));
      addLog("receive${message.fromAccount} message: $content");
      setState(() {});
    }).onError((err) {
      addLog(err);
    });

    // receive group chat
    flutterMimc
        .addEventListenerHandleGroupMessage()
        .listen((MIMCMessage message) {
      String content = utf8.decode(base64.decode(message.payload));
      addLog("receive group${message.topicId}message: $content");
      setState(() {});
    }).onError((err) {
      addLog(err);
    });

    // Send message callback
    flutterMimc.addEventListenerServerAck().listen((MimcServeraAck ack) {
      addLog("Send message callback==${ack.toJson()}");
    }).onError((err) {
      addLog(err);
    });

    // Send online message callback
    flutterMimc.addEventListenerOnlineMessageAck().listen((MimcServeraAck ack) {
      addLog("Send online message callback==${ack.toJson()}");
    }).onError((err) {
      addLog(err);
    });

    // Send single chat timeout
    flutterMimc
        .addEventListenerSendMessageTimeout()
        .listen((MIMCMessage message) {
      addLog("Send single chat timeout==${message.toJson()}");
    }).onError((err) {
      addLog(err);
    });

    // Send group chat timeout
    flutterMimc
        .addEventListenerSendGroupMessageTimeout()
        .listen((MIMCMessage message) {
      addLog("Send group chat timeout==${message.toJson()}");
    }).onError((err) {
      addLog(err);
    });

    // Send unlimited group chat timeout
    flutterMimc
        .addEventListenerSendUnlimitedGroupMessageTimeout()
        .listen((MIMCMessage message) {
      addLog("Send unlimited group chat timeout==${message.toJson()}");
    }).onError((err) {
      addLog(err);
    });

    // Create large group callbacks
    flutterMimc
        .addEventListenerHandleCreateUnlimitedGroup()
        .listen((Map<dynamic, dynamic> res) {
      addLog("Create large group callbacks==$res");
      maxGroupID = (res['topicId'] as int).toString();
    }).onError((err) {
      addLog(err);
    });

    // Join large group callback
    flutterMimc
        .addEventListenerHandleJoinUnlimitedGroup()
        .listen((Map<dynamic, dynamic> res) {
      addLog("Join large group callback==$res");
    }).onError((err) {
      addLog(err);
    });

    // Exit large group callback
    flutterMimc
        .addEventListenerHandleQuitUnlimitedGroup()
        .listen((Map<dynamic, dynamic> res) {
      addLog("Exit large group callback==$res");
    }).onError((err) {
      addLog(err);
    });

    // Disbanding large groups of callbacks
    flutterMimc
        .addEventListenerHandleDismissUnlimitedGroup()
        .listen((Map<dynamic, dynamic> res) {
      addLog("Disbanding large groups of callbacks==$res");
    }).onError((err) {
      addLog(err);
    });

    // Receive online message
    flutterMimc.addEventListenerOnlineMessage().listen((msg) {
      addLog("message==${msg.toJson()}");
    }).onError((err) {
      addLog(err);
    });

    // Receive and send online message callback
    flutterMimc.addEventListenerOnlineMessageAck().listen((ack) {
      addLog("Receive and send online message callback==${ack.toJson()}");
    }).onError((err) {
      addLog(err);
    });




 ```


## LICENSE


    Copyright 2019 keith

    Licensed to the Apache Software Foundation (ASF) under one or more contributor
    license agreements.  See the NOTICE file distributed with this work for
    additional information regarding copyright ownership.  The ASF licenses this
    file to you under the Apache License, Version 2.0 (the "License"); you may not
    use this file except in compliance with the License.  You may obtain a copy of
    the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
    License for the specific language governing permissions and limitations under
    the License.
