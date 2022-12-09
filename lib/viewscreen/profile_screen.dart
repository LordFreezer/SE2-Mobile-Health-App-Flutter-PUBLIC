import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project1/controller/firestore_controller.dart';
import 'package:project1/model/constants.dart';
import 'package:project1/model/user_info.dart';
import 'package:project1/viewscreen/view/view_util.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';

  final User user;
  final UserInformation info;

  const ProfileScreen({required this.info, required this.user, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<ProfileScreen> {
  late _Controller con;
  bool editMode = false;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          editMode
              ? IconButton(onPressed: con.update, icon: const Icon(Icons.check))
              : IconButton(onPressed: con.edit, icon: const Icon(Icons.edit)),
        ],
      ),
      body: Form(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: 200,
                width: 200,
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    widget.info.userPhotoURL == ''
                        ? const CircleAvatar(
                            child: Icon(
                              Icons.person,
                              size: 60,
                            ),
                          )
                        : CircleAvatar(
                            radius: 12.0,
                            backgroundImage:
                                NetworkImage(widget.info.userPhotoURL!),
                            backgroundColor: Colors.transparent,
                            /*radius: 16.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25.0),
                            child: cachedNetworkImage(widget.info.userPhotoURL),*/
                            // ),
                          ),
                    editMode
                        ? Positioned(
                            right: 0,
                            bottom: 0,
                            child: PopupMenuButton(
                              onSelected: con.getProfilePicture,
                              itemBuilder: (context) => [
                                for (var source in PhotoSource.values)
                                  PopupMenuItem(
                                    value: source,
                                    child: Text(source.name),
                                  ),
                              ],
                            ),
                          )
                        : const SizedBox(
                            height: 1.0,
                          ),
                    Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      child: con.progressMessage == null
                          ? const SizedBox(
                              height: 1.0,
                            )
                          : Container(
                              color: Colors.blue[200],
                              child: Text(
                                con.progressMessage!,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Text(
                          'Update account',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Username',
                          ),
                          enabled: editMode,
                          initialValue: widget.info.username,
                          // keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          validator: con.validateUsername,
                          onSaved: con.saveUsername,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Biography',
                          ),
                          enabled: editMode,
                          initialValue: widget.info.biography,
                          autocorrect: false,
                          validator: con.validateBiography,
                          onSaved: con.saveBiography,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Phone',
                          ),
                          enabled: editMode,
                          initialValue: widget.info.phone,
                          autocorrect: false,
                          validator: con.validatePhone,
                          onSaved: con.savePhone,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _ProfileState state;
  String? username;
  late UserInformation tempInfo;
  File? photo;
  String? biography;
  String? phone;
  String? progressMessage;

  _Controller(this.state) {
    // tempMemo.username = state.widget.info.username;
    // tempMemo.userPhotoURL = state.widget.info.userPhotoURL;
    tempInfo = UserInformation.clone(state.widget.info);
  }

  void edit() {
    state.render(() => state.editMode = true);
  }

  void update() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;

    currentState.save();
    //replace username in firestore with new one
    startCircularProgress(state.context);
    //print('=========== ${tempMemo.title} ${tempMemo.memo} ${tempMemo.sharedWith}');
    try {
      Map<String, dynamic> update = {};
      // if(tempInfo.photoFilename==''){
      // if (photo != null) {
      //   Map result = await CloudStorageController.uploadPhotoFile(
      //     photo: photo!,

      //     // filename: tempInfo.photoFilename,
      //     uid: state.widget.user.uid,
      //     listener: (int progress) {
      //       state.render((){
      //         progressMessage = progress == 100 ? null : 'Uploading : $progress %';
      //       });
      //     },
      //   );
      //   // print('tempInfo.photoFilename==========${tempInfo.photoFilename}');
      //   // if(tempInfo.photoFilename==''){
      //   // print('tempInfo.photoFilename==========${tempInfo.photoFilename}');
      //   tempInfo.photoFilename = result[ArgKey.filename];

      //   // }
      //   tempInfo.userPhotoURL = result[ArgKey.downloadURL];
      //   update[DocKeyUserInfo.photoURL.name] = tempInfo.userPhotoURL;
      // }
      // }
      // else if(tempInfo.photoFilename!=''){
      //   if (photo != null) {
      //   Map result = await CloudStorageController.uploadPhotoFile(
      //     photo: photo!,
      //     filename: tempInfo.photoFilename,
      //     uid: state.widget.user.uid,
      //     listener: (int progress) {
      //       state.render((){
      //         progressMessage = progress == 100 ? null : 'Uploading : $progress %';
      //       });
      //     },
      //   );
      //   // print('tempInfo.photoFilename==========${tempInfo.photoFilename}');
      //   // if(tempInfo.photoFilename==''){
      //   // print('tempInfo.photoFilename==========${tempInfo.photoFilename}');
      //   // tempInfo.photoFilename = result[ArgKey.filename];

      //   // }
      //   tempInfo.userPhotoURL = result[ArgKey.downloadURL];
      //   update[DocKeyUserInfo.photoURL.name] = tempInfo.userPhotoURL;
      // }
      // }

      //update Firestore doc
      if (tempInfo.username != state.widget.info.username) {
        update[DocKeyUserInfo.username.name] = tempInfo.username;
      }

      if (tempInfo.biography != state.widget.info.biography) {
        update[DocKeyUserInfo.biography.name] = tempInfo.biography;
      }

      if (tempInfo.phone != state.widget.info.phone) {
        update[DocKeyUserInfo.phone.name] = tempInfo.phone;
      }

      if (update.isNotEmpty) {
        //change has been made
        await FirestoreController.updateUserInfo(
            docID: tempInfo.docID!, update: update);

        //update original
        state.widget.info.copyFrom(tempInfo);
        // print('Info.photoFilename==========${state.widget.info.photoFilename}');

      }

      stopCircularProgress(state.context);
      state.render(() => state.editMode = false);
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('======== Failed to update: $e');
      showSnackBar(
          context: state.context,
          seconds: 20,
          message: '======= Failed to update: $e');
    }
  }

  String? validateUsername(String? value) {
    if (value == null || value.length < 4) {
      return 'Username too short (min 4 chars)';
    } else {
      return null;
    }
  }

  void saveUsername(String? value) {
    tempInfo.username = value;
    username = value;
  }

  String? validateBiography(String? value) {
    if (value == null || value.length > 100) {
      return 'Biography must be 100 characters or less';
    } else {
      return null;
    }
  }

  void saveBiography(String? value) {
    tempInfo.biography = value;
    biography = value;
  }

  String? validatePhone(String? value) {
    if (value == null || value.length < 10) {
      return 'Phone must be 10 characters';
    } else {
      return null;
    }
  }

  void savePhone(String? value) {
    tempInfo.phone = value;
    phone = value;
  }

  void getProfilePicture(PhotoSource source) async {}
  //   try {
  //     var imageSource = source == PhotoSource.camera
  //         ? ImageSource.camera
  //         : ImageSource.gallery;
  //     XFile? image = await ImagePicker().pickImage(source: imageSource);
  //     if (image == null) {
  //       return;
  //     }
  //     state.render(() => photo = File(image.path));
  //   } catch (e) {
  //     if (Constant.devMode) {
  //       print('========Failed to get pic: $e');
  //       showSnackBar(
  //           context: state.context, message: 'Failed to get a picture: $e');
  //     }
  //   }
  // }
}
