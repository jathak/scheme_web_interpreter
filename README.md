# scheme_web_interpreter

This is a new frontend under development for scheme.cs61a.org.

You can currently try it out at [scheme-beta.apps.cs61a.org][].

It depends on the [Dart implementation][] of [61A Scheme][] and a
[private staff implementation][private] of the required [ProjectInterface][].

## Development Setup

1. Install the [Dart SDK](https://www.dartlang.org/install). At least version
1.20 is required, but I recommend at least 1.24. If Dart 2.0 has been released
by the time you read this, stick with the latest 1.x version for now. Make sure
that both `dart` and `pub` are on your path.

1b. (Temporary) At the moment, this project uses the Ruby version of Sass and
requires you to install it separately on your path in order to build the CSS.
I plan to switch this over to the Dart version of Sass soon.

2. While this package will eventually depend on the main implementation through
Pub and the private implementation through Git, for right now, make a directory
and clone all three repos into it as follows:

    dart_scheme -> cs61a_scheme
    dart_scheme_impl -> cs61a_scheme_impl
    scheme_web_interpreter -> scheme_web_interpreter

3. From the scheme_web_interpreter, run `pub get` to fetch dependencies.

4. For a build that should closely match the published release (minus
obfuscation), run `pub serve` and go to `localhost:8080`. These builds must run
after every change to the Dart code and can take a while (they'll happen
automatically when you refresh the page).

5. (Dart 1.24+) For a faster dev cycle, run `pub serve --web-compiler=dartdevc`.
This compiler is incremental, so it should be much faster. However, some
behavior can differ (notably, procedure toString methods are including a bunch
of random JS at the moment).

## Deployment

To deploy to the 61A Dokku, make sure you have a remote named `dokku` set up to
point to it and then run `make deploy`. Note: This will build based off of the
current working tree, and include any uncommitted changes.

If this is the first time the app has been deployed, run `git push dokku master`
to initialize the remote repo (it will fail, but then `make deploy` can work).

[scheme-beta.apps.cs61a.org]: https://scheme-beta.apps.cs61a.org
[Dart implementation]: https://github.com/Cal-CS-61A-Staff/dart_scheme
[61A Scheme]: https://cs61a.org/articles/scheme-spec.html
[private]: https://github.com/Cal-CS-61A-Staff/dart_scheme_impl
[ProjectInterface]: https://github.com/Cal-CS-61A-Staff/dart_scheme/blob/master/lib/src/core/project_interface.dart
