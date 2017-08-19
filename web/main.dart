import 'dart:html';
import 'dart:js';

import 'package:cs61a_scheme/cs61a_scheme_web.dart';
import 'package:cs61a_scheme_impl/impl.dart' show StaffProjectImplementation;

import 'package:scheme_web_interpreter/repl.dart';

const String motd = """Scheme Interpreter 2.0 Preview
********************************************************************************
This is a development build of the new Scheme interpreter version.

Feature Status
--------------------------------------------------------------------------------
Frontend: Most things except for the editor are done
Core library: Everything but quasiquoting
Async/await: Supported through AsyncExpressions and auto-awaiting frontend
Event listeners: Core support, primitives in extra, buttons available.
Diagramming: Done
Visualization: Done
.scm Libraries: Themes only at this point, though imports are ready.
JS interop: Done
Theming: Done (with default, solarized, monochrome, monochrome-dark, and
  go-bears)
Turtle: Not yet

Component Versions
--------------------------------------------------------------------------------
Frontend: WIP, not yet versioned
Core Interpreter: 2.0.0-alpha006
StaffProjectImplementation: 2.0.0-alpha006

Help Wanted
--------------------------------------------------------------------------------
Ping @jathak on Slack if you want to help with development.
You'll need to learn Dart, but it's fairly easy to pick up.

""";

main() async {
  var interpreter = new Interpreter(new StaffProjectImplementation());
  interpreter.importLibrary(new ExtraLibrary());
  interpreter.importLibrary(new TurtleLibrary());
  var diagramBox = querySelector('#diagram');
  String css = await HttpRequest.getString('css/main.css');
  var style = querySelector('style');
  var web = new WebLibrary(diagramBox, context['jsPlumb'], css, style);
  interpreter.importLibrary(web);
  if (window.localStorage.containsKey('#scheme-theme')) {
    var d = new Deserializer(window.localStorage['#scheme-theme']);
    Expression expr = d.expression;
    if (expr is Theme) {
      applyTheme(expr, css, style, false);
    }
  }
  onThemeChange.listen((Theme theme) {
    window.localStorage['#scheme-theme'] = new Serializer(theme).toJSON();
  });
  var repl = new Repl(interpreter, document.body);
  repl.logText(motd);
}
