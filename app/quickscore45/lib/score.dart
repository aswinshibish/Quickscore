import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuickScoreScreen extends StatefulWidget {
  @override
  _QuickScoreScreenState createState() => _QuickScoreScreenState();
}

class _QuickScoreScreenState extends State<QuickScoreScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveScore() async {
    if (_nameController.text.isNotEmpty &&
        _courseController.text.isNotEmpty &&
        _scoreController.text.isNotEmpty) {
      await _firestore.collection('students').add({
        'name': _nameController.text,
        'course': _courseController.text,
        'score': int.parse(_scoreController.text),
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _nameController.clear();
        _courseController.clear();
        _scoreController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Score", style: TextStyle(color: Colors.yellow)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("image/logo12.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [

          IconButton(
            icon: Icon(Icons.bar_chart, color: Colors.yellow),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RankPage()),
              );
            },
          ),
         ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Student Name'),
            ),
            TextField(
              controller: _courseController,
              decoration: InputDecoration(labelText: 'Course'),
            ),
            TextField(
              controller: _scoreController,
              decoration: InputDecoration(labelText: 'Score '),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveScore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text('Save Score'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('students')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('image/Card1.jpg'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      data['course'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Score: ${data['score']}%',
                                      style: TextStyle(color: Colors.yellow),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                width: 50,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      value: (data['score'] as int) / 100,
                                      backgroundColor: Colors.grey.shade300,
                                      color: Colors.yellow,
                                      strokeWidth: 6,
                                    ),
                                    Center(
                                      child: Text(
                                        '${data['score']}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class RankPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchTopScores() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('students')
        .orderBy('score', descending: true)
        .limit(5)
        .get();
return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'name': data['name'] ?? 'Unknown',
        'course': data['course'] ?? 'N/A',
        'score': data['score'] ?? 0,
      };
    }).toList();
  }
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.yellow),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Rank", style: TextStyle(color: Colors.yellow)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("image/logo12.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchTopScores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No scores available"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var data = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('image/gold.jpg'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                data['course'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Score: ${data['score']}%',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: (data['score'] as int) / 100,
                                backgroundColor: Colors.grey.shade300,
                                color: Colors.red,
                                strokeWidth: 6,
                              ),
                              Center(
                                child: Text(
                                  '${data['score']}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
