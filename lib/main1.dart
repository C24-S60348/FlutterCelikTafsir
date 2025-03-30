import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../local_storage.dart';
import '../html_parser.dart' as custom_html_parser;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celik Tafsir App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final custom_html_parser.HtmlParser htmlParser =
      custom_html_parser.HtmlParser();
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
      const proxyUrl = 'https://quiet-sun-5b87.afwanhaziq987.workers.dev/?url=';
      const url = '${proxyUrl}https://celiktafsir.net';
      final html = await htmlParser.fetchHtml(url);
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
        title: const Text('Celik Tafsir App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAndStoreHtml,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
              : const Center(child: Text('Failed to load content')),
    );
  }
}
