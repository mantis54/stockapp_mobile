import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

FirebaseUser user;
String uid;
String docId;

Map<String, dynamic> data;

String url = 'https://api.iextrading.com/1.0';

double looseCash;

final  NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_us', name: '\$', decimalDigits: 2);
final NumberFormat percentFormatter = NumberFormat.currency(locale: 'en_us');