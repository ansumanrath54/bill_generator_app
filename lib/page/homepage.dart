import 'package:flutter/material.dart';
import '../api/pdf_api.dart';
import '../api/pdf_invoice_api.dart';
import '../model/itemlist.dart';
import '../model/customer.dart';
import '../model/invoice.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late String name, phone, email, company;
  late Items item_1, item_2;
  String? valueChoose_1, valueChoose_2;
  late int quantity_1, quantity_2;
  late Customer customer;
  Color _color = Colors.greenAccent;
  List dropDownList = ['Coffee', 'Orange', 'Apple', 'Mango', 'Blue Berries'];
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  bool validate() {
    if(signupFormKey.currentState!.validate()) {
      return(true);
    }
    else {
      return(false);
    }
  }

  String? validateInput(String? value) {
    if(value!.isEmpty) {
      return "Required";
    }
    else if(value.length > 25) {
      return "Max length should not exceed 25";
    }
    else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill your details'),
      ),
      body:
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Form(
                key: signupFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Name"),
                      validator: validateInput,
                      onChanged: (value){
                        name=value;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: validateInput,
                      onChanged: (value){
                        email=value;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: "Phone No"),
                      validator: validateInput,
                      onChanged: (value){
                        phone=value;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Company Name"),
                      validator: validateInput,
                      onChanged: (value){
                        company=value;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: const [
                  Text('Items'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  DropdownButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    value: valueChoose_1,
                    onChanged: (value) {
                      setState(() {
                        valueChoose_1 = value.toString();
                      });
                    },
                    items: dropDownList.map((valueItem) {
                      return DropdownMenuItem(
                        value: valueItem,
                        child: Text(valueItem),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 80),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "No of Items"),
                      validator: validateInput,
                      onChanged: (value){
                        quantity_1 = int.parse(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  DropdownButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    value: valueChoose_2,
                    onChanged: (value) {
                      setState(() {
                        valueChoose_2 = value.toString();
                      });
                    },
                    items: dropDownList.map((valueItem) {
                      return DropdownMenuItem(
                        value: valueItem,
                        child: Text(valueItem),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 80),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "No of Items"),
                      validator: validateInput,
                      onChanged: (value){
                        quantity_2 = int.parse(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Container(
                height: 40,
                width: double.infinity,
                color: _color,
                child: MaterialButton(
                  splashColor: Colors.blueGrey,
                  onPressed: () async {
                    if(validate()) {
                      try {
                        customer = Customer(name: name, email: email, company: company, phone: phone);
                        item_1 = Items(itemName: valueChoose_1.toString(), quantity: quantity_1, unitPrice: checkPrice(valueChoose_1.toString()));
                        item_2 = Items(itemName: valueChoose_2.toString(), quantity: quantity_2, unitPrice: checkPrice(valueChoose_2.toString()));
                        final date = DateTime.now();
                        final dueDate = date.add(const Duration(days: 7));

                        final invoice = Invoice(
                          customer: Customer(
                              name: name,
                              email: email,
                              phone: phone,
                              company: company
                          ),
                          info: InvoiceInfo(
                            date: date,
                            dueDate: dueDate,
                            number: '${DateTime.now().year}-${DateTime.now().month}${DateTime.now().day}-${DateTime.now().hour}${DateTime.now().minute}',
                          ),
                          items: [
                            InvoiceItem(
                              description: item_1.itemName,
                              date: DateTime.now(),
                              quantity: item_1.quantity,
                              vat: 0.19,
                              unitPrice: item_1.unitPrice,
                            ),
                            InvoiceItem(
                              description: item_2.itemName,
                              date: DateTime.now(),
                              quantity: item_2.quantity,
                              vat: 0.19,
                              unitPrice: item_2.unitPrice,
                            ),
                          ],
                        );

                        final pdfFile = await PdfInvoiceApi.generate(invoice);
                        PdfApi.openFile(pdfFile);
                      }
                      catch(e) {
                        const snackBar = SnackBar(
                          content: Text("Invalid Input"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  },
                  //color: Colors.blueGrey,
                  child: const Text('Generate Bill', style: TextStyle(color: Colors.black, letterSpacing: 1),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  double checkPrice(String product) {
    if(product.contains('Coffee')) {
      return 8;
    }
    if(product.contains('Orange')) {
      return 3;
    }
    if(product.contains('Apple')) {
      return 5;
    }
    if(product.contains('Mango')) {
      return 6;
    }
    if(product.contains('Blue Berries')) {
      return 11;
    }
    return 0;
  }
}
