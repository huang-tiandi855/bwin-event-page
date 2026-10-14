import 'package:flutter/material.dart';

//ignore: must_be_immutable
class ExpandableText extends StatefulWidget {
  final String? text;
  final int maxLines;
  final TextStyle style;
  final String? expandBtnText;
  final String? shrinkBtnText;
  late bool expand;

  ExpandableText(
      {Key? key,
      this.text,
      required this.maxLines,
      required this.style,
      required this.expand,
      this.expandBtnText,
      this.shrinkBtnText})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ExpandableTextState();
  }
}

class _ExpandableTextState extends State<ExpandableText> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      final span = TextSpan(text: widget.text ?? '', style: widget.style);
      final tp = TextPainter(
          text: span,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr);
      tp.layout(maxWidth: size.maxWidth);

      if (tp.didExceedMaxLines) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.expand
                ? Text(widget.text ?? '', style: widget.style)
                : Text(widget.text ?? '',
                    maxLines: widget.maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: widget.style),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  widget.expand = !widget.expand;
                });
              },
              child: Container(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                    widget.expand
                        ? (widget.shrinkBtnText ?? '收起')
                        : (widget.expandBtnText ?? '全文'),
                    style: TextStyle(
                        fontSize: widget.style.fontSize,
                        color: const Color.fromRGBO(176, 159, 217, 1))),
              ),
            ),
          ],
        );
      } else {
        return Text(widget.text ?? '', style: widget.style);
      }
    });
  }
}
