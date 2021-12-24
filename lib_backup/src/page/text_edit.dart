import 'dart:io';

// import 'package:extended_text_field/extended_text_field.dart';
import 'package:file_manager/src/io/src/file.dart';
import 'package:flutter/material.dart' hide TextField, TextEditingController;
import 'package:flutter/material.dart';

import '../io/src/file.dart';
// import 'package:flutter_toolkit/widgets/text_field/editable_text.dart';
// import 'package:flutter_toolkit/widgets/text_field/custom_editable_text.dart';
// import 'package:flutter_toolkit/widgets/text_field/text_field.dart';
// class NiTextEditingController extends TextEditingController {
//   /// Creates a controller for an editable text field.
//   ///
//   /// This constructor treats a null [text] argument as if it were the empty
//   /// string.
//   NiTextEditingController({ String text })
//     : super(text : text);

//   /// Creates a controller for an editable text field from an initial [TextEditingValue].
//   ///
//   /// This constructor treats a null [value] argument as if it were
//   /// [TextEditingValue.empty].
//   // NiTextEditingController.fromValue(TextEditingValue value)
//   //   : super(value ?? TextEditingValue.empty);

//   /// The current string the user is editing.
//   String get text => value.text;
//   /// Setting this will notify all the listeners of this [NiTextEditingController]
//   /// that they need to update (it calls [notifyListeners]). For this reason,
//   /// this value should only be set between frames, e.g. in response to user
//   /// actions, not during the build, layout, or paint phases.
//   ///
//   /// This property can be set from a listener added to this
//   /// [NiTextEditingController]; however, one should not also set [selection]
//   /// in a separate statement. To change both the [text] and the [selection]
//   /// change the controller's [value].
//   set text(String newText) {
//     value = value.copyWith(
//       text: newText,
//       selection: const TextSelection.collapsed(offset: -1),
//       composing: TextRange.empty,
//     );
//   }

//   /// Builds [TextSpan] from current editing value.
//   ///
//   /// By default makes text in composing range appear as underlined.
//   /// Descendants can override this method to customize appearance of text.
//   TextSpan buildTextSpan({TextStyle style , bool withComposing}) {
//     if (!value.composing.isValid || !withComposing) {
//       return TextSpan(style: style, text: text);
//     }
//     final TextStyle composingStyle = style.merge(
//       const TextStyle(decoration: TextDecoration.underline),
//     );
//     return TextSpan(
//       style: style,
//       children: <TextSpan>[
//         TextSpan(text: value.composing.textBefore(value.text)),
//         TextSpan(
//           style: composingStyle,
//           text: value.composing.textInside(value.text),
//         ),
//         TextSpan(text: value.composing.textAfter(value.text)),
//     ]);
//   }

//   /// The currently selected [text].
//   ///
//   /// If the selection is collapsed, then this property gives the offset of the
//   /// cursor within the text.
//   TextSelection get selection => value.selection;
//   /// Setting this will notify all the listeners of this [NiTextEditingController]
//   /// that they need to update (it calls [notifyListeners]). For this reason,
//   /// this value should only be set between frames, e.g. in response to user
//   /// actions, not during the build, layout, or paint phases.
//   ///
//   /// This property can be set from a listener added to this
//   /// [NiTextEditingController]; however, one should not also set [text]
//   /// in a separate statement. To change both the [text] and the [selection]
//   /// change the controller's [value].
//   set selection(TextSelection newSelection) {
//     if (newSelection.start > text.length || newSelection.end > text.length)
//       throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('invalid text selection: $newSelection')]);
//     value = value.copyWith(selection: newSelection, composing: TextRange.empty);
//   }

//   /// Set the [value] to empty.
//   ///
//   /// After calling this function, [text] will be the empty string and the
//   /// selection will be invalid.
//   ///
//   /// Calling this will notify all the listeners of this [NiTextEditingController]
//   /// that they need to update (it calls [notifyListeners]). For this reason,
//   /// this method should only be called between frames, e.g. in response to user
//   /// actions, not during the build, layout, or paint phases.
//   void clear() {
//     value = TextEditingValue.empty;
//   }

//   /// Set the composing region to an empty range.
//   ///
//   /// The composing region is the range of text that is still being composed.
//   /// Calling this function indicates that the user is done composing that
//   /// region.
//   ///
//   /// Calling this will notify all the listeners of this [NiTextEditingController]
//   /// that they need to update (it calls [notifyListeners]). For this reason,
//   /// this method should only be called between frames, e.g. in response to user
//   /// actions, not during the build, layout, or paint phases.
//   void clearComposing() {
//     value = value.copyWith(composing: TextRange.empty);
//   }
// }

// // class CustomNiTextEditingController extends NiTextEditingController {
// //   /// Creates a controller for an editable text field.
// //   ///
// //   /// This constructor treats a null [text] argument as if it were the empty
// //   /// string.

// //   CustomNiTextEditingController({String text}) : super(text: text);

// //   /// Creates a controller for an editable text field from an initial [TextEditingValue].
// //   ///
// //   /// This constructor treats a null [value] argument as if it were
// //   /// [TextEditingValue.empty].

// //   /// The current string the user is editing.
// //   ///
// //   @override
// //   String get text => value.text;

// //   /// Setting this will notify all the listeners of this [NiTextEditingController]
// //   /// that they need to update (it calls [notifyListeners]). For this reason,
// //   /// this value should only be set between frames, e.g. in response to user
// //   /// actions, not during the build, layout, or paint phases.
// //   ///
// //   /// This property can be set from a listener added to this
// //   /// [NiTextEditingController]; however, one should not also set [selection]
// //   /// in a separate statement. To change both the [text] and the [selection]
// //   /// change the controller's [value].
// //   set text(String newText) {
// //     value = value.copyWith(
// //       text: newText,
// //       selection: const TextSelection.collapsed(offset: -1),
// //       composing: TextRange.empty,
// //     );
// //   }

// //   /// Builds [TextSpan] from current editing value.
// //   ///
// //   /// By default makes text in composing range appear as underlined.
// //   /// Descendants can override this method to customize appearance of text.
// //   @override
// //   TextSpan buildTextSpan({TextStyle style, bool withComposing}) {
// //     if (!value.composing.isValid || !withComposing) {
// //       return TextSpan(style: style, text: text);
// //     }
// //     final TextStyle composingStyle = style.merge(
// //       const TextStyle(decoration: TextDecoration.underline),
// //     );
// //     // final SyntaxHighlighterStyle style =
// //     // Theme.of(context).brightness == Brightness.dark
// //     //     ? SyntaxHighlighterStyle.darkThemeStyle()
// //     //     : SyntaxHighlighterStyle.lightThemeStyle();
// //     return TextSpan(style: style, children: <TextSpan>[
// //       // TextSpan(text: value.composing.textBefore(value.text)),
// //       DartSyntaxHighlighter(SyntaxHighlighterStyle.darkThemeStyle())
// //           .format(value.composing.textBefore(value.text)),
// //       TextSpan(
// //         style: composingStyle,
// //         text: value.composing.textInside(value.text),
// //       ),

// //       DartSyntaxHighlighter(SyntaxHighlighterStyle.darkThemeStyle())
// //           .format(value.composing.textAfter(value.text)),
// //     ]);
// //   }
// // }

class TextEdit extends StatefulWidget {
  const TextEdit({Key key, @required this.fileNode}) : super(key: key);
  final AbstractNiFile fileNode;

  @override
  _TextEditState createState() => _TextEditState();
}

class _TextEditState extends State<TextEdit> with TickerProviderStateMixin {
  AnimationController animationController;
  List<String> fileText;
  TextEditingController _textEditingController;
  ScrollController _scrollController;
  ScrollController _scrollController0;
  int maxLength = 0;

  @override
  void initState() {
    super.initState();
    initText();
  }

  void initText() {
    _scrollController = ScrollController()
      ..addListener(() {
        _scrollController0.jumpTo(_scrollController.offset);
      });
    _scrollController0 = ScrollController();
    fileText = File(widget.fileNode.path).readAsLinesSync();
    maxLength = fileText.length;
    _textEditingController = TextEditingController(text: fileText.join('\n'));
    //_NiTextEditingController.selection = TextSelection(baseOffset: 0,extentOffset: 0,isDirectional: true);
    print(maxLength);
    print('maxstr');
    setState(() {});
  }

  double onVerticalDragStart = 0.0;
  double onHorizontalDragStart;
  Matrix4 matrix4;
  double current = 0.0;
  double _fontSize = 16;
  double _tmpfontSize = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileNode.nodeName,
          style: const TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                File(widget.fileNode.path)
                    .writeAsStringSync(_textEditingController.text);
              }),
          IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                // showCustomDialog2<void>(
                //   isPadding: false,
                //   height: 600,
                //   child: Niterm(
                //     showOnDialog: true,
                //     script:
                //         '/data/data/com.termux/files/usr/bin/dart ${widget.fileNode.path}',
                //   ),
                // );
              })
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: GestureDetector(
          onScaleStart: (ScaleStartDetails details) {
            onVerticalDragStart =
                details.localFocalPoint.dy + _scrollController.offset;
            // _tmpScale = _scale;
            _tmpfontSize = _fontSize;
            // print(onVerticalDragStart);
          },
          // onPanUpdate: ,
          onScaleUpdate: (ScaleUpdateDetails details) {
            // print(_scrollController.offset);
            print(details.localFocalPoint);
            if (details.scale == 1.0) {
              // _scrollController
              //     .jumpTo(onVerticalDragStart - details.localFocalPoint.dy);
            } else {
              //_scale = _tmpScale * details.scale;
              _fontSize = _tmpfontSize * details.scale;
            }

            setState(() {});
          },
          onScaleEnd: (details) {
            print(details.velocity.pixelsPerSecond.dx);
            print(details.velocity.pixelsPerSecond.dy);
            print(details.velocity.pixelsPerSecond.distance);
            return;
            final Tolerance tolerance = Tolerance(
              velocity: 1.0 /
                  (0.050 *
                      WidgetsBinding.instance.window
                          .devicePixelRatio), // logical pixels per second
              distance: 1.0 /
                  WidgetsBinding
                      .instance.window.devicePixelRatio, // logical pixels
            );
            final double start = _scrollController.offset;
            final ClampingScrollSimulation clampingScrollSimulation =
                ClampingScrollSimulation(
              position: start,
              velocity: -details.velocity.pixelsPerSecond.dy,
              tolerance: tolerance,
            );
            animationController = AnimationController(
              vsync: this,
              value: 0,
              lowerBound: double.negativeInfinity,
              upperBound: double.infinity,
            );

            animationController.reset();
            animationController.addListener(() {
              print(animationController.value);
              // _scrollController.jumpTo(animationController.value);
            });
            animationController.animateWith(clampingScrollSimulation);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 25,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _scrollController0,
                  itemCount: fileText.length,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (BuildContext context, int index) {
                    return Material(
                      color: Colors.grey[200],
                      child: Text(
                        '$index',
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 2000,
                child: Scrollbar(
                  child: TextField(
                    scrollController: _scrollController,
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    // onTap: null,
                    onChanged: (String a) {},
                    style: TextStyle(fontSize: _fontSize),
                    keyboardType: TextInputType.multiline,
                    controller: _textEditingController,
                    maxLines: 100,
                    //expands: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      fillColor: Colors.white10,
                      filled: true,
                      contentPadding: EdgeInsets.only(bottom: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
