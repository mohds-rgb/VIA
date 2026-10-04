# Dependency Policy

The Flutter application keeps `pubspec.yaml` as the dependency declaration. A `pubspec.lock` generated on a developer machine should be committed when the application is developed as a concrete app checkout.

The Firebase Functions package keeps `package.json` as the dependency declaration. A `package-lock.json` may be generated and committed from the maintainer's Windows environment before a real GitHub publication.

This portfolio package does not fabricate a lockfile from an environment that did not produce one.
