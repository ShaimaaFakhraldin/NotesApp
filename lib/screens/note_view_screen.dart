import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shaimaa_notes/helper/note_provider.dart';
import 'package:shaimaa_notes/models/note.dart';
import 'package:shaimaa_notes/utils/constants.dart';
import 'package:shaimaa_notes/widgets/delete_popup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'note_edit_screen.dart';

class NoteViewScreen extends StatefulWidget {
  static const route = '/note-view';

  @override
  _NoteViewScreenState createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  Note selectedNote;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    final id = ModalRoute.of(context).settings.arguments;

    final provider = Provider.of<NoteProvider>(context);

    if (provider.getNote(id) != null) {
      selectedNote = provider.getNote(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        elevation: 0.7,
        backgroundColor: white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.grey,
            ),
            onPressed: () => _showDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                selectedNote?.title,
                style: viewTitleStyle,
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(

                    Icons.access_time,
                    color: headerColor,
                    size: 18,
                  ),
                ),
                Expanded(child:
                Text('${selectedNote?.date}')),
                Row(
                  children: [
                    Text(
                      "Status :",
                      style: itemDateStyle,
                    ),
                    SizedBox(width: 4,),
                    Text(
                      selectedNote. status  == 1? "Open" : "Close",
                      style:  GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: 11.0,
                          color: selectedNote.status ==1 ? Colors.greenAccent[700] :  Colors.red,
                        ),
                      ),
                    ),

                  ],

                ),
                SizedBox(width: 15,)
              ],
            ),

            if (selectedNote.imagePath != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.file(
                  File(selectedNote.imagePath),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                selectedNote.content,
                style: viewContentStyle,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: headerColor,
        onPressed: () {
          Navigator.pushNamed(context, NoteEditScreen.route,
              arguments: selectedNote.id);
        },
        child: Icon(Icons.edit),
      ),
    );
  }

  _showDialog() {
    showDialog(
        context: this.context,
        builder: (context) {
          return DeletePopUp(selectedNote);
        });
  }
}
