# scheme_web_interpreter

[scheme.cs61a.org][] is an online interpreter for [61A Scheme][] written in
[Dart][]. It's used by Berkeley's CS 61A to help students learn Scheme.

It depends on both [dart_scheme][] and a private implementation library (since
parts of the interpreter mirror the 61A Scheme project). A [skeleton][] of this
library is publicly available.

## Development Setup

1. Install the [Dart SDK](https://www.dartlang.org/install). At least version
1.20 is required, but I recommend at least 1.24.

2. Clone all three repos into a shared directory.

```
mkdir scheme && cd scheme
git clone git@github.com:Cal-CS-61A-Staff/dart_scheme.git
git clone git@github.com:Cal-CS-61A-Staff/scheme_web_interpreter.git
git clone git@github.com:jathak/scheme_impl_skeleton.git dart_scheme_impl
```

61A TAs may replace that last line with

```
git clone git@github.com:Cal-CS-61A-Staff/dart_scheme_impl.git
```

3. From the scheme_web_interpreter, run `pub get` to fetch dependencies.

4. For a build that should closely match the published release (minus
obfuscation), run `pub serve` and go to `localhost:8080`. These builds must run
after every change to the Dart code and can take a while (they'll happen
automatically when you refresh the page).

5. (Dart 1.24+) For a faster dev cycle, run `pub serve --web-compiler=dartdevc`.
This compiler is incremental, so it should be much faster. However, some
behavior can differ (notably, procedure toString methods are including a bunch
of random JS at the moment; that appears to be fixed in the Dart 2 dev build).

## Deployment

To deploy to the 61A Dokku, make sure you have a remote named `dokku` set up to
point to it and then run `make deploy`. Note: This will build based off of the
current working tree, and include any uncommitted changes.

If this is the first time the app has been deployed, run `git push dokku master`
to initialize the remote repo (it will fail, but then `make deploy` can work).

[scheme.cs61a.org]: https://scheme.cs61a.org
[Dart]: https://dartlang.org
[dart_scheme]: https://github.com/Cal-CS-61A-Staff/dart_scheme
[61A Scheme]: https://cs61a.org/articles/scheme-spec.html
[skeleton]: https://github.com/jathak/scheme_impl_skeleton
