import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celik Tafsir App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? htmlContent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHtmlContent();
  }

  Future<void> loadHtmlContent() async {
    final storedHtml = await getHtmlFromLocalStorage();
    if (storedHtml != null) {
      setState(() {
        htmlContent = storedHtml;
        isLoading = false;
      });
    } else {
      fetchAndStoreHtml();
    }
  }

  Future<void> fetchAndStoreHtml() async {
    setState(() {
      isLoading = true;
    });
    try {
      const proxyUrl = 'https://quiet-sun-5b87.afwanhaziq987.workers.dev/?url=';
      const url = '${proxyUrl}https://celiktafsir.net';
      final html = await fetchHtml(url);
      final parsedHtml = parseHtml(html);
      await saveHtmlToLocalStorage(parsedHtml);
      setState(() {
        htmlContent = parsedHtml;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  Future<String> fetchHtml(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load HTML');
    }
  }

  String parseHtml(String html) {
    var document = html_parser.parse(html);
    return document.outerHtml;
  }

  Future<void> saveHtmlToLocalStorage(String html) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_html', html);
  }

  Future<String?> getHtmlFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cached_html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Celik Tafsir App'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchAndStoreHtml,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : htmlContent != null
              ? SingleChildScrollView(
                  child: Html(
                    data: htmlContent,
                    onLinkTap: (url, attributes, element) {
                      if (url != null) {
                        launchUrl(Uri.parse(url));
                      }
                    },
                    tagsList: Html.tags,
                    extensions: [
                      TagExtension(
                        tagsToExtend: {"img"},
                        builder: (extensionContext) {
                          final src = extensionContext.attributes["src"];
                          if (src != null) {
                            return GestureDetector(
                              onTap: () => launchUrl(Uri.parse(src)),
                              child: Image.network(src),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                )
              : Center(child: Text('Failed to load content')),
    );
  }
}
