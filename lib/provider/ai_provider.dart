import 'dart:developer';

import 'package:flutter/cupertino.dart';

class DocumentAIProvider extends ChangeNotifier{
  String documentPath = "";

  void getDocumentPath(String documentPath){
    log("documentPath "+documentPath.toString());
    this.documentPath = documentPath;
    notifyListeners();
  }
}