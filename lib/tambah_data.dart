import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'home.dart';

class TambahData extends StatefulWidget {
  @override
  _TambahDataState createState() => _TambahDataState();
}

class _TambahDataState extends State<TambahData> {
  TextEditingController nikController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController umurController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController nohpController = TextEditingController();
  String? pinjamValue = '1500000';
  String? tempoValue = '1';
  String? angsuran;
  XFile? _imageFile;
  XFile? _videoFile; // Add this line
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Tunggu sebentar, masih menginput data..."),
            ],
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Function to calculate installment based on pinjam and tempo
    void calculateAngsuran() {
      int pinjam = int.parse(pinjamValue!);
      int tempo = int.parse(tempoValue!);

      int hasilPinjam;
      int hasilTempo;

      if (pinjam == 1500000) {
        hasilPinjam = 1800000;
      } else if (pinjam == 3000000) {
        hasilPinjam = 3500000;
      } else if (pinjam == 5000000) {
        hasilPinjam = 5600000;
      } else if (pinjam == 10000000) {
        hasilPinjam = 11000000;
      } else {
        hasilPinjam = 0;
      }

      if (tempo == 1) {
        hasilTempo = 12;
      } else if (tempo == 2) {
        hasilTempo = 24;
      } else if (tempo == 3) {
        hasilTempo = 36;
      } else if (tempo == 4) {
        hasilTempo = 48;
      } else if (tempo == 5) {
        hasilTempo = 60;
      } else {
        hasilTempo = 0;
      }

      int hasilAngsuran = hasilPinjam ~/ hasilTempo;

      setState(() {
        angsuran = hasilAngsuran.toString();
      });
    }

    Future<void> _pickImage(ImageSource source) async {
      XFile? pickedFile = await ImagePicker().pickImage(source: source);
      setState(() {
        _imageFile = pickedFile;
      });
    }

    Future<void> _pickVideo(ImageSource source) async {
      XFile? pickedFile = await ImagePicker().pickVideo(source: source);
      if (pickedFile != null) {
        _videoController = VideoPlayerController.file(File(pickedFile.path))
          ..initialize().then((_) {
            setState(() {});
            _videoController!.setLooping(true);
            _videoController!.play();
          });
        setState(() {
          _videoFile = pickedFile;
        });
      }
    }

    Future<String> _uploadFileToFirebaseStorage(
        File file, String folder) async {
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        firebase_storage.Reference storageReference = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child(folder)
            .child(fileName);

        await storageReference.putFile(file);
        String fileUrl = await storageReference.getDownloadURL();
        return fileUrl;
      } catch (e) {
        print('Error uploading file to Firebase Storage: $e');
        return '';
      }
    }

    void _showNikExistsPopup() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("NIK nasabah sudah tersedia"),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> addData() async {
      String imageUrl = '';
      String videoUrl = '';

      if (_imageFile != null) {
        imageUrl = await _uploadFileToFirebaseStorage(
            File(_imageFile!.path), 'user_images');
      }

      if (_videoFile != null) {
        videoUrl = await _uploadFileToFirebaseStorage(
            File(_videoFile!.path), 'user_videos');
      }

      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('nasabah')
          .doc(nikController.text);

      Map<String, dynamic> nsb = {
        "nik": nikController.text,
        "nama": namaController.text,
        "umur": umurController.text,
        "alamat": alamatController.text,
        "nohp": nohpController.text,
        "pinjam": pinjamValue,
        "tempo": tempoValue,
        "angsuran": angsuran,
        "photoUrl": imageUrl,
        "videoUrl": videoUrl,
      };

      try {
        await documentReference.set(nsb);
        print('${nikController.text} created');
      } catch (error) {
        print('Failed to add data: $error');
      }
    }

    Future<void> _checkAndAddData() async {
      String nik = nikController.text;

      _showLoadingDialog(); // Show the loading dialog

      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('nasabah')
            .where('nik', isEqualTo: nik)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          _showNikExistsPopup();
        } else {
          await addData();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home()),
            (Route<dynamic> route) => false,
          );
        }
      } finally {
        _hideLoadingDialog(); // Hide the loading dialog
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("ADD DATA"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Text(
              "Input Data Nasabah",
              style: TextStyle(
                color: Colors.red,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            TextFormField(
              controller: nikController,
              decoration: InputDecoration(
                labelText: "NIK",
              ),
            ),
            TextFormField(
              controller: namaController,
              decoration: InputDecoration(labelText: "Nama"),
            ),
            TextFormField(
              controller: umurController,
              decoration: InputDecoration(labelText: "Umur"),
            ),
            TextFormField(
              controller: alamatController,
              decoration: InputDecoration(labelText: "Alamat"),
            ),
            TextFormField(
              controller: nohpController,
              decoration: InputDecoration(labelText: "No HP"),
            ),
            DropdownButtonFormField<String>(
              value: pinjamValue,
              onChanged: (String? newValue) {
                setState(() {
                  pinjamValue = newValue;
                  calculateAngsuran();
                });
              },
              decoration: InputDecoration(labelText: "Pinjam"),
              items: <String>['1500000', '3000000', '5000000', '10000000']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButtonFormField<String>(
              value: tempoValue,
              onChanged: (String? newValue) {
                setState(() {
                  tempoValue = newValue;
                  calculateAngsuran();
                });
              },
              decoration: InputDecoration(labelText: "Tempo Tahun"),
              items: <String>['1', '2', '3', '4', '5']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                calculateAngsuran();
              },
              child: Text("HITUNG ANGSURAN"),
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Angsuran Perbulan",
              ),
              enabled: false,
              controller: TextEditingController(text: angsuran ?? ''),
            ),
            SizedBox(height: 20),
            Text("Upload Foto"),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Icon(Icons.camera_alt),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Icon(Icons.image),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                _pickImage(ImageSource.gallery);
              },
              child: Container(
                color: Colors.grey[200],
                height: 150,
                width: 150,
                child: _imageFile == null
                    ? Center(child: Text('No image selected.'))
                    : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            Text("Upload Video"),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _pickVideo(ImageSource.camera),
                  child: Icon(Icons.videocam),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _pickVideo(ImageSource.gallery),
                  child: Icon(Icons.video_library),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                _pickVideo(ImageSource.gallery);
              },
              child: Container(
                color: Colors.grey[200],
                height: 150,
                width: 150,
                child: _videoFile == null
                    ? Center(child: Text('No video selected.'))
                    : _videoController != null &&
                            _videoController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        : Container(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _checkAndAddData();
              },
              child: Text("SIMPAN"),
            ),
          ],
        ),
      ),
    );
  }
}
