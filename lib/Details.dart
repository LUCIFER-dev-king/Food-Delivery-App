import 'package:flutter/material.dart';
import 'OrderManagement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Details extends StatefulWidget {
  final userId;
  final time;
  final docId;
  final total;

  Details({this.userId,this.time,this.docId,this.total});

  @override
   _DetailsState createState() => _DetailsState();
}
class _DetailsState extends State<Details> {

  
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseUser user;
  OrderManagement _orderManagement = new OrderManagement();
  Stream finalList;

  String hotelName='';
  String hotelAddress='';
  String hotelphone = '';


  getOrders(){
    _orderManagement..getUserList(widget.userId).then((result){
      setState(() {
         finalList = result;
      });
    });
  }
//TODO: Since the accessing the dataSnapshots is not poosbile the HotelBasicInfo collection is removed so to get hotel info we need query to document fields.

  gethotelDetails(String id) async {
    await Firestore.instance.collection('HotelManagement').document(id).collection('HotelBasicInfo').document('Zc38qxhbZ1v4kiD7sooP').get().then((value){
      setState(() {
        hotelAddress = value.data['address'];
        hotelName = value.data['name'];
        hotelphone = value.data['phone'];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.getOrders();
  }

   @override
   Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text('Details'),
       ),
       body: finalOrder()
    );
  }


    Future<bool> hotelDialog(BuildContext context) async{
     return showDialog(
       context: context,
       barrierDismissible: false,
       builder: (BuildContext context){
         return AlertDialog(
           title: Text('Hotel Information', style: TextStyle(fontSize: 22.0)),
           content: Container(
             height: 150.0,
             child: Column(
               mainAxisAlignment: MainAxisAlignment.start,
               children: <Widget>[
                Container(
                     alignment: Alignment.centerLeft,
                     child: Text(hotelName,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                   ),
                 SizedBox(height: 5.0,),
                  Container(
                     alignment: Alignment.centerLeft,
                     child: Text(hotelphone,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                   ),
                 SizedBox(height: 5.0,),
                  Container(
                     alignment: Alignment.centerLeft,
                     child: Text(hotelAddress,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                   ),
               ],
             ),
           ),
           actions: <Widget>[
             FlatButton(
               child: Text('OK'),
               textColor: Colors.blue,
               onPressed: (){
                 Navigator.of(context).pop();
               },
             )
           ],
         );
       }
     );
   }

   Widget finalOrder(){
    if(finalList != null){
      return Column(
        children: <Widget>[
          Expanded(
            child :  StreamBuilder(
          stream: finalList,
          builder: (context,snapshot){
            return ListView.builder(
                padding: EdgeInsets.all(5.0),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context,i){
                  return Card(
                 child: ListTile(
                    title: Text(snapshot.data.documents[i].data['name']),
                    subtitle : Text(snapshot.data.documents[i].data['price']),
                    onTap: (){
                      gethotelDetails(snapshot.data.documents[i].data['hotelId']);
                      print(hotelName);
                      if(hotelName!=null){
                        hotelDialog(context);
                      }else{
                        
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      Container(
        padding: EdgeInsets.all(10.0),
        child: Material(
           elevation: 7.0,
           borderRadius: BorderRadius.circular(5.0),
           child: Container(
             width: double.infinity,
             padding: EdgeInsets.all(10.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
                 Container(
                   alignment: Alignment.centerLeft,
                   child: Text("ORDER SUMMARY: ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
                 ),

                 //TODO: The name and address are hard coded need to be update when the user screen is finished.
                 SizedBox(height: 5.0,),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Name: ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.black)),
                        
                        Text("Lucifer", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.grey[500]))
                      ],
                    ),
                    SizedBox(height: 5.0,),
                  Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Address :", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.black)),
                        Container(
                          width: MediaQuery.of(context).size.width*10.0,
                          child: SelectableText.rich(
                          TextSpan(
                            text: "\t\t\t\t\t\t\t21, West Car Street, Chidambaram", 
                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.grey[500])
                          )
                        )
                        )
                       
                      ],
                    ),
                 SizedBox(height: 5.0,),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Order time:", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.black)),
                        
                        Text(widget.time, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.grey[500]))
                      ],
                    ),
                    SizedBox(height: 5.0,),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.black)),
                        
                        Text(widget.total.toString(), style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.grey[500]))
                      ],
                    ),
               ],
             ),
           ),
         ),
      ),
      Container(
        padding: EdgeInsets.all(10.0),
        child: SizedBox(
          height: 50.0,
          width: double.infinity,
          child: RaisedButton(
            onPressed: (){

              _orderManagement.updateData(widget.docId, {
                'delivered' : true
              });
            },
            child: Text('Order Delivered',style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25
              ),
            ),
            color: Colors.blue,
          ),
        )
      )
        ],
      );
    }
    else{
      return Text('Loading. Please Wait for a second.....');
    }
  }
} 