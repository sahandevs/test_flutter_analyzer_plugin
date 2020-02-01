import 'dart:isolate';

import 'lib/plugin_starter.dart';


void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}