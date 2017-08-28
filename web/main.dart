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
Core library: Done
Async/await: Supported through AsyncExpressions and auto-awaiting frontend
Event listeners: Done (and now actually working)
Diagramming: Done
Visualization: Done
.scm Libraries: (import 'scm/apps/chess) (should be same as old chess)
JS interop: Done
Theming: Done (default, solarized, monochrome, monochrome-dark, go-bears)
Turtle: Mostly done (missing pixel)

Component Versions
--------------------------------------------------------------------------------
Core Interpreter: 2.0.0-alpha008
StaffProjectImplementation: 2.0.0-alpha008

Help Wanted
--------------------------------------------------------------------------------
Ping @jathak on Slack if you want to help with development.
You'll need to learn Dart, but it's fairly easy to pick up.

""";

main() async {
  var inter = new Interpreter(new StaffProjectImplementation());
  inter.importLibrary(new ExtraLibrary());
  inter.importLibrary(new TurtleLibrary(querySelector('canvas'), inter));
  var diagramBox = querySelector('#diagram');
  String css = await HttpRequest.getString('css/main.css');
  var style = querySelector('style');
  var web = new WebLibrary(diagramBox, context['jsPlumb'], css, style);
  inter.importLibrary(web);
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
  var repl = new Repl(inter, document.body);
  repl.logText(motd);
}
