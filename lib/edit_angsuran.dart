import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/lihatangsuran.dart';

class EditAngsuran extends StatefulWidget {
  final String? nik;
  final String? bulan;
  final String? totalbayar;

  EditAngsuran({
    this.nik,
    this.bulan,
    this.totalbayar,
  }); // Update constructor

  @override
  _EditAngsuranState createState() => _EditAngsuranState();
}

class _EditAngsuranState extends State<EditAngsuran> {
  TextEditingController nikController = TextEditingController();
  TextEditingController bulanController = TextEditingController();
  TextEditingController totalbayarController = TextEditingController();

  void EditAngsuran() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('bayar').doc(widget.nik);

    Map<String, dynamic> byr = {
      "nik": widget.nik,
      "bulan": bulanController.text,
      "totalbayar": totalbayarController.text
    };

    // update data to Firebase
    documentReference
        .update(byr)
        .whenComplete(() => print('${widget.nik} updated'));
  }

  void deleteData() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('bayar').doc(widget.nik);

    // delete data from Firebase
    documentReference
        .delete()
        .whenComplete(() => print('${widget.nik} deleted'));
  }

  void konfirmasi() {
    AlertDialog alertDialog = AlertDialog(
      content: Text("Apakah anda yakin akan menghapus data '${widget.nik}'?"),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.red, // Use backgroundColor instead of primary
          ),
          child: Text(
            "OK DELETE!",
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            deleteData();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LihatAngsuran()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.green, // Use backgroundColor instead of primary
          ),
          child: Text(
            "CANCEL",
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    nikController = TextEditingController(text: widget.nik);
    bulanController = TextEditingController(text: widget.bulan);
    totalbayarController = TextEditingController(text: widget.totalbayar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EDIT DATA"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Text(
              "Ubah Data Angsuran",
              style: TextStyle(
                color: Colors.red,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(height: 40),
            TextFormField(
              controller: nikController,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.orange, // Use backgroundColor instead of primary
                  ),
                  onPressed: () {
                    EditAngsuran();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LihatAngsuran()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text("Ubah"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red, // Use backgroundColor instead of primary
                  ),
                  onPressed: () {
                    konfirmasi();
                  },
                  child: Text("Hapus"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
