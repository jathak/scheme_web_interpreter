import 'package:cs61a_scheme/cs61a_scheme_web.dart';
import 'package:cs61a_scheme_impl/impl.dart' show StaffProjectImplementation;
import 'dart:html';
import 'dart:async';
import 'dart:js';
import 'dart:convert';

var input = querySelector('#input');
var log = querySelector('#output');
var prompt = querySelector('#prompt');
var loading = querySelector('#loading');

var hljs = context['hljs'];

highlight(String code) {
  code = code.toString();

  var result = hljs.callMethod('highlight', ['scheme', code, true]);
  return result['value'];
}

var validator = new NodeValidatorBuilder.common()..allowNavigation(new OpenUriPolicy());

class OpenUriPolicy implements UriPolicy {
  @override
  bool allowsUri(String url) => true;
}

String DEFAULT_PROMPT = "<span class='green'>scm></span> ";
String ALT_PROMPT = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

List<String> history = [];
int historyIndex = -1;
Interpreter interpreter = new Interpreter(new StaffProjectImplementation());

Function output;
Function outputLine = (a, [b]) => output(a + '\n', b);

saveHistory() {
  if (history.length == 0) return;
  String save = "";
  for (int i = 0; i < history.length && i < 100; i++) {
    save += "\n" + history[i];
  }
  save = save.substring(1);
  window.localStorage['#history'] = save;
}

waitToFocus() {
  new Future.delayed(const Duration(milliseconds: 500), () {
    if (document.activeElement == input) return;
    if (window.getSelection().rangeCount == 0) {
      input.focus();
      return;
    }
    var r = window.getSelection().getRangeAt(0);
    if (r.startOffset == r.endOffset)
      input.focus();
    else
      waitToFocus();
  });
}

listenForCacheUpdate() {
  /*var refresh = ([e]) {
    if (userInteraction) {
      outputLine("A new update is available. Refresh the page to use the latest version.");
    } else {
      outputLine("A new update is available. Refreshing...");
      window.location.reload();
    }
  };
  window.applicationCache.onUpdateReady.listen(refresh);
  if (window.applicationCache.status == ApplicationCache.UPDATEREADY) {
    refresh();
  }*/
}

bool userInteraction = false;

main() async {
  interpreter.logger = (Expression expr, bool newline) {
    output(expr.toString() + (newline ? "\n" : ""), false);
  };
  updateInput("");
  listenForCacheUpdate();
  if (window.localStorage['#history'] != null) {
    for (String hist in window.localStorage['#history'].split('\n')) {
      if (history.length > 0 && history.last == hist) continue;
      history.add(hist);
    }
  }
  listenForResize();
  input.onBlur.listen((e) => waitToFocus());
  querySelectorAll("*").onClick.listen((e) => waitToFocus());
  log.onSelectStart.listen((e) {
    waitToFocus();
  });
  var crossWindowCallback = (msg, isError) => null;
  output = (String msg, [bool isError = false]) {
    if (isError) {
      log.appendHtml("<span class='red'>${HTML_ESCAPE.convert(msg)}</span>");
    } else {
      log.appendHtml(highlight(msg));
    }
    log.scrollTop = log.scrollHeight;
    crossWindowCallback(msg, isError);
  };
  String url = "${Uri.base}".replaceAll("#?", "?");
  var params = Uri.parse(url).queryParameters;
  //startInterpreterExtra(output, querySelector("#diagram"), querySelector("#turtle"),
  //    querySelector("#buttons"), params);
  
  interpreter.importLibrary(new WebLibrary());
  interpreter.importLibrary(new TurtleLibrary());
  interpreter.importLibrary(new ExtraLibrary());
  //if (!onEmbeddedPage()) input.focus();
  window.onKeyDown.listen((e) {
    if (e.keyCode == KeyCode.UP) {
      historyUp();
    } else if (e.keyCode == KeyCode.DOWN) {
      historyDown();
    }
  });
  int pendingCount = 0;
  var pendingResolver = () {
    if (pendingCount > 0) pendingCount--;
    if (pendingCount <= 0) loading.style.opacity = "0";
  };
  inputLine(String line, [bool fromPaste = false]) async {
    if (history.length == 0 || history[0] != line) {
      if (line.trim().length > 0) history.insert(0, line);
    }
    historyIndex = -1;
    saveHistory();
    String highlighted = highlight(line);
    String text = prompt.innerHtml + highlighted;
    log.appendHtml("$text\n");
    log.scrollTop = log.scrollHeight;
    loading.style.opacity = "1";
    pendingCount++;
    lastOpenParenCount = 0;
    currentOpenParenCount = 0;
    updateStatus("");
    await window.animationFrame;
    if (!fromPaste) {
      await window.animationFrame;
      await window.animationFrame;
    }
    var schemeResult = await inputCode(line, true);
    pendingCount--;
    if (pendingCount <= 0) {
      loading.style.opacity = "0";
    }
    if (schemeResult != true) {
      prompt.innerHtml = ALT_PROMPT;
      lastOpenParenCount = schemeResult;
      hasIncompleteLines = true;
      if (input.innerHtml == "") updateInput(" " * 2 * schemeResult);
    } else {
      hasIncompleteLines = false;
      prompt.innerHtml = DEFAULT_PROMPT;
      if (input.innerHtml == "") updateInput("");
    }
  }
  input.onKeyPress.listen((e) {
    userInteraction = true;
    if (e.keyCode != 13) {
      delay(0, styleInput);
      return;
    }
    String result = input.text;
    if (e.shiftKey) {
      result += ")" * currentOpenParenCount;
    }
    input.innerHtml = "";
    delay(50, () async {
      input.innerHtml = "";
      await inputLine(result);
    });
  });
  void Function(KeyboardEvent) inputListener = (e) {
    if (e.keyCode == KeyCode.BACKSPACE) {
      delay(0, styleInput);
    }
  };
  input.onKeyDown.listen(inputListener);
  input.onKeyUp.listen(inputListener);
  input.onPaste.listen((e) {
    delay(5, () async {
      String result = input.text;
      List<String> lines = result.split("\n");
      if (lines.length > 1) {
        for (int i = 0; i < lines.length - 1; i++) {
          input.innerHtml = lines[i + 1];
          await inputLine(lines[i], true);
        }
        updateInput(lines.last);
      } else
        updateInput(result);
    });
  });
  querySelector("#main").onTouchStart.listen((TouchEvent event) {
    //event.preventDefault();
    if (event.touches.length > 0) {
      touchX = event.touches[0].page.x;
      touchY = event.touches[0].page.y;
      //output("start $touchX, $touchY");
    }
  });
  querySelector("#main").onTouchMove.listen((TouchEvent event) {
    //event.preventDefault();
    if (event.touches.length > 0) {
      var touchEX = event.touches[0].page.x;
      var touchEY = event.touches[0].page.y;
      if (touchY != null && touchEY < touchY - 130) {
        historyUp();
        touchY = null;
      } else if (touchX != null && (touchEX - touchX).abs() > 130) {
        historyDown();
        touchX = null;
      }
    }
  });
}

List<Expression> tokens = [];

inputCode(String code, bool _) {
  tokens.addAll(tokenizeLine(code));
  List<Expression> lastTokens;
  while (tokens.isNotEmpty) {
    try {
      lastTokens = tokens.toList();
      Expression expr = schemeRead(tokens, interpreter.implementation);
      Expression result = schemeEval(expr, interpreter.globalEnv);
      if (result != undefined) outputLine(result.toString(), false);
    } on SchemeException catch (e) {
      outputLine(e.toString(), true);
    } on Exception {
      tokens = lastTokens;
      return 0;
    }
  }
  return true;
}

int lastOpenParenCount = 0;
int currentOpenParenCount = 0;

historyUp() {
  if (historyIndex < history.length - 1) {
    historyIndex++;
  }
  if (historyIndex >= 0) {
    updateInput(history[historyIndex]);
  }
}

historyDown() {
  if (historyIndex >= 0) {
    historyIndex--;
    String text = "";
    if (historyIndex >= 0) text = history[historyIndex];
    updateInput(text);
  } else if (historyIndex == -1) {
    input.innerHtml = "";
  }
}

var touchX = null;
var touchY = null;

updateInput(String text) {
  input.innerHtml = highlight(text);
  delay(5, () {
    var s = window.getSelection();
    var r = new Range();
    r.selectNodeContents(input);
    r.collapse(false);
    s.removeAllRanges();
    s.addRange(r);
    updateStatus(text);
  });
}

bool hasIncompleteLines = false;

updateStatus(text) {
  String status = "";
  int count = lastOpenParenCount;
  var tokens;
  try {
    tokens = tokenizeLine(text);
  } catch (e) {
    return;
  }
  for (var token in tokens) {
    if (token == '(') count++;
    if (token == ')') count--;
  }
  var parenStatus = querySelector("#status");
  String plural = count == 1 || count == -1 ? "" : "s";
  status = (count > 0 ? "    $count open paren$plural" : "") + status;
  currentOpenParenCount = count;
  if (count < 0) {
    count = -count;
    status = "$count extra closed paren$plural";
    status = "    <span class='red'>$status</span>";
  }
  if (hasIncompleteLines) {
    status = "<span id='cancel'>Cancel Input</span>" + status;
  }
  parenStatus.innerHtml = "";
  parenStatus.appendHtml(status, validator: validator);
  if (hasIncompleteLines) {
    querySelector('#cancel').onClick.listen((e) {
      hasIncompleteLines = false;
      prompt.innerHtml = DEFAULT_PROMPT;
      lastOpenParenCount = 0;
      //cancelInput();
      updateInput("");
    });
  }
}

styleInput() {
  String text = input.text;
  updateStatus(text);
  var s = window.getSelection();
  var last = s.getRangeAt(0);
  var pos = findPosition(last);
  String style = highlight(text);
  input.innerHtml = style;
  var r = makeRange(pos);
  s.removeAllRanges();
  s.addRange(r);
}

int findPosition(var range) {
  int offset = range.startOffset;
  var node = range.startContainer;
  bool found = false;
  int countUntil(var current, var needle) {
    if (current == needle) {
      found = true;
      return 0;
    } else if (current.nodeType == Node.TEXT_NODE) {
      return current.text.length;
    } else {
      int total = 0;
      for (var c in current.childNodes) {
        total += countUntil(c, needle);
        if (found) return total;
      }
      return total;
    }
  }
  return countUntil(input, node) + offset;
}

Range makeRange(int pos) {
  int remaining = pos;
  Node findNode(var current) {
    if (current.nodeType == Node.TEXT_NODE) {
      int length = current.text.length;
      if (length >= remaining) {
        return current;
      } else {
        remaining -= length;
        return null;
      }
    } else {
      for (var c in current.childNodes) {
        var result = findNode(c);
        if (result != null) {
          return result;
        }
      }
      return null;
    }
  }
  var node = findNode(input);
  var r = new Range();
  if (node == null) {
    r.selectNodeContents(input);
    r.collapse(false);
  } else {
    r.setStart(node, remaining);
    r.setEnd(node, remaining);
  }
  return r;
}

delay(int millis, var fn) {
  return new Future.delayed(new Duration(milliseconds: millis), fn);
}

listenForResize() {
  window.onResize.listen((e) {
    context['jsPlumb'].callMethod('repaintEverything', []);
  });
}
