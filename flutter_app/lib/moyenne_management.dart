import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class MoyenneManagement extends StatefulWidget {
  const MoyenneManagement({super.key});
  @override
  State<MoyenneManagement> createState() => _MoyenneManagementState();
}

class _MoyenneManagementState extends State<MoyenneManagement> {
  List<Map<String,dynamic>> classes=[] , students=[], subjects=[], notes=[];
  String? selectedClass, selectedStudent, error;
  bool loading=false, saving=false;
  final Map<String,Map<String,TextEditingController>> controllers={};
  final Map<String,String> types={};
  @override void initState(){super.initState(); _loadClassesAndSubjects();}
  @override void dispose(){for(final row in controllers.values){for(final c in row.values){c.dispose();}} super.dispose();}
  Future<void> _loadClassesAndSubjects() async {
    try { final r=await Future.wait([http.get(Uri.parse('${ApiConfig.baseUrl}/api/classes')),http.get(Uri.parse('${ApiConfig.baseUrl}/api/matieres'))]);
      if(r.any((x)=>x.statusCode!=200)) throw Exception('Erreur de chargement');
      if(!mounted)return; setState((){classes=List<Map<String,dynamic>>.from(jsonDecode(r[0].body).map((e)=>Map<String,dynamic>.from(e)));subjects=List<Map<String,dynamic>>.from(jsonDecode(r[1].body).map((e)=>Map<String,dynamic>.from(e)));});
    }catch(e){if(mounted)setState(()=>error='Erreur API : $e');}
  }
  Future<void> _loadStudents(String code) async {setState(() { selectedClass=code; selectedStudent=null; students=[]; notes=[]; error=null; });try{final r=await http.get(Uri.parse('${ApiConfig.baseUrl}/api/etudiants?codClass=${Uri.encodeQueryComponent(code)}'));if(r.statusCode!=200)throw Exception('HTTP ${r.statusCode}');if(mounted)setState(()=>students=List<Map<String,dynamic>>.from(jsonDecode(r.body).map((e)=>Map<String,dynamic>.from(e))));}catch(e){if(mounted)setState(()=>error='$e');}}
  Future<void> _loadStudent(String nce) async {setState(() { selectedStudent=nce; loading=true; error=null; });try{final r=await http.get(Uri.parse('${ApiConfig.baseUrl}/api/notes/etudiant/${Uri.encodeComponent(nce)}'));if(r.statusCode!=200)throw Exception('HTTP ${r.statusCode}');final data=List<Map<String,dynamic>>.from(jsonDecode(r.body).map((e)=>Map<String,dynamic>.from(e)));for(final s in subjects){final code=s['codMat'].toString();Map<String,dynamic>? found; for (final n in data) { if (n['codMat']==code) { found=n; break; } }final type=(found?['typeModule']??'AUTRE').toString();types[code]=type;controllers[code]={'tp1':TextEditingController(text:found?['tp1']?.toString()??''),'tp2':TextEditingController(text:found?['tp2']?.toString()??''),'ds':TextEditingController(text:found?['ds']?.toString()??''),'exam':TextEditingController(text:found?['exam']?.toString()??'')};}if(mounted)setState(() { notes=data; loading=false; });}catch(e){if(mounted)setState(() { loading=false; error='Erreur de chargement des notes : $e'; });}}
  double? _value(String code,String key){final raw=controllers[code]?[key]?.text.trim().replaceAll(',','.');if(raw==null||raw.isEmpty)return null;return double.tryParse(raw);}
  double? _average(String code){final tp=types[code]=='TP';final values=tp?[_value(code,'tp1'),_value(code,'tp2')]:[_value(code,'ds'),_value(code,'exam')];final valid=values.whereType<double>().toList();if(valid.isEmpty)return null;return valid.reduce((a,b)=>a+b)/valid.length;}
  double? get generalAverage {final values=subjects.map((s)=>_average(s['codMat'].toString())).whereType<double>().toList();if(values.isEmpty)return null;return values.reduce((a,b)=>a+b)/values.length;}
  Future<void> _save(String code) async {if(selectedStudent==null)return;final type=types[code]??'AUTRE';final fields=controllers[code]!;for(final key in (type=='TP'?['tp1','tp2']:['ds','exam'])){final raw=fields[key]!.text.trim();final n=raw.isEmpty?null:double.tryParse(raw.replaceAll(',','.'));if(raw.isNotEmpty&&(n==null||n<0||n>20)){_message('La note doit être comprise entre 0 et 20');return;}}
    setState(()=>saving=true);try{final body={'nce':selectedStudent,'codMat':code,'typeModule':type,'tp1':type=='TP'?_value(code,'tp1'):null,'tp2':type=='TP'?_value(code,'tp2'):null,'ds':type=='TP'?null:_value(code,'ds'),'exam':type=='TP'?null:_value(code,'exam')};final r=await http.post(Uri.parse('${ApiConfig.baseUrl}/api/notes'),headers:{'Content-Type':'application/json'},body:jsonEncode(body));if(r.statusCode!=200)throw Exception(r.body);_message('Notes enregistrées pour $code');}catch(e){_message('Erreur : $e');}finally{if(mounted)setState(()=>saving=false);}}
  void _message(String s)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));
  Widget _field(String code,String key){return SizedBox(width:76,child:TextField(controller:controllers[code]![key],keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:key.toUpperCase(),isDense:true,border:const OutlineInputBorder()),onChanged:(_)=>setState((){})));}
  @override Widget build(BuildContext context){Map<String,dynamic>? student; for (final s in students) { if (s['nce']==selectedStudent) { student=s; break; } }final cl=student?['classe'] as Map<String,dynamic>?;final dep=cl?['departement'] as Map<String,dynamic>?;
    return Scaffold(appBar:AppBar(title:const Text('Notes & moyennes'),backgroundColor:const Color(0xFF6A1B9A),foregroundColor:Colors.white),body:SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      DropdownButtonFormField<String>(value:selectedClass,decoration:const InputDecoration(labelText:'Classe',border:OutlineInputBorder()),items:classes.map((e){final c=e['codClass'].toString();return DropdownMenuItem(value:c,child:Text(c));}).toList(),onChanged:(v){if(v!=null)_loadStudents(v);}),const SizedBox(height:12),
      DropdownButtonFormField<String>(value:selectedStudent,decoration:const InputDecoration(labelText:'Étudiant',border:OutlineInputBorder()),items:students.map((e)=>DropdownMenuItem(value:e['nce'].toString(),child:Text('${e['nce']} - ${e['nom']} ${e['prenom']}'))).toList(),onChanged:students.isEmpty?null:(v){if(v!=null)_loadStudent(v);}),
      if(error!=null)Padding(padding:const EdgeInsets.all(8),child:Text(error!,style:const TextStyle(color:Colors.red))),if(loading)const Center(child:CircularProgressIndicator()),
      if(!loading&&selectedStudent!=null)...[const SizedBox(height:12),Card(color:Colors.purple.shade50,child:Padding(padding:const EdgeInsets.all(12),child:Text('Classe : ${cl?['codClass']??selectedClass}   Département : ${dep?['codDept']??'-'}\nÉtudiant : $selectedStudent\nNom : ${student?['nom']??'-'}   Prénom : ${student?['prenom']??'-'}'))),
      const SizedBox(height:12),const Text('Type de chaque module : TP ou autre',style:TextStyle(fontWeight:FontWeight.w600)),
      ...subjects.map((s){final code=s['codMat'].toString();final type=types[code]??'AUTRE';final avg=_average(code);return Card(margin:const EdgeInsets.symmetric(vertical:7),child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('$code - ${s['intMat']}',style:const TextStyle(fontWeight:FontWeight.bold)),DropdownButton<String>(value:type,items:const [DropdownMenuItem(value:'TP',child:Text('Module TP')),DropdownMenuItem(value:'AUTRE',child:Text('Module DS / Exam'))],onChanged:(v){if(v!=null)setState(()=>types[code]=v);}),Wrap(spacing:8,runSpacing:8,children:type=='TP'?[_field(code,'tp1'),_field(code,'tp2')]:[_field(code,'ds'),_field(code,'exam')]),const SizedBox(height:8),Text('Moyenne : ${avg?.toStringAsFixed(2)??'—'} / 20',style:const TextStyle(fontWeight:FontWeight.bold,color:Color(0xFF6A1B9A))),Align(alignment:Alignment.centerRight,child:ElevatedButton(onPressed:saving?null:()=>_save(code),child:const Text('Enregistrer')))])));}),
      Card(color:Colors.deepPurple.shade50,child:Padding(padding:const EdgeInsets.all(16),child:Text('Moyenne générale : ${generalAverage?.toStringAsFixed(2)??'—'} / 20',textAlign:TextAlign.center,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:18,color:Color(0xFF4A148C))))),
      const Text('Calcul : moyenne arithmétique des notes disponibles. La moyenne générale est la moyenne simple des moyennes des modules renseignés.',style:TextStyle(fontSize:12,color:Colors.black54)),
      ]])));
  }
}
