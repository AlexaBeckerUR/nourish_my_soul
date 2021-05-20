import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io' show Platform;

void main(List<String> arguments) async {
  Db db = new Db("mongodb://localhost:27017/test");
  await db.open();
  print('Connection succeeded!');
}