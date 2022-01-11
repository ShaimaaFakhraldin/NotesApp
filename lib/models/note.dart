import 'package:intl/intl.dart';

class Note {
  int _id;
  String _title;
  String _content;
  String _imagePath;
  int _status;

  Note(this._id, this._title, this._content, this._imagePath ,this._status);

  int get id => _id;
  String get title => _title;
  String get content => _content;
  String get imagePath => _imagePath;
  int get status => _status;

  String get date {
    final date = DateTime.fromMillisecondsSinceEpoch(id);
    return DateFormat('EEE h:mm a, dd/MM/yyyy').format(date);
  }
}
