import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'tambah_data.dart';
import 'edit_data.dart';
import 'lihatangsuran.dart';
import 'youtube_video_page.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playAudio() async {
    await _audioPlayer.play(AssetSource('audio/suara.mp3'));
  }

  Future<Map<String, dynamic>> _getTotalBayar(String nik) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('bayar').doc(nik).get();
    return documentSnapshot.exists
        ? documentSnapshot.data() as Map<String, dynamic>
        : {"totalbayar": "N/A"};
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Nasabah'),
        // Removed the logout button from the AppBar
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TambahData(),
                ),
              );
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LihatAngsuran(),
                ),
              );
            },
            child: Icon(Icons.list),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _playAudio,
              child: Text('Play Audio'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => YouTubeVideoPage()),
                );
              },
              child: Text('Play YouTube Video'),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('nasabah').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    return doc["nik"].toString().contains(_searchQuery) ||
                        doc["nama"].toString().contains(_searchQuery) ||
                        doc["angsuran"].toString().contains(_searchQuery);
                  }).toList();

                  return Container(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                    child: Card(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot documentSnapshot =
                              filteredDocs[index];
                          return Column(
                            children: [
                              GestureDetector(
                                child: ListTile(
                                  leading: documentSnapshot["photoUrl"] != null
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            documentSnapshot["photoUrl"],
                                          ),
                                        )
                                      : Icon(Icons.person),
                                  title: Text(
                                    "NIK: ${documentSnapshot["nik"]}",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  subtitle: FutureBuilder(
                                    future:
                                        _getTotalBayar(documentSnapshot["nik"]),
                                    builder: (context,
                                        AsyncSnapshot<Map<String, dynamic>>
                                            totalBayarSnapshot) {
                                      if (totalBayarSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (totalBayarSnapshot.hasError) {
                                        return Text(
                                            'Error: ${totalBayarSnapshot.error}');
                                      } else {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Nama: ${documentSnapshot["nama"]}",
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            Text(
                                              "Angsuran: ${documentSnapshot["angsuran"]}",
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            Text(
                                              "Total Bayar: ${totalBayarSnapshot.data!["totalbayar"]}",
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                  trailing: Icon(Icons.navigate_next_rounded),
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditData(
                                      nik: documentSnapshot["nik"],
                                      nama: documentSnapshot["nama"],
                                      umur: documentSnapshot["umur"],
                                      alamat: documentSnapshot["alamat"],
                                      nohp: documentSnapshot["nohp"],
                                      pinjam: documentSnapshot["pinjam"],
                                      tempo: documentSnapshot["tempo"],
                                      photoUrl: documentSnapshot["photoUrl"],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                color: Colors.black,
                                indent: 10,
                                endIndent: 10,
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.black,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
