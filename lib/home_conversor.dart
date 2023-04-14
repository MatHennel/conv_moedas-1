import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeConver extends StatefulWidget {
  const HomeConver({Key? key}) : super(key: key);

  @override
  State<HomeConver> createState() => _HomeConverState();
}

class _HomeConverState extends State<HomeConver> {
  final realControl = TextEditingController();
  final dolarControl = TextEditingController();
  final euroControl = TextEditingController();
  final solDoPeruControl = TextEditingController();

  double dolar = 0;
  double euro = 0;
  double solDoPeru = 0;

  @override
  void dispose() {
    realControl.dispose();
    dolarControl.dispose();
    euroControl.dispose();
    solDoPeruControl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Conversor de Moedas'),
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            if (!snapshot.hasError) {
              if (snapshot.connectionState == ConnectionState.done) {
                dolar = double.parse(snapshot.data!['USDBRL']['bid']);
                euro = double.parse(snapshot.data!['EURBRL']['bid']);
                solDoPeru = double.parse(snapshot.data!['PENBRL']['bid']);
                // dolar = snapshot.data!['USD']['buy'];
                // euro = snapshot.data!['EUR']['buy'];
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.monetization_on_outlined,
                        size: 120,
                      ),
                      const SizedBox(height: 20),
                      currencyTextField(
                          'reais ', 'R\$ ', realControl, _convertReal),
                      const SizedBox(height: 20),
                      currencyTextField(
                          'Dolares', 'US\$ ', dolarControl, _convertDolar),
                      const SizedBox(height: 20),
                      currencyTextField(
                          'Euros', '€ ', euroControl, _convertEuro),
                      const SizedBox(height: 20),
                      currencyTextField('Sol do Peru', 'S/ ', solDoPeruControl,
                          _convertSolDoPeru),
                    ],
                  ),
                );
              } else {
                return waitingIndicator();
              }
            } else {
              return waitingIndicator();
            }
          },
        ));
  }

  TextField currencyTextField(String label, String prefixText,
      TextEditingController controller, Function f) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixText: prefixText,
      ),
      onChanged: (value) => f(value),
      keyboardType: TextInputType.number,
    );
  }

  Center waitingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void _convertReal(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double real = double.parse(text);
    dolarControl.text = (real / dolar).toStringAsFixed(2);
    euroControl.text = (real / euro).toStringAsFixed(2);
    solDoPeruControl.text = (real / solDoPeru).toStringAsFixed(2);
  }

  void _convertDolar(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double dolar = double.parse(text);
    realControl.text = (this.dolar * dolar).toStringAsFixed(2);
    solDoPeruControl.text = (this.dolar * dolar / solDoPeru).toStringAsFixed(2);
    euroControl.text = ((this.dolar * dolar) / euro).toStringAsFixed(2);
  }

  void _convertSolDoPeru(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double solDoPeru = double.parse(text);
    realControl.text = (this.solDoPeru * solDoPeru).toStringAsFixed(2);
    euroControl.text = ((this.solDoPeru * solDoPeru) / euro).toStringAsFixed(2);
    dolarControl.text =
        ((this.solDoPeru * solDoPeru) / dolar).toStringAsFixed(2);
  }

  void _convertEuro(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double euro = double.parse(text);
    realControl.text = (this.euro * euro).toStringAsFixed(2);
    solDoPeruControl.text = (this.euro * euro / solDoPeru).toStringAsFixed(2);
    dolarControl.text = ((this.euro * euro) / dolar).toStringAsFixed(2);
  }

  void _clearFields() {
    realControl.clear();
    dolarControl.clear();
    euroControl.clear();
  }
}

Future<Map> getData() async {
  //* ENDEREÇO DA API NOVA
  //* https://docs.awesomeapi.com.br/api-de-moedas

  const requestApi =
      "https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL,PEN-BRL";
  var response = await http.get(Uri.parse(requestApi));
  return jsonDecode(response.body);

  //* json manual para teste em caso de
  //* problema com a conexão http
/*   var response = {
    "USDBRL": {
      "code": "USD",
      "codein": "BRL",
      "name": "Dólar Americano/Real Brasileiro",
      "high": "5.3388",
      "low": "5.2976",
      "varBid": "0.0382",
      "pctChange": "0.72",
      "bid": "5.3348",
      "ask": "5.3363",
      "timestamp": "1679660987",
      "create_date": "2023-03-24 09:29:47"
    },
    "EURBRL": {
      "code": "EUR",
      "codein": "BRL",
      "name": "Euro/Real Brasileiro",
      "high": "5.7429",
      "low": "5.6772",
      "varBid": "-0.0095",
      "pctChange": "-0.17",
      "bid": "5.7256",
      "ask": "5.7293",
      "timestamp": "1679660999",
      "create_date": "2023-03-24 09:29:59"
    }

    <USD-XCD>Dólar Americano/Dólar do Caribe Oriental</USD-XCD>
    <USD-KRW>Dólar Americano/Won Sul-Coreano</USD-KRW>
  };

  return jsonDecode(jsonEncode(response));
 */
}
