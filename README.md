## Flutter_mimc  v 0.0.3+3

[English][中文](./README_CN.md)

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

     FlutterMimc flutterMimc = FlutterMimc.init(
          debug: true,
          appId: "xxxxxxxx",
          appKey: "xxxxxxxx",
          appSecret: "xxxxxxxx",
          appAccount: appAccount
    );
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

  // send message
  void sendMessage(int type){
    String id = accountCtr.value.text;
    String content = contentCtr.value.text;

    if(id == null || id.isEmpty || content == null || content.isEmpty){
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("id or content Parameter error"), backgroundColor: Colors.pink,));
      return;
    }

    MimcChatMessage messageRes = MimcChatMessage();
    MimcMessageBena messageBena = MimcMessageBena();
    messageRes.timestamp = DateTime.now().millisecondsSinceEpoch;
    messageRes.bizType = "bizType";
    messageRes.fromAccount = appAccount;
    messageBena.timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    messageBena.payload = base64Encode(utf8.encode(content));
    messageBena.version  = 0;
    messageBena.msgId  = "msgId";
    messageRes.message = messageBena;
    if(type == 0){
      messageRes.toAccount = id;
      addLog("send to$id: $content");
      flutterMimc.sendMessage(messageRes);
    }else if(type == 1){
      messageRes.topicId = int.parse(id);
      addLog("Send a normal group message: $content");
      flutterMimc.sendGroupMsg(messageRes);
    }else{
      messageRes.topicId = int.parse(id);
      addLog("Send unlimited group messages: $content");
      flutterMimc.sendGroupMsg(messageRes, isUnlimitedGroup: true);
    }
    print(messageRes.toJson());
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
    if(!res['success']){
      addLog("Create group failed:${res['message']}" );
    }else{
      groupID = res['data']['topicInfo']['topicId'];
      addLog("Create group success：${res['data']}");
    }
    accountCtr.text = groupID;
    setState(() { });
  }

  // Query group
  void queryGroupInfo() async{
    var res = await flutterMimc.queryGroupInfo(groupID);
    if(!res['success']){
      addLog("Query group failed:${res['message']}" );
    }else{
      addLog("Query group success：${res['data']}");
    }
  }

  // Query group information
  void queryGroupsOfAccount() async{
    var res = await flutterMimc.queryGroupsOfAccount();
    if(!res['success']){
      addLog("Querying group info failed:${res['message']}" );
    }else{
      addLog("Querying group info success：${res['data']}");
    }
  }

  // Invite users to join the group
  void joinGroup() async{
    var res = await flutterMimc.joinGroup(groupID, "101,102,103");
    if(!res['success']){
      addLog("Invite users to join group failed:${res['message']}" );
    }else{
      addLog("Invite users to join group success：${res['data']}");
    }
  }

  // Non-group master user quit group
  void quitGroup() async{
    var res = await flutterMimc.quitGroup(groupID);
    if(!res['success']){
      addLog("Non-group master user quit group failed:${res['message']}" );
    }else{
      addLog("Non-group master user quit group success：${res['data']}");
    }
  }

  // Kicking members out of the group
  void kickGroup() async{
    var res = await flutterMimc.kickGroup(groupID, "101,102,103");
    if(!res['success']){
      addLog("Kicking members out of the group failed:${res['message']}");
    }else{
      addLog("Kicking members out of the group success：${res['data']}");
    }
  }

  // Group owner update group information
  void updateGroup() async{
    var res = await flutterMimc.updateGroup(groupID, newOwnerAccount: "", newGroupName: "New group name" + groupID, newGroupBulletin: "New announcement");
    if(!res['success']){
      addLog("Group owner update group information failed:${res['message']}" );
    }else{
      addLog("Group owner update group information success：${res['data']}");
    }
  }

  // Group destroyer
  void dismissGroup() async{
    var res = await flutterMimc.dismissGroup(groupID);
    if(!res['success']){
      addLog("Group destroyer failed:${res['message']}" );
    }else{
      addLog("Group destroyer success：${res['data']}");
    }
  }

  // Pull single chat message record
  void pullP2PHistory() async{
    int thisTimer = DateTime.now().millisecondsSinceEpoch;
    String fromAccount = appAccount;
    String toAccount = "101";
    String utcFromTime = (thisTimer - 86400000).toString();
    String utcToTime = thisTimer.toString();
    var res = await flutterMimc.pullP2PHistory(
      toAccount: toAccount,
      fromAccount: fromAccount,
      utcFromTime: utcFromTime,
      utcToTime: utcToTime
    );
    if(!res['success']){
      addLog("Pull single chat message record failed:${res['message']}" );
    }else{
      addLog("Pull single chat message record success：${res['data']}");
    }
  }

  // Pull group chat message record
  void pullP2THistory() async{
    int thisTimer = DateTime.now().millisecondsSinceEpoch;
    String account = appAccount;
    String topicId = groupID;
    String utcFromTime = (thisTimer - 86400000).toString();
    String utcToTime = thisTimer.toString();
    var res = await flutterMimc.pullP2THistory(
      account: account,
      topicId: topicId,
      utcFromTime: utcFromTime,
      utcToTime: utcToTime
    );
    if(!res['success']){
      addLog("Pull group chat message record failed:${res['message']}" );
    }else{
      addLog("Pull group chat message record success：${res['data']}");
    }
  }

  // create unlimited group
  void createUnlimitedGroup() async{
    await flutterMimc.createUnlimitedGroup("unlimitedGroup");
    addLog("create unlimited group" );
  }

  // join unlimited group
  void joinUnlimitedGroup() async{
    await flutterMimc.joinUnlimitedGroup("21395272047788032");
    addLog("join unlimited group$maxGroupID" );
  }

  // quit unlimited group
  void quitUnlimitedGroup() async{
    await flutterMimc.quitUnlimitedGroup("21395272047788032");
    addLog("quit unlimited group$maxGroupID" );
  }

  // dismiss unlimited group
  void dismissUnlimitedGroup() async{
    await flutterMimc.dismissUnlimitedGroup(maxGroupID);
    addLog("dismiss unlimited group$maxGroupID" );
  }

  // Query unlimited group members
  void queryUnlimitedGroupMembers() async{
    var res = await flutterMimc.queryUnlimitedGroupMembers(maxGroupID);
    addLog("Query unlimited group members: $res" );
  }

  // unlimited group I am in
  void queryUnlimitedGroups() async{
    var res = await flutterMimc.queryUnlimitedGroups();
    addLog("unlimited group I am in: $res" );
  }

  // Query the number of unlimited group of online users
  void queryUnlimitedGroupOnlineUsers() async{
    var res =  await flutterMimc.queryUnlimitedGroupOnlineUsers(maxGroupID);
    addLog("online count data：$res" );
  }

      // unlimited group Basic Information
  void queryUnlimitedGroupInfo() async{
    var res =  await flutterMimc.queryUnlimitedGroupInfo(maxGroupID);
    addLog("unlimited group Basic Information：$res" );
  }

  // update unlimited group Basic Information
  void updateUnlimitedGroup() async{
    var res =  await flutterMimc.updateUnlimitedGroup(maxGroupID, newGroupName: "newGroupName");
    addLog("update unlimited group Basic Information：$res" );
  }

  // =========add Event Listener==============

    // Listener login status
    flutterMimc.addEventListenerStatusChanged().listen((status){
      isOnline = status;
      if(status){
        addLog("$appAccount====status changed====Online");
      }else{
        addLog("$appAccount====status changed====Offline");
      }
      setState(() {});
    }).onError((err){
      addLog(err);
    });

    // Receive a single chat
    flutterMimc.addEventListenerHandleMessage().listen((MimcChatMessage resource){
      String content =utf8.decode(base64.decode(resource.message.payload));
      addLog("get${resource.fromAccount}message: $content");
      setState(() {});
    }).onError((err){
      addLog(err);
    });

    // Receiving group chat
    flutterMimc.addEventListenerHandleGroupMessage().listen((MimcChatMessage resource){
      String content =utf8.decode(base64.decode(resource.message.payload));
      addLog("get group${resource.topicId}message: $content");
      setState(() {});
    }).onError((err){
      addLog(err);
    });

    // Send message callback
    flutterMimc.addEventListenerServerAck().listen((MimcServeraAck ack){
      addLog("Send message callback==${ack.toJson()}");
    }).onError((err){
      addLog(err);
    });

    // Send a single chat timeout
    flutterMimc.addEventListenerSendMessageTimeout().listen((MimcChatMessage resource){
      addLog("Send a single chat timeout==${resource.toJson()}");
    }).onError((err){
      addLog(err);
    });

    // Send group chat timeout
    flutterMimc.addEventListenerSendGroupMessageTimeout().listen((MimcChatMessage resource){
      addLog("Send group chat timeout==${resource.toJson()}");
    }).onError((err){
      addLog(err);
    });

    // Send unlimited group chat timeout
    flutterMimc.addEventListenerSendUnlimitedGroupMessageTimeout().listen((MimcChatMessage resource){
      addLog("Send unlimited group chat timeout==${resource.toJson()}");
    }).onError((err){
      addLog(err);
    });

    // Create a unlimited group callback
    flutterMimc.addEventListenerHandleCreateUnlimitedGroup().listen((Map<dynamic, dynamic> res){
      addLog("Create a unlimited group callback==${res}");
      maxGroupID = (res['topicId'] as int).toString();
    }).onError((err){
      addLog(err);
    });

    // join unlimited group callback
    flutterMimc.addEventListenerHandleJoinUnlimitedGroup().listen((Map<dynamic, dynamic> res){
      addLog("join unlimited group callback==${res}");
    }).onError((err){
      addLog(err);
    });

    // quit unlimited group callback
    flutterMimc.addEventListenerHandleQuitUnlimitedGroup().listen((Map<dynamic, dynamic> res){
      addLog("quit unlimited group callback==${res}");
    }).onError((err){
      addLog(err);
    });

    // Dismiss unlimited group callback
    flutterMimc.addEventListenerHandleDismissUnlimitedGroup().listen((Map<dynamic, dynamic> res){
      addLog("Dismiss unlimited group callback==${res}");
    }).onError((err){
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
