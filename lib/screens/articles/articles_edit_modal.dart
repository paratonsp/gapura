// ignore_for_file: unused_import, must_be_immutable, avoid_web_libraries_in_flutter, non_constant_identifier_names
import 'dart:convert';
import 'dart:html';

import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gapura/controllers/categories_controller.dart';
import 'package:gapura/responsive.dart';
import 'package:flutter/material.dart';
import 'package:gapura/screens/articles/articles_label_modal.dart';
import 'package:gapura/screens/articles/articles_sublabel_modal.dart';
import 'package:gapura/screens/template/background_image_upload.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:gapura/constants.dart';

import 'package:gapura/screens/components/my_fields.dart';
import 'package:gapura/screens/components/header.dart';
import 'package:gapura/screens/components/recent_files.dart';
import 'package:gapura/screens/components/storage_details.dart';

class ArticlesEditModal extends StatefulWidget {
  ArticlesEditModal({this.article_id});
  String article_id;
  @override
  State<ArticlesEditModal> createState() => _ArticlesEditModal();
}

class _ArticlesEditModal extends State<ArticlesEditModal> {
  String labelString = "";
  String sublabelString = "";

  String categoriesPicked;
  List listCategories;

  TextEditingController titleController = TextEditingController();
  TextEditingController subtitleController = TextEditingController();
  TextEditingController tableuController = TextEditingController();
  TextEditingController tableuHeightController =
      TextEditingController(text: "400");
  TextEditingController iframeController = TextEditingController();
  HtmlEditorController descriptionController = HtmlEditorController();

  List<int> imageBytes;
  String imageString;
  String imageUrl;

  String descriptionText = "";

  bool contentLoad = true;

  getData() async {
    String url =
        dotenv.env['BASE_URL'] + "api/v1/article/show/" + widget.article_id;
    var uri = Uri.parse(url);

    var response = await http.get(uri);
    if (jsonDecode(response.body)["error"] == false) {
      setState(() {
        categoriesPicked =
            jsonDecode(response.body)["data"]["categories_id"].toString();
        titleController.text = jsonDecode(response.body)["data"]["title"];
        labelString = jsonDecode(response.body)["data"]["label"];
        sublabelString = jsonDecode(response.body)["data"]["sublabel"];
        descriptionText = jsonDecode(response.body)["data"]["description"];
        imageUrl = "https://" + jsonDecode(response.body)["data"]["imagelink"];
        contentLoad = false;
      });
      notif("Updated");
    } else {
      setState(() {});
      notif("Error");
    }
  }

  getCategories() async {
    String url = dotenv.env['BASE_URL'] + "api/v1/categories";
    var uri = Uri.parse(url);

    var response = await http.get(uri);
    var decodeJson = json.decode(response.body)["data"];
    if (jsonDecode(response.body)["error"] == false) {
      setState(() {
        listCategories = decodeJson;
      });
      contentLoad = false;
      notif("Updated");
    } else {
      setState(() {});
      notif("Error");
    }
  }

  pickImage() async {
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.multiple = false;
    uploadInput.draggable = false;
    uploadInput.accept = '.png,.jpg,.jpeg';
    uploadInput.size = 2000000;
    uploadInput.click();
    document.body.append(uploadInput);
    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      final file = files[0];
      final reader = FileReader();
      reader.onLoadEnd.listen((value) {
        var _bytesData =
            Base64Decoder().convert(reader.result.toString().split(",").last);
        setState(() {
          imageBytes = _bytesData;
          imageString = reader.result;
        });
      });
      reader.readAsDataUrl(file);
    });
    uploadInput.remove();
  }

  patchData() async {
    var descriptionText = await descriptionController.getText();
    String url = dotenv.env['BASE_URL'] + "api/v1/article/update";
    var uri = Uri.parse(url);

    var response = await http.patch(
      uri,
      body: (imageString == null)
          ? {
              "article_id": widget.article_id,
              "categories_id": categoriesPicked,
              "title": titleController.text,
              "label": labelString,
              "sublabel": sublabelString,
              "description": descriptionText,
            }
          : {
              "article_id": widget.article_id,
              "categories_id": categoriesPicked,
              "title": titleController.text,
              "label": labelString,
              "sublabel": sublabelString,
              "description": descriptionText,
              "image": imageString,
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
        dotenv.env['BASE_URL'] + "api/v1/article/delete/" + widget.article_id;
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
    getCategories();
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
                          "Ubah Artikel",
                          style: TextStyle(
                              color: fontColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (Responsive.isDesktop(context))
                            ? imageBody(context)
                            : SizedBox(),
                        (Responsive.isDesktop(context))
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: TextButton.styleFrom(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // <-- Radius
                                      ),
                                      backgroundColor: primaryColor,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: defaultPadding * 1.5,
                                        vertical: defaultPadding,
                                      ),
                                    ),
                                    child: Text("Label Gambar"),
                                    onPressed: () {
                                      navigateLabelModal(context, labelString);
                                    },
                                  ),
                                  SizedBox(height: 5),
                                  ElevatedButton(
                                    style: TextButton.styleFrom(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // <-- Radius
                                      ),
                                      backgroundColor: primaryColor,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: defaultPadding * 1.5,
                                        vertical: defaultPadding,
                                      ),
                                    ),
                                    child: Text("Sub Label Gambar"),
                                    onPressed: () {
                                      navigateSubLabelModal(
                                          context, sublabelString);
                                    },
                                  ),
                                ],
                              )
                            : SizedBox(),
                      ],
                    ),
                    (!Responsive.isDesktop(context))
                        ? imageBody(context)
                        : SizedBox(),
                    (!Responsive.isDesktop(context))
                        ? SizedBox(height: defaultPadding)
                        : SizedBox(),
                    (!Responsive.isDesktop(context))
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                style: TextButton.styleFrom(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10), // <-- Radius
                                  ),
                                  backgroundColor: primaryColor,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: defaultPadding * 1.5,
                                    vertical: defaultPadding,
                                  ),
                                ),
                                child: Text("Label Gambar"),
                                onPressed: () {
                                  navigateLabelModal(context, labelString);
                                },
                              ),
                              SizedBox(height: defaultPadding),
                              ElevatedButton(
                                style: TextButton.styleFrom(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10), // <-- Radius
                                  ),
                                  backgroundColor: primaryColor,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: defaultPadding * 1.5,
                                    vertical: defaultPadding,
                                  ),
                                ),
                                child: Text("Sub Label Gambar"),
                                onPressed: () {
                                  navigateSubLabelModal(
                                      context, sublabelString);
                                },
                              ),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(height: defaultPadding),
                    titleBody(context),
                    SizedBox(height: defaultPadding),
                    categoriesBody(context),
                    SizedBox(height: defaultPadding),
                    descriptionBody(context),
                    SizedBox(height: defaultPadding),
                    tableuBody(context),
                    SizedBox(height: defaultPadding),
                    iframeBody(context),
                    SizedBox(height: defaultPadding),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          ElevatedButton(
                            style: TextButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10), // <-- Radius
                              ),
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
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10), // <-- Radius
                              ),
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
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10), // <-- Radius
                              ),
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: defaultPadding * 1.5,
                                vertical: defaultPadding,
                              ),
                            ),
                            child: Text("Simpan"),
                            onPressed: () async {
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

  imageBody(BuildContext context) {
    double containerSize = (Responsive.isDesktop(context))
        ? MediaQuery.of(context).size.width / 3
        : MediaQuery.of(context).size.width / 1;
    return Container(
      width: containerSize,
      height: 160,
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: fontColor)),
      child: Center(
        child: imageUrl != null
            ? Stack(
                children: <Widget>[
                  Image.network(
                    imageUrl,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                  Positioned(
                    right: 5.0,
                    child: InkWell(
                      child: Icon(
                        Icons.remove_circle,
                        size: 30,
                        color: Colors.red,
                      ),
                      onTap: () {
                        setState(() {
                          imageUrl = null;
                        });
                      },
                    ),
                  )
                ],
              )
            : imageBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          pickImage();
                        },
                        icon: Icon(Icons.upload, color: fontColor),
                        label: Text(
                          "Unggah Ilustrasi",
                          style: TextStyle(color: fontColor),
                        ),
                      ),
                      Text(
                        "Upload max: 2MB",
                        style: TextStyle(color: fontColor),
                      ),
                    ],
                  )
                : Stack(
                    children: <Widget>[
                      Image.memory(imageBytes),
                      Positioned(
                        right: 5.0,
                        child: InkWell(
                          child: Icon(
                            Icons.remove_circle,
                            size: 30,
                            color: Colors.red,
                          ),
                          onTap: () {
                            setState(() {
                              imageBytes = null;
                              imageString = null;
                            });
                          },
                        ),
                      )
                    ],
                  ),
      ),
    );
  }

  titleBody(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Judul",
            style: TextStyle(color: fontColor, fontSize: 16),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: titleController,
              style: TextStyle(color: fontColor),
              decoration: InputDecoration(
                fillColor: fontColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  categoriesBody(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kategori",
            style: TextStyle(color: fontColor, fontSize: 16),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField(
              items: listCategories.map((item) {
                return DropdownMenuItem(
                  child: Text(item['title']),
                  value: item['id'].toString(),
                );
              }).toList(),
              onChanged: (newVal) {
                setState(() {
                  categoriesPicked = newVal;
                });
              },
              value: categoriesPicked,
              decoration: InputDecoration(
                fillColor: fontColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  tableuBody(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tableu",
                    style: TextStyle(color: fontColor, fontSize: 16),
                  ),
                  SizedBox(height: defaultPadding),
                  TextField(
                    controller: tableuController,
                    style: TextStyle(color: fontColor),
                    decoration: InputDecoration(
                      fillColor: fontColor,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: fontColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              )),
              SizedBox(width: defaultPadding),
              SizedBox(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tinggi Tableu",
                      style: TextStyle(color: fontColor, fontSize: 16),
                    ),
                    SizedBox(height: defaultPadding),
                    TextField(
                      controller: tableuHeightController,
                      style: TextStyle(color: fontColor),
                      decoration: InputDecoration(
                        fillColor: fontColor,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: fontColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: defaultPadding),
          ElevatedButton(
            style: TextButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // <-- Radius
              ),
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: defaultPadding * 1.5,
                vertical: defaultPadding,
              ),
            ),
            child: Text("Masukkan Tableu"),
            onPressed: () {
              // uploadData();
              setState(() {
                descriptionController.insertHtml('<iframe src=' +
                    tableuController.text +
                    '?:showVizHome=no&:embed=true" width="100%" height="' +
                    tableuHeightController.text +
                    '"></iframe>');
              });
            },
          ),
        ],
      ),
    );
  }

  iframeBody(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Embed",
            style: TextStyle(color: fontColor, fontSize: 16),
          ),
          SizedBox(height: defaultPadding),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: iframeController,
              style: TextStyle(color: fontColor),
              decoration: InputDecoration(
                fillColor: fontColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: defaultPadding),
          ElevatedButton(
            style: TextButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // <-- Radius
              ),
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: defaultPadding * 1.5,
                vertical: defaultPadding,
              ),
            ),
            child: Text("Masukkan Embed"),
            onPressed: () {
              // uploadData();
              setState(() {
                descriptionController.insertHtml(iframeController.text);
              });
            },
          ),
        ],
      ),
    );
  }

  descriptionBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Deskripsi",
            style: TextStyle(fontSize: 16, color: bgColor),
          ),
          SizedBox(height: 10),
          HtmlEditor(
            controller: descriptionController,
            htmlEditorOptions: HtmlEditorOptions(
              hint: '',
              darkMode: false,
              initialText: descriptionText,
            ),
            htmlToolbarOptions: HtmlToolbarOptions(
              buttonColor: bgColor,
              textStyle: TextStyle(color: bgColor),
              defaultToolbarButtons: [
                StyleButtons(),
                FontSettingButtons(
                  fontName: false,
                  fontSizeUnit: false,
                ),
                ListButtons(
                  listStyles: false,
                ),
                FontButtons(
                  clearAll: false,
                  strikethrough: false,
                  superscript: false,
                  subscript: false,
                ),
                InsertButtons(
                  table: false,
                  audio: false,
                  hr: false,
                ),
                OtherButtons(
                  help: false,
                  copy: false,
                  paste: false,
                ),
              ],

              toolbarPosition: ToolbarPosition.aboveEditor, //by default
              toolbarType: ToolbarType.nativeScrollable, //by default
              onButtonPressed:
                  (ButtonType type, bool status, Function() updateStatus) {
                return true;
              },
              onDropdownChanged: (DropdownType type, dynamic changed,
                  Function(dynamic) updateSelectedItem) {
                return true;
              },
              mediaLinkInsertInterceptor: (String url, InsertFileType type) {
                return true;
              },
              mediaUploadInterceptor:
                  (PlatformFile file, InsertFileType type) async {
                //filename
                return true;
              },
            ),
            plugins: [
              SummernoteAtMention(
                  getSuggestionsMobile: (String value) {
                    var mentions = <String>['test1', 'test2', 'test3'];
                    return mentions
                        .where((element) => element.contains(value))
                        .toList();
                  },
                  mentionsWeb: ['test1', 'test2', 'test3'],
                  onSelect: (String value) {}),
            ],
          ),
        ],
      ),
    );
  }

  void navigateLabelModal(BuildContext context, String label) async {
    var labelData = await Navigator.of(context).push(
      PageRouteBuilder(
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.5),
          transitionDuration: Duration(milliseconds: 300),
          opaque: false,
          pageBuilder: (_, __, ___) => ArticlesLabelModal(label: label),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          }),
    );
    setState(() {
      labelString = labelData;
    });
  }

  void navigateSubLabelModal(BuildContext context, String sublabel) async {
    var sublabelData = await Navigator.of(context).push(
      PageRouteBuilder(
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.5),
          transitionDuration: Duration(milliseconds: 300),
          opaque: false,
          pageBuilder: (_, __, ___) =>
              ArticlesSubLabelModal(sublabel: sublabel),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          }),
    );
    setState(() {
      sublabelString = sublabelData;
    });
  }
}
