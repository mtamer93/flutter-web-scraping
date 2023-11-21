import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:web_scraping_app/kitap.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Material App', home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Kitap> kitaplar = [];
  var url = Uri.parse(
      'https://www.kitapyurdu.com/index.php?route=product/category&filter_category_all=true&path=1_737&sort=publish_date&order=DESC');
  bool isLoading = false;

  Future getData() async {
    setState(() {
      isLoading = true;
    });
    var res = await http.get(url);
    final body = res.body;
    final document = parser.parse(body);
    /*
    resim => element
          .children[2].children[0].children[0].children[0].attributes['src']
    
    kitap adı => element.children[3].text
    kitap yayınevi => element.children[4].text
    kitap yazarı => element.children[5].text
    kitap fiyatı => element.children[8].children[0].text
    */
    var response = document
        .getElementsByClassName('product-grid')[0]
        .getElementsByClassName('product-cr')
        .forEach((element) {
      setState(() {
        kitaplar.add(
          Kitap(
            image: element.children[2].children[0].children[0].children[0]
                .attributes['src']
                .toString(),
            kitapAdi: element.children[3].text.toString(),
            yayinEvi: element.children[4].text.toString(),
            yazar: element.children[5].text.toString(),
            fiyat: element.children[8].children[0].text.toString(),
          ),
        );
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KitapYurdu Scraping'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10),
                itemCount: kitaplar.length,
                itemBuilder: (context, index) => Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 6,
                  color: Colors.black87,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(kitaplar[index].image),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                index.toString(),
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Kitap İsmi: ${kitaplar[index].kitapAdi}',
                          style: _style,
                        ),
                        Text(
                          'Kitap YayınEvi: ${kitaplar[index].yayinEvi}',
                          style: _style,
                        ),
                        Text(
                          'Kitap Yazarı: ${kitaplar[index].yazar}',
                          style: _style,
                        ),
                        Text(
                          'Kitap Fiyatı: ${kitaplar[index].fiyat} TL',
                          style: _style,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

TextStyle _style = TextStyle(color: Colors.white, fontSize: 15);
