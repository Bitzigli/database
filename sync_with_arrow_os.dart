import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';
import 'tools/extended_codename_creator.dart';
import 'tools/is_supported.dart';
import 'tools/add_to_support.dart';

void main() async {
  int numberOfCovered = 0;
  int numberOfNotCovered = 0;
  List<String> listOfNotCovered = [];
  http.Response response = await http.get(Uri.parse("https://raw.githubusercontent.com/ArrowOS/arrow_ota/master/arrow_ota.json"));
  if (response.statusCode == 200) {
    String content = response.body;
    YamlMap ydoc = loadYaml(content);
    for (var readCodename in ydoc.keys) {
      stdout.write(readCodename + "\n");
      YamlList deviceList = ydoc[readCodename];
      YamlMap deviceMap = deviceList[0];
      String readVendor = deviceMap["oem"];
      List<String> androidVersionAndState = androidVersionAndStateForArrowOS(deviceMap: deviceMap);
      String androidVersion = androidVersionAndState[0];
      String romState = androidVersionAndState[1];
      stdout.write("$readVendor\n");
      String extendedCodename = extendedCodenameCreator(readCodename: readCodename, readVendor: readVendor);
      stdout.write("$extendedCodename\n");
      stdout.write("$androidVersion\n");
      stdout.write("$romState\n");
      if (isSupported(extendedCodename: extendedCodename)) {
        numberOfCovered += 1;
        addToSupport(
          androidVersion: androidVersion,
          extendedCodename: extendedCodename,
          romName: "ArrowOS",
          romState: romState,
          romSupport: true,
          romWebpage: "https://arrowos.net/",
          deviceWebpage: "https://arrowos.net/download/"
        );
      }
      else {
        numberOfNotCovered += 1;
        listOfNotCovered += [extendedCodename];
      }
    }
    stdout.write("Covered: $numberOfCovered\n");
    stdout.write("Not covered: $numberOfNotCovered\n");
    for (var deviceNotCovered in listOfNotCovered) {
      stdout.write("$deviceNotCovered\n");
    }
  }
}

List<String> androidVersionAndStateForArrowOS ({
  required YamlMap deviceMap
}) {
  String androidVersion = "";
  if (deviceMap.containsKey("v13.0")) {
    androidVersion = "13";
    return [androidVersion, stateFromRomList(romList: deviceMap["v13.0"])];
  }
  else if (deviceMap.containsKey("v13.1")) {
    androidVersion = "13";
    return [androidVersion, stateFromRomList(romList: deviceMap["v13.1"])];
  }
  else if (deviceMap.containsKey("v12.1")) {
    androidVersion = "12L";
    return [androidVersion, stateFromRomList(romList: deviceMap["v12.1"])];
  }
  else if (deviceMap.containsKey("v12.0")) {
    androidVersion = "12";
    return [androidVersion, stateFromRomList(romList: deviceMap["v12.0"])];
  }
  else if (deviceMap.containsKey("v11.0")) {
    androidVersion = "11";
    return [androidVersion, stateFromRomList(romList: deviceMap["v11.0"])];
  }
  else if (deviceMap.containsKey("v10.0")) {
    androidVersion = "10";
    return [androidVersion, stateFromRomList(romList: deviceMap["v10.0"])];
  }
  else {
    throw Exception("Device ${deviceMap["model"]} does not include any known Android version.");
  }
}

String stateFromRomList({
  required YamlList romList
}) {
  YamlMap romMap = romList[0];
  if (romMap.containsKey("OFFICIAL")) {
    return "Official";
  }
  else if (romMap.containsKey("UNOFFICIAL")) {
    return "Unofficial";
  }
  else if (romMap.containsKey("COMMUNITY")) {
    return "Community";
  }
  else {
    throw Exception("No OFFICIAL, UNOFFICIAL nor COMMUNITY keys found");
  }
}
