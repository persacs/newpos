import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lihatangsuran.dart';

class TambahAngsur extends StatefulWidget {
  @override
  _TambahAngsurState createState() => _TambahAngsurState();
}

class _TambahAngsurState extends State<TambahAngsur> {
  TextEditingController bulanController = TextEditingController();
  TextEditingController totalbayarController = TextEditingController();
  String? selectedNik;
  List<String> nikList = [];

  @override
  void initState() {
    super.initState();
    fetchNikData();
  }

  Future<void> fetchNikData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('nasabah').get();
      List<String> fetchedNikList =
          snapshot.docs.map((doc) => doc['nik'].toString()).toList();
      setState(() {
        nikList = fetchedNikList;
      });
    } catch (error) {
      print('Error fetching NIK data: $error');
    }
  }

  void addData() async {
    if (selectedNik != null) {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('bayar').doc(selectedNik);

      Map<String, dynamic> byr = {
        "nik": selectedNik,
        "bulan": bulanController.text,
        "totalbayar": totalbayarController.text,
      };

      documentReference
          .set(byr)
          .then((value) => print('$selectedNik created'))
          .catchError((error) => print('Failed to add data: $error'));

      Navigator.pop(context);
    } else {
      print('Please select a NIK');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ADD DATA"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Text(
              "Input Data Angsuran Nasabah",
              style: TextStyle(
                color: Colors.red,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(height: 40),
            DropdownButtonFormField<String>(
              value: selectedNik,
              onChanged: (String? value) {
                setState(() {
                  selectedNik = value;
                });
              },
              items: nikList.map((nik) {
                return DropdownMenuItem<String>(
                  value: nik,
                  child: Text(nik),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: "NIK",
              ),
            ),
            TextFormField(
              controller: bulanController,
              decoration: InputDecoration(labelText: "Angsuran Bulan Ke"),
            ),
            TextFormField(
              controller: totalbayarController,
              decoration: InputDecoration(labelText: "Total Bayar"),
            ),
            ElevatedButton(
              onPressed: () {
                addData();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LihatAngsuran()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
