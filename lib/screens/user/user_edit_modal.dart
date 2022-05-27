// ignore_for_file: unused_import, must_be_immutable, avoid_web_libraries_in_flutter, non_constant_identifier_names

import 'dart:convert';
import 'dart:html';

import 'package:cross_file_image/cross_file_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gapura/constants.dart';
import 'package:gapura/controllers/categories_controller.dart';
import 'package:gapura/responsive.dart';
import 'package:flutter/material.dart';
import 'package:gapura/screens/template/background_image_upload.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gapura/screens/components/my_fields.dart';
import 'package:gapura/screens/components/header.dart';
import 'package:gapura/screens/components/recent_files.dart';
import 'package:gapura/screens/components/storage_details.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserEditModal extends StatefulWidget {
  UserEditModal({this.user_id});
  String user_id;
  @override
  State<UserEditModal> createState() => _UserEditModal();
}

class _UserEditModal extends State<UserEditModal> {
  TextEditingController fullnameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool contentLoad = true;

  getData() async {
    String url = dotenv.env['BASE_URL'] + "api/v1/user/show/" + widget.user_id;
    var uri = Uri.parse(url);

    var response = await http.get(uri);
    if (jsonDecode(response.body)["error"] == false) {
      setState(() {
        fullnameController.text = jsonDecode(response.body)["data"]["fullname"];
        usernameController.text = jsonDecode(response.body)["data"]["username"];
        emailController.text = jsonDecode(response.body)["data"]["email"];
        phoneController.text = jsonDecode(response.body)["data"]["phone"];
        contentLoad = false;
      });
      notif("Updated");
    } else {
      setState(() {});
      notif("Error");
    }
  }

  patchData() async {
    String url = dotenv.env['BASE_URL'] + "api/v1/user/update";
    var uri = Uri.parse(url);

    var response = await http.patch(
      uri,
      body: {
        "user_id": widget.user_id,
        "fullname": fullnameController.text,
        "username": usernameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "phone": phoneController.text,
      },
    );

    if (jsonDecode(response.body)["error"] == false) {
      notif("Behasil Update");
      setState(() {
        Navigator.pop(context);
      });
    } else {
      notif("Gagal Update");
      setState(() {});
    }
  }

  deleteData() async {
    String url =
        dotenv.env['BASE_URL'] + "api/v1/user/delete/" + widget.user_id;
    var uri = Uri.parse(url);

    var response = await http.delete(uri);

    if (jsonDecode(response.body)["error"] == false) {
      notif("Deleted");
      Navigator.pop(context);
    } else {
      setState(() {});
      notif("Error");
    }
  }

  notif(String msg) async {
    Fluttertoast.showToast(
        msg: msg, webBgColor: "linear-gradient(to right, #F15A24, #F15A24)");
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: (contentLoad)
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: (Responsive.isDesktop(context))
                        ? MediaQuery.of(context).size.width / 5
                        : 20,
                    vertical: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Ubah Pengguna",
                          style: TextStyle(
                              color: secondaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultPadding),
                    fullnameBody(context),
                    SizedBox(height: defaultPadding),
                    usernameBody(context),
                    SizedBox(height: defaultPadding),
                    emailBody(context),
                    SizedBox(height: defaultPadding),
                    passwordBody(context),
                    SizedBox(height: defaultPadding),
                    phoneBody(context),
                    SizedBox(height: defaultPadding),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          ElevatedButton(
                            style: TextButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: defaultPadding * 1.5,
                                vertical: defaultPadding,
                              ),
                            ),
                            child: Text("Batal"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(width: 5),
                          ElevatedButton(
                            style: TextButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: defaultPadding * 1.5,
                                vertical: defaultPadding,
                              ),
                            ),
                            child: Text("Hapus"),
                            onPressed: () {
                              deleteData();
                            },
                          ),
                          SizedBox(width: 5),
                          ElevatedButton(
                            style: TextButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: defaultPadding * 1.5,
                                vertical: defaultPadding,
                              ),
                            ),
                            child: Text("Simpan"),
                            onPressed: () {
                              patchData();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  fullnameBody(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nama Lengkap",
            style: TextStyle(color: secondaryColor, fontSize: 16),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: fullnameController,
              style: TextStyle(color: secondaryColor),
              decoration: InputDecoration(
                fillColor: secondaryColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  usernameBody(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nama Pengguna",
            style: TextStyle(color: secondaryColor, fontSize: 16),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: usernameController,
              style: TextStyle(color: secondaryColor),
              decoration: InputDecoration(
                fillColor: secondaryColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  emailBody(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "E-Mail",
            style: TextStyle(color: secondaryColor, fontSize: 16),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: emailController,
              style: TextStyle(color: secondaryColor),
              decoration: InputDecoration(
                fillColor: secondaryColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  passwordBody(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Password",
            style: TextStyle(color: secondaryColor, fontSize: 16),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: passwordController,
              style: TextStyle(color: secondaryColor),
              decoration: InputDecoration(
                fillColor: secondaryColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  phoneBody(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "No. Telepon",
            style: TextStyle(color: secondaryColor, fontSize: 16),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: phoneController,
              style: TextStyle(color: secondaryColor),
              decoration: InputDecoration(
                fillColor: secondaryColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}