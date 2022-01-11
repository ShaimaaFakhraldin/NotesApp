import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shaimaa_notes/helper/note_provider.dart';
import 'package:shaimaa_notes/models/note.dart';
import 'package:shaimaa_notes/utils/constants.dart';
import 'package:shaimaa_notes/widgets/delete_popup.dart';
import 'package:shaimaa_notes/widgets/lite_rolling_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'note_view_screen.dart';

class NoteEditScreen extends StatefulWidget {
  static const route = '/edit-note';

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  File _image;

  final picker = ImagePicker();

  bool firstTime = true;
  Note selectedNote;
  int id;
  int currentState  = 1;


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    if (firstTime) {
      id = ModalRoute.of(this.context).settings.arguments;

      if (id != null) {
        selectedNote = Provider.of<NoteProvider>(
          this.context,
          listen: false,
        ).getNote(id);

        titleController.text = selectedNote?.title;
        contentController.text = selectedNote?.content;
        currentState = selectedNote?.status;

        if (selectedNote?.imagePath != null) {
          _image = File(selectedNote.imagePath);
        }
      }
    }
    firstTime = false;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        elevation: 0.7,
        backgroundColor: white,
      //  title: Text("New note" ,style:  TextStyle(color: Colors.black ,fontSize: 22),),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back),
          color: black,
        ),
        actions: [
          Row(
            children: [
              Text(
                'Status : ',
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    letterSpacing: 1.0,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color:Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(width: 3,),
              Container(

                child:
              LiteRollingSwitch(
                value: currentState== 1,
                textOn: 'Open',
                textOff: 'Close',
                colorOn: Colors.greenAccent[700],
                colorOff: Colors.grey,
                iconOn: Icons.done,
                iconOff: Icons.close,
                textSize: 12.0,
                onChanged: (bool state) {
                    currentState = state ? 1 : 0;
                  print('Current State of SWITCH IS: $currentState');
                },
              )),
            ],
          ),
          SizedBox(width: 10,),

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20,),



            Padding(
              padding: EdgeInsets.only(
                  left: 10.0, right: 5.0, top: 10.0, bottom: 5.0),
              child: TextField(
                controller: titleController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: createTitle,
                decoration: InputDecoration(
                    hintText: 'Enter Note Title', border: InputBorder.none),
              ),
            ),
            if (_image != null)
              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width,
                height: 250.0,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        image: DecorationImage(
                          image: FileImage(_image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Container(
                          height: 30.0,
                          width: 30.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _image = null;
                              });
                            },
                            child: Icon(
                              Icons.delete,
                              size: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 5.0, top: 10.0, bottom: 5.0),
              child: TextField(
                controller: contentController,
                maxLines: null,
                style: createContent,
                decoration: InputDecoration(
                  hintText: 'Enter Something...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: headerColor,
                onPressed: () {
                  if (titleController.text.isEmpty)
                    titleController.text = 'Untitled Note';

                  saveNote();
                },
                child: Icon(Icons.save),
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                backgroundColor: headerColor,
                  child: Icon(Icons.photo_camera),
                  onPressed: () {
                    getImage(ImageSource.camera);
                  },
                heroTag: null,
              ),
              SizedBox(
                height: 10,
              ),

              FloatingActionButton(
                backgroundColor: headerColor,
                  child: Icon(Icons.insert_photo),
                  onPressed: () {
                    getImage(ImageSource.gallery);
                  },
                heroTag: null,
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                backgroundColor: headerColor,
                child: Icon(Icons.delete),
                onPressed: () {
                  if (id != null) {
                    _showDialog();
                  } else {
                    Navigator.pop(context);
                  }
                },
                heroTag: null,
              ),
              SizedBox(
                height: 10,
              ),


            ]
        )
      // floatingActionButton:
      // FloatingActionButton(
      //   onPressed: () {
      //     if (titleController.text.isEmpty)
      //       titleController.text = 'Untitled Note';
      //
      //     saveNote();
      //   },
      //   child: Icon(Icons.save),
      // ),
    );
  }

  getImage(ImageSource imageSource) async {
    PickedFile imageFile = await picker.getImage(source: imageSource);

    if (imageFile == null) return;

    File tmpFile = File(imageFile.path);

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = basename(imageFile.path);

    tmpFile = await tmpFile.copy('${appDir.path}/$fileName');

    setState(() {
      _image = tmpFile;
    });
  }

  void saveNote() {
    String title = titleController.text.trim();
    String content = contentController.text.trim();

    String imagePath = _image != null ? _image.path : null;

    if (id != null) {
      Provider.of<NoteProvider>(
        this.context,
        listen: false,
      ).addOrUpdateNote(id, title, content, imagePath, EditMode.UPDATE ,currentState);
      Navigator.of(this.context).pop();
    } else {
      int id = DateTime.now().millisecondsSinceEpoch;

      Provider.of<NoteProvider>(this.context, listen: false)
          .addOrUpdateNote(id, title, content, imagePath, EditMode.ADD ,currentState);

      Navigator.of(this.context)
          .pushReplacementNamed(NoteViewScreen.route, arguments: id);
    }
  }

  void _showDialog() {
    showDialog(
        context: this.context,
        builder: (context) {
          return DeletePopUp(selectedNote);
        });
  }
}
