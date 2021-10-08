import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppView extends StatefulWidget {
  const InAppView({Key? key}) : super(key: key);

  @override
  _InAppViewState createState() => _InAppViewState();
}

class _InAppViewState extends State<InAppView> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        useOnDownloadStart: true,
      ),
      android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
          domStorageEnabled: true,
          databaseEnabled: true,
          clearSessionCache: true,
          thirdPartyCookiesEnabled: true,
          allowFileAccess: true,
          allowContentAccess: true),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  late PullToRefreshController pullToRefreshController;
  late ContextMenu contextMenu;

  @override
  void initState() {
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController!.canGoBack()) {
          await webViewController?.goBack();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest:
                URLRequest(url: Uri.parse('https://home.myallo.io/')),
            initialUserScripts: UnmodifiableListView<UserScript>([]),
            initialOptions: options,
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (controller) {
              webViewController = controller;
              webViewController?.addJavaScriptHandler(
                  handlerName: 'handlerFoo',
                  callback: (args) {
                    // return data to JavaScript side!
                    return {'bar': 'bar_value', 'baz': 'baz_value'};
                  });

              webViewController?.addJavaScriptHandler(
                  handlerName: 'handlerFooWithArgs',
                  callback: (args) {
                    print(args);
                    // it will print: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}]
                  });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var url = navigationAction.request.url;
              if (![
                "http",
                "https",
                "file",
                "chrome",
                "data",
                "javascript",
                "about"
              ].contains(url!.scheme)) {
                String? encodedURL;
                if (url.scheme.contains('whatsapp')) {
                  encodedURL = 'whatsapp://send?' + url.query;
                }
                if (await canLaunch(encodedURL ?? url.toString())) {
                  // Launch the App
                  await launch(encodedURL ?? url.toString());
                  // and cancel the request
                  return NavigationActionPolicy.CANCEL;
                }
              }
              return NavigationActionPolicy.ALLOW;
            },
            androidOnPermissionRequest: (InAppWebViewController controller,
                String origin, List<String> resources) async {
              return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT);
            },
            onLoadStop: (controller, url) async {
              pullToRefreshController.endRefreshing();
            },
            onLoadError: (controller, url, code, message) {
              pullToRefreshController.endRefreshing();
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                pullToRefreshController.endRefreshing();
              }
            },
            gestureRecognizers: Set()
              ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()
                ..onTapDown = (TapDownDetails details) {
                  print(details.globalPosition.dx);
                })),
            onPrint: (controller, url) {
              log(url!.path);
            },
            onConsoleMessage: (controller, consoleMessage) {
              log(consoleMessage.message);
            },
          ),
        ),
      ),
    );
  }
}
