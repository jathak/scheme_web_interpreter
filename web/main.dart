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
Frontend: WIP
Core library: Everything but quasiquoting
Async/await: Supported through AsyncExpressions and auto-awaiting frontend
Event listeners: Core support, needs buttons on frontend
Diagramming: Working, needs some CSS tweaks
Visualization: Working, needs UI controls
.scm Libraries: None yet, needs imports and some rewrites
JS interop: Mostly done
Theming: Not yet
Turtle: Not yet

Component Versions
--------------------------------------------------------------------------------
Frontend: WIP, not yet versioned
Core Interpreter: 2.0.0-alpha004
StaffProjectImplementation: 2.0.0-alpha004

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
  var repl = new Repl(interpreter, document.body);
  repl.logText(motd);
}
