import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/edit_angsuran.dart';
import 'package:project/home.dart';
import 'package:project/tambah_angsur.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LihatAngsuran extends StatefulWidget {
  @override
  LihatAngsuranState createState() => LihatAngsuranState();
}

class LihatAngsuranState extends State<LihatAngsuran> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Angsuran Nasabah'),
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
                  builder: (context) => TambahAngsur(),
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
                  builder: (context) => Home(),
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
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('bayar').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    return doc["nik"].toString().contains(_searchQuery) ||
                        doc["bulan"].toString().contains(_searchQuery) ||
                        doc["totalbayar"].toString().contains(_searchQuery);
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
                                  title: Text(
                                    "NIK: ${documentSnapshot["nik"]}",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Angsuran Bulan Ke: ${documentSnapshot["bulan"]}",
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      Text(
                                        "Total Bayar: ${documentSnapshot["totalbayar"]}",
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(Icons.navigate_next_rounded),
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditAngsuran(
                                      nik: documentSnapshot["nik"],
                                      bulan: documentSnapshot["bulan"],
                                      totalbayar:
                                          documentSnapshot["totalbayar"],
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
