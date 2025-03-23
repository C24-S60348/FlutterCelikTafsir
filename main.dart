import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'html_parser.dart';
import 'local_storage.dart';

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
  final HtmlParser htmlParser = HtmlParser();
  final LocalStorage localStorage = LocalStorage();
  String? htmlContent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHtmlContent();
  }

  Future<void> loadHtmlContent() async {
    final storedHtml = await localStorage.getHtml('cached_html');
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
      final html = await htmlParser.fetchHtml('https://www.celiktafsir.net');
      final parsedHtml = htmlParser.parseHtml(html);
      await localStorage.saveHtml('cached_html', parsedHtml);
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
                    onLinkTap: (url, _, __, ___) {
                      // Handle link tap
                    },
                    onImageTap: (src, _, __, ___) {
                      // Handle image tap
                    },
                  ),
                )
              : Center(child: Text('Failed to load content')),
    );
  }
}
