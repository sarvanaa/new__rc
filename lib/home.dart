import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
// import 'package:url_launcher/url_launcher_string.dart';

class Home extends StatefulWidget {
  final String id;
  final String pass;

  const Home({Key? key, required this.id, required this.pass})
      : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic> data = {};
  List<String> tallyCodes = [];
  String? selectedTallyCode;
  // Map<String, String?> pdfUrls = {};

  Future<void> fetchData() async {
    try {
      print("Fetching project details...");
      var response = await http.post(
        Uri.parse("http://rcapp.nitt.edu/projectDetails.php"),
        //  Uri.parse("http://127.0.0.1/R&C/v1/projectDetails.php"),
        body: {"staff_ID": widget.id},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['error'] == false) {
        var dataList = jsonResponse['data'] as List;
        if (dataList.isNotEmpty) {
          var content =
              jsonDecode(dataList[0]['content']) as Map<String, dynamic>;
          setState(() {
            data = content;
            print("Fetched data: $data");
          });
        }
      } else {
        print('Error fetching data: ${jsonResponse['message']}');
      }
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  Future<void> fetchDataByTallyCode(String tallyCode) async {
    try {
      print("Fetching data by tally code: $tallyCode");
      var response = await http.post(
        Uri.parse("http://rcapp.nitt.edu/dataByTallyCode.php"),
        //  Uri.parse("http://127.0.0.1/R&C/v1/dataByTallyCode.php"),
        body: {"Tallycode": tallyCode},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['error'] == false) {
        var dataList = jsonResponse['data'] as List;
        if (dataList.isNotEmpty) {
          var content =
              jsonDecode(dataList[0]['content']) as Map<String, dynamic>;
          setState(() {
            data = content;
            print("Fetched data for tally code $tallyCode: $data");
          });
        }
      } else {
        print('Error fetching data: ${jsonResponse['message']}');
      }
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  Future<void> fetchTallyCodes() async {
    try {
      print("Fetching Tally Codes...");
      var response = await http.post(
        Uri.parse("http://rcapp.nitt.edu/fetchTallyCodes.php"),
        //  Uri.parse("http://127.0.0.1/R&C/v1/fetchTallyCodes.php"),
        body: {"staff_ID": widget.id},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['error'] == false) {
          // Ensure that 'tallyCodes' is not null and is a List
          if (jsonResponse['tallyCodes'] != null &&
              jsonResponse['tallyCodes'] is List) {
            var tallyCodesList = jsonResponse['tallyCodes'] as List;
            // Remove double quotes from each tally code
            var sanitizedTallyCodes =
                tallyCodesList.map((code) => code.replaceAll('"', '')).toList();
            setState(() {
              tallyCodes = sanitizedTallyCodes.cast<String>();
              if (tallyCodes.isNotEmpty) {
                selectedTallyCode = tallyCodes.first;
                fetchDataByTallyCode(selectedTallyCode!);
              }
              print("Fetched Tally Codes: $tallyCodes");
            });
          } else {
            print('Invalid TallyCode format in the response');
          }
        } else {
          print('Error fetching data: ${jsonResponse['message']}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchData();
    fetchTallyCodes();
  }

@override
Widget build(BuildContext context) {
  var filteredAndSortedKeys = data.keys
      .where((key) =>
          data[key] != null &&
          data[key].toString().isNotEmpty &&
          !key.contains('97. Sanction Order') &&
          !key.contains('98. Office Order') &&
          !key.contains('99. Utilization Certificate') &&
          !key.contains('99a. Expenditure Details'))
      .toList()
        ..sort((a, b) => a.compareTo(b));

  List<TableRow> rows = filteredAndSortedKeys.map((key) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(key, textAlign: TextAlign.center), // Key
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(
            data[key].toString(),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }).toList();

  if (rows.isEmpty) {
    rows.add(
      TableRow(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text('No Data Available', textAlign: TextAlign.center),
          )
        ],
      ),
    );
  }

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 252, 250, 253),
      title: Text("NITT R&C PROJECTS"),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/NITT_logo.png/481px-NITT_logo.png',
          width: 40.0,
          height: 40.0,
          fit: BoxFit.contain,
        ),
      ),
    ),
    body: SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),

            Text(
                'Welcome, ${data.containsKey('05. Name') ? data['05. Name'] : 'Loading...'}'),

            Text('staff Id: ${widget.id}'), // Welcome message
            SizedBox(height: 10.h),

            if (tallyCodes.isNotEmpty) Text('Select Tally Code:'),
            if (tallyCodes.isNotEmpty)
              DropdownButton<String>(
                value: selectedTallyCode,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTallyCode = newValue!;
                    fetchDataByTallyCode(
                        selectedTallyCode!); // Fetch data for the selected tally code
                  });
                },
                items:
                    tallyCodes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

            SizedBox(height: 20.h),

            Table(
              columnWidths: {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              border: TableBorder.all(),
              children: rows,
            ),
          ],
        ),
      ),
    ),
  );
}


}