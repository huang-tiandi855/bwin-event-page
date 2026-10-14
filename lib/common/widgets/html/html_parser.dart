import 'package:cached_network_image/cached_network_image.dart';
import 'package:comics_app/pages/image/network/image_cache_manager.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

import 'html_pro_parser.dart';

import 'package:comics_app/common/utils/logger.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class HtmlParser {
  HtmlParser({
    required this.width,
    required this.onLinkTap,
    this.imgLinkTap,
    this.renderNewlines = false,
  });

  final double width;
  final Function(String) onLinkTap;
  final Function(String)? imgLinkTap;
  final bool renderNewlines;

  static const _supportedElements = [
    "a",
    "abbr",
    "acronym",
    "address",
    "article",
    "aside",
    "b",
    "bdi",
    "bdo",
    "big",
    "blockquote",
    "body",
    "br",
    "caption",
    "cite",
    "center",
    "code",
    "data",
    "dd",
    "del",
    "dfn",
    "div",
    "dl",
    "dt",
    "em",
    "figcaption",
    "figure",
    "footer",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "header",
    "hr",
    "i",
    "img",
    "ins",
    "kbd",
    "li",
    "main",
    "mark",
    "nav",
    "noscript",
    "ol", //partial
    "p",
    "pre",
    "q",
    "rp",
    "rt",
    "ruby",
    "s",
    "samp",
    "section",
    "small",
    "span",
    "strike",
    "strong",
    "table",
    "tbody",
    "td",
    "template",
    "tfoot",
    "th",
    "thead",
    "time",
    "tr",
    "tt",
    "u",
    "ul", //partial
    "var",
    "font"
  ];

  ///Parses an html string and returns a list of widgets that represent the body of your html document.
  List<Widget> parse(String data) {
    List<Widget> widgetList = [];

    if (renderNewlines) {
      l.d("Before: $data");
      data = data.replaceAll("\n", "<br />");
      l.d("After: $data");
    }
    dom.Document document = parser.parse(data);
    widgetList.add(_parseNode(document.body as dom.Node));
    return widgetList;
  }

  Widget _parseNode(dom.Node node) {
    if (node is dom.Element) {
      l.d("Found ${node.localName}");
      if (!_supportedElements.contains(node.localName)) {
        return Container();
      }
      l.d((node.localName).toString());
      switch (node.localName) {
        case "a":
          return GestureDetector(
              child: DefaultTextStyle.merge(
                child: Wrap(
                  children: _parseNodeList(node.nodes),
                ),
                style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blueAccent,
                    decorationColor: Colors.blueAccent),
              ),
              onTap: () {
                if (node.attributes.containsKey('href')) {
                  String? url = node.attributes['href'];
                  onLinkTap(url ?? "");
                }
              });
        case "abbr":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            ),
          );
        case "acronym":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            ),
          );
        case "address":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
        case "article":
          return SizedBox(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "aside":
          return SizedBox(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "b":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          );
        case "bdi":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "bdo":
          if (node.attributes["dir"] != null) {
            return Directionality(
              textDirection: node.attributes["dir"] == "rtl"
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Wrap(
                children: _parseNodeList(node.nodes),
              ),
            );
          }
          //Direction attribute is required, just render the text normally now.
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "big":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontSize: 20.0,
            ),
          );
        case "blockquote":
          return Padding(
            padding: const EdgeInsets.fromLTRB(40.0, 14.0, 40.0, 14.0),
            child: SizedBox(
              width: width,
              child: Wrap(
                children: _parseNodeList(node.nodes),
              ),
            ),
          );
        case "body":
          return SizedBox(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "br":
          if (_isNotFirstBreakTag(node)) {
            return const Text("\n");
          }
          return Container(width: width);
        case "caption":
          return SizedBox(
            width: width,
            child: Wrap(
              alignment: WrapAlignment.center,
              children: _parseNodeList(node.nodes),
            ),
          );
        case "center":
          return SizedBox(
              width: width,
              child: Wrap(
                alignment: WrapAlignment.center,
                children: _parseNodeList(node.nodes),
              ));
        case "cite":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
        case "code":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
          );
        case "data":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "dd":
          return Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: SizedBox(
                width: width,
                child: Wrap(
                  children: _parseNodeList(node.nodes),
                ),
              ));
        case "del":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
            ),
          );
        case "dfn":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
        case "div":
          return SizedBox(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "dl":
          return Padding(
              padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _parseNodeList(node.nodes),
              ));
        case "dt":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "em":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
        case "figcaption":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "figure":
          return Padding(
              padding: const EdgeInsets.fromLTRB(40.0, 14.0, 40.0, 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _parseNodeList(node.nodes),
              ));
        case "footer":
          return SizedBox(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "h1":
          return DefaultTextStyle.merge(
            child: SizedBox(
              width: width,
              child: Wrap(
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          );
        case "h2":
          return DefaultTextStyle.merge(
            child: SizedBox(
              width: width,
              child: Wrap(
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontSize: 21.0,
              fontWeight: FontWeight.bold,
            ),
          );
        case "h3":
          return DefaultTextStyle.merge(
            child: SizedBox(
              width: width,
              child: Wrap(
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          );
        case "h4":
          return DefaultTextStyle.merge(
            child: SizedBox(
              width: width,
              child: Wrap(
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          );
        case "h5":
          return DefaultTextStyle.merge(
            child: SizedBox(
              width: width,
              child: Wrap(
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          );
        case "h6":
          return DefaultTextStyle.merge(
            child: SizedBox(
              width: width,
              child: Wrap(
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
            ),
          );
        case "header":
          return SizedBox(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "hr":
          return Padding(
            padding: const EdgeInsets.only(top: 7.0, bottom: 7.0),
            child: Container(
              height: 1,
              decoration: const BoxDecoration(color: Colors.white),
            ),
          );
        case "i":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
        case "img":
          if (node.attributes['src'] != null) {
            return GestureDetector(
              onTap: () => imgLinkTap?.call(node.attributes['src'] ?? ""),
              child: CachedNetworkImage(
                cacheManager: ImgCacheMgr(),
                imageUrl: getPath(node.attributes['src'] ?? ""),
                fit: BoxFit.contain,
                width: ScreenUtil().screenWidth - 32,
                placeholder: (context, url) {
                  return SizedBox(
                      width: ScreenUtil().screenWidth - 32, height: 200);
                },
              ),
            );
          } else if (node.attributes['alt'] != null) {
            //Temp fix for https://github.com/flutter/flutter/issues/736
            if (node.attributes['alt']?.endsWith(" ") == true) {
              return Container(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: Text(node.attributes['alt'] ?? ""));
            } else {
              return Text(node.attributes['alt'] ?? "");
            }
          }
          return Container();
        case "ins":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.underline,
            ),
          );
        case "kbd":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
          );
        case "li":
          String? type =
              node.parent?.localName; // Parent type; usually ol or ul
          const EdgeInsets markPadding = EdgeInsets.symmetric(horizontal: 4.0);
          Widget mark;
          switch (type) {
            case "ul":
              mark = Container(padding: markPadding, child: const Text('•'));
              break;
            case "ol":
              int index = (node.parent?.children.indexOf(node) ?? 0) + 1;
              mark = Container(padding: markPadding, child: Text("$index."));
              break;
            default: //Fallback to middle dot
              mark = const SizedBox(width: 0.0, height: 0.0);
              break;
          }
          return SizedBox(
            width: width,
            child: Wrap(
              children: <Widget>[
                mark,
                Wrap(children: _parseNodeList(node.nodes))
              ],
            ),
          );
        case "main":
          return SizedBox(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "mark":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: TextStyle(
              color: Colors.black,
              background: _getPaint(Colors.yellow),
            ),
          );
        case "nav":
          return SizedBox(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "noscript":
          return SizedBox(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "ol":
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _parseNodeList(node.nodes),
          );
        case "p":
          return DefaultTextStyle.merge(
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
              child: Container(
                alignment:
                    HtmlProParser.alignment(node.attributes["style"] ?? ""),
                width: width,
                child: Wrap(
                  alignment: HtmlProParser.wrapAlignment(
                      node.attributes["style"] ?? ""),
                  children: _parseNodeList(node.nodes),
                ),
              ),
            ),
            style: TextStyle(
                height:
                    HtmlProParser.lineHeight(node.attributes["style"] ?? "")),
          );
        case "font":
          Color? textColor;
          String colorStr = node.attributes["color"] ?? "";
          if (colorStr.length == 7) {
            textColor = HexColor(colorStr);
          }
          l.d('颜色值为 $colorStr');
          double fontSize = 14;
          try {
            //字体大小和h5那边约定
            Map<String, double> fontSizeMap = {
              "1": 14,
              "2": 17,
              "3": 20,
              "4": 23,
              "5": 26,
              "6": 29,
              "7": 32
            };
            if (node.attributes["size"] is String) {
              fontSize = fontSizeMap[node.attributes["size"]] ?? 14;
            }
          } catch (e) {
            // l.d('fontSize ' + e);
          }
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              backgroundColor:
                  HtmlProParser.spanBg(node.attributes["style"] ?? ""),
            ),
          );
        case "pre":
          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: DefaultTextStyle.merge(
              child: Text(node.innerHtml),
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
            ),
          );
        case "q":
          List<Widget> children = [];
          children.add(const Text("\""));
          children.addAll(_parseNodeList(node.nodes));
          children.add(const Text("\""));
          return DefaultTextStyle.merge(
            child: Wrap(
              children: children,
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
        case "rp":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "rt":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "ruby":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "s":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
            ),
          );
        case "samp":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
          );
        case "section":
          return SizedBox(
            width: width,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "small":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontSize: 10.0,
            ),
          );
        case "span":
          return DefaultTextStyle.merge(
            style: TextStyle(
                backgroundColor:
                    HtmlProParser.spanBg(node.attributes['style'])),
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "strike":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
            ),
          );
        case "strong":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          );
        case "table":
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _parseNodeList(node.nodes),
          );
        case "tbody":
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _parseNodeList(node.nodes),
          );
        case "td":
          int colspan = 1;
          if (node.attributes['colspan'] != null) {
            colspan = int.tryParse(node.attributes['colspan'] ?? "1") ?? 1;
          }
          return Expanded(
            flex: colspan,
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
          );
        case "template":
          //Not usually displayed in HTML
          return Container();
        case "tfoot":
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _parseNodeList(node.nodes),
          );
        case "th":
          int colspan = 1;
          if (node.attributes['colspan'] != null) {
            colspan = int.tryParse(node.attributes['colspan'] ?? "1") ?? 1;
          }
          return DefaultTextStyle.merge(
            child: Expanded(
              flex: colspan,
              child: Wrap(
                alignment: WrapAlignment.center,
                children: _parseNodeList(node.nodes),
              ),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          );
        case "thead":
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _parseNodeList(node.nodes),
          );
        case "time":
          return Wrap(
            children: _parseNodeList(node.nodes),
          );
        case "tr":
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _parseNodeList(node.nodes),
          );
        case "tt":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
          );
        case "u":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              decoration: TextDecoration.underline,
            ),
          );
        case "ul":
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _parseNodeList(node.nodes),
          );
        case "var":
          return DefaultTextStyle.merge(
            child: Wrap(
              children: _parseNodeList(node.nodes),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          );
      }
    } else if (node is dom.Text) {
      //We don't need to worry about rendering extra whitespace
      if (node.text.trim() == "" && !node.text.contains(" ")) {
        return const Wrap();
      }
      if (node.text.trim() == "" && node.text.contains(" ")) {
        node.text = " ";
      }
      l.d("Plain Text Node: '${trimStringHtml(node.text)}'");
      String finalText = trimStringHtml(node.text);
      //Temp fix for https://github.com/flutter/flutter/issues/736
      if (finalText.endsWith(" ")) {
        return Container(
            padding: const EdgeInsets.only(right: 2.0), child: Text(finalText));
      } else {
        return Text(finalText);
      }
    }
    return const Wrap();
  }

  List<Widget> _parseNodeList(List<dom.Node> nodeList) {
    return nodeList.map((node) {
      return _parseNode(node);
    }).toList();
  }

  Paint _getPaint(Color color) {
    Paint paint = Paint();
    paint.color = color;
    return paint;
  }

  String trimStringHtml(String stringToTrim) {
    stringToTrim = stringToTrim.replaceAll("\n", "");
    while (stringToTrim.contains("  ")) {
      stringToTrim = stringToTrim.replaceAll("  ", " ");
    }
    return stringToTrim;
  }

  bool _isNotFirstBreakTag(dom.Node? node) {
    int index = node?.parentNode?.nodes.indexOf(node) ?? 0;
    if (index == 0) {
      if (node?.parentNode == null) {
        return false;
      }
      return _isNotFirstBreakTag(node?.parentNode);
    } else if (node?.parentNode?.nodes[index - 1] is dom.Element) {
      if ((node?.parentNode?.nodes[index - 1] as dom.Element).localName ==
          "br") {
        return true;
      }
      return false;
    } else if (node?.parentNode?.nodes[index - 1] is dom.Text) {
      if ((node?.parentNode?.nodes[index - 1] as dom.Text).text.trim() == "") {
        return _isNotFirstBreakTag(node?.parentNode?.nodes[index - 1]);
      } else {
        return false;
      }
    }
    return false;
  }
}
