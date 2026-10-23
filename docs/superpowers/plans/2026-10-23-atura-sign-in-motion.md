# Atura Sign-in Motion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the stock page transitions on the way in with two custom moments: **B · Badge handoff** (Welcome → Sign in) and **D · Check-in** (Sign in → Home).

**Architecture:** Each moment is split at the route change so that the last frame of one screen is pixel-identical to the first frame of the next, and the route transition itself does almost nothing.
- **B:** WelcomeScreen plays its own handoff: the badge straightens, the lanyard pulls up, the teal band floods the screen and the wordmark flies to the sign-in header. Then it pushes `/login`. LoginScreen animates its own headline, art and sheet in from the route's `animation`.
- **D:** LoginScreen plays the check-in: spinner, then check, then the sheet rises to cover the screen. A new `entryHeldProvider` keeps the auth redirect from leaving `/login` until that finishes. The home shell then fades its sections in one after another, driven by an `ArrivalAnimation` that the shell's page transition provides.

**Tech Stack:** Flutter, go_router 14 (`CustomTransitionPage`), flutter_riverpod 2, mocktail for tests.

**Spec:** Design canvas "Atura Sign-in Motion" — https://claude.ai/artifact/SQ3jBroeEWQ3cbu56mJTot. The relevant frames are **B · Badge handoff**, **D · Check-in** and **A + D · End to end**; their timings are on the sticky notes. Picked by Irfan on 2026-10-23: B + D.

## Global Constraints

- Easing for every custom curve: `Cubic(0.23, 1, 0.32, 1)`. Name it `kSignInCurve`.
- Reduced motion (`MediaQuery.disableAnimationsOf(context)`) turns every moment in this plan into a 150ms cross-fade, and nothing is held back.
- The redirect is never held longer than the check-in itself, about 650ms after the session lands. A failed sign-in releases the hold at once.
- Light and dark must both work:
  - The welcome band is `#003439` in light mode and `#00C896` in dark; the sign-in background is the same teal gradient in both.
  - The band's wordmark is white in light mode and `#111111` in dark; it ends white.
- Success haptic on the check only when `profileSettingsProvider.hapticFeedbackEnabled` is on: `HapticFeedback.mediumImpact()`, on the same frame the check appears.
- Submitting locks on the first tap. Sign in and Start my shift each act once per tap, however fast they are tapped again.
- Commits: conventional style as in this repo (`feat(auth): …`), no trailers of any kind. **Ask Irfan before the first commit**; he decides when history is written.
- Branch: `feature/atura-rebrand`. Flutter binary: `/Users/irfanfikhribiniszahar/Developer/flutter/bin/flutter`.

## Review Focus

1. **Sign-in fails after the hold is set.** The hold must release and the error show under the button; otherwise the person is stuck on Sign in. Test in Task 2.
2. **Sign in tapped twice during the check-in.** `login` must be called once. Test in Task 2.
3. **Start my shift tapped twice, or back pressed during the handoff.** `/login` must be pushed once, and the welcome must come back whole after back. Test in Task 5.
4. **Person with several warehouses.** After the check-in they land on Choose warehouse, not Home, and nothing waits on an `ArrivalAnimation` that isn't there. Tests in Tasks 1 and 3.
5. **Fingerprint unlock.** It plays the same check-in, and a locked session still keeps the person on Sign in until unlocked. Test in Task 2.

---

### Task 1: Hold the redirect on Sign in during the check-in

**Files:**
- Modify: `lib/core/providers/auth_provider.dart`: add the provider next to `lockedSessionProvider`
- Modify: `lib/core/router/auth_redirect.dart`: new `held` parameter
- Modify: `lib/core/router/app_router.dart:53-72`: `_RouterNotifier` listens to and passes the hold
- Test: `test/core/router/auth_redirect_test.dart`

**Interfaces:**
- Produces: `final entryHeldProvider = StateProvider<bool>((_) => false);` and `String? authRedirect({required AsyncValue<UserSession?> auth, required String location, UserSession? locked, bool held = false})`

- [ ] **Step 1: Write the failing tests**

```dart
test('a held sign-in stays on Sign in until the check-in finishes', () {
  final signedIn = AsyncData<UserSession?>(session(warehouseId: 'kp1', warehouses: [kp1]));
  expect(authRedirect(auth: signedIn, location: AppRoutes.login, held: true), isNull);
  expect(authRedirect(auth: signedIn, location: AppRoutes.login), AppRoutes.dashboard);
});

test('the hold only applies on Sign in, and still leads to Choose warehouse after', () {
  final waiting = AsyncData<UserSession?>(session(warehouses: [sa1, kp1]));
  expect(authRedirect(auth: waiting, location: AppRoutes.dashboard, held: true), AppRoutes.chooseWarehouse);
  expect(authRedirect(auth: waiting, location: AppRoutes.login), AppRoutes.chooseWarehouse);
});
```

- [ ] **Step 2: Run them and confirm they fail**

Run: `flutter test test/core/router/auth_redirect_test.dart`
Expected: compile error, `No named parameter with the name 'held'`

- [ ] **Step 3: Implement**

In `authRedirect`, return `null` when `held && location == AppRoutes.login`. Put this check before the session branches. `_RouterNotifier` adds a third `ref.listen(entryHeldProvider, …)` subscription, closes it in `dispose`, and passes `held: _ref.read(entryHeldProvider)`.

- [ ] **Step 4: Run all router tests and confirm they pass**

Run: `flutter test test/core/router/`
Expected: all pass, including the six existing tests.

- [ ] **Step 5: Commit** (after Irfan's go-ahead)

```bash
git add lib/core/providers/auth_provider.dart lib/core/router/auth_redirect.dart lib/core/router/app_router.dart test/core/router/auth_redirect_test.dart
git commit -m "feat(auth): hold the sign-in redirect while the check-in plays"
```

---

### Task 2: D · Check-in on Sign in

**Files:**
- Modify: `lib/features/auth/presentation/login_screen.dart`: `_signIn`, `_biometricSignIn`, the button, the sheet
- Create: `lib/core/motion/sign_in_motion.dart`: shared constants
- Test: `test/features/auth/login_screen_test.dart`

**Interfaces:**
- Consumes: `entryHeldProvider` (Task 1)
- Produces, in `sign_in_motion.dart`:
  - `const kSignInCurve = Cubic(0.23, 1, 0.32, 1);`
  - `const kCheckInFold = Duration(milliseconds: 200);`
  - `const kCheckInPause = Duration(milliseconds: 250);`
  - `const kCheckInRise = Duration(milliseconds: 400);`
  - `const kReducedMotionFade = Duration(milliseconds: 150);`
- Produces, in `login_screen.dart`: `static const checkInKey = ValueKey('check-in');` on the check icon, `Icons.check_rounded`

Sequence after a successful `login(...)` or a successful fingerprint:
1. The button folds from full width to a 48 × 48 circle and its label becomes the check (`kCheckInFold`). The haptic fires here, gated by the setting.
2. Pause for `kCheckInPause`.
3. The sheet rises to cover the screen (`kCheckInRise`). Its `minHeight` animates from rest to the full layout height and its top dip flattens. The form contents fade out over the first half.
4. Set `entryHeldProvider` to false.

Before calling `login` or `unlock`, set `entryHeldProvider` to true. If `login` leaves the auth state in error, set it back to false at once. With reduced motion, never set the hold.

- [ ] **Step 1: Write the failing tests**

```dart
testWidgets('a successful sign-in holds on Sign in, shows the check, then lets go', (tester) async {
  when(() => mockRepo.getStoredSession()).thenAnswer((_) async => null);
  when(() => mockRepo.login(any(), any())).thenAnswer((_) async => workerSession);
  await tester.pumpWidget(buildSubject());
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), 'worker@warehouse.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'pw');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
  await tester.pump(); // login resolves
  await tester.pump(const Duration(milliseconds: 250));
  final container = ProviderScope.containerOf(tester.element(find.byType(LoginScreen)));
  expect(find.byKey(LoginScreen.checkInKey), findsOneWidget);
  expect(container.read(entryHeldProvider), isTrue);
  await tester.pumpAndSettle();
  expect(container.read(entryHeldProvider), isFalse);
});

testWidgets('a failed sign-in lets go at once and keeps the button', (tester) async { /* login throws → held false after pump(); error text shown; Sign in button present; no check */ });

testWidgets('Sign in tapped twice signs in once', (tester) async { /* two taps → verify(() => mockRepo.login(any(), any())).called(1) */ });

testWidgets('a locked session unlocked by fingerprint plays the same check-in', (tester) async { /* extend the existing fingerprint test: check shown, held true then false */ });

testWidgets('with reduced motion nothing is held', (tester) async { /* wrap in MediaQuery(disableAnimations: true): held never true; no check */ });
```

Write the bodies of the four placeholder tests in the same style as the first. The comment in each one lists its assertions.

- [ ] **Step 2: Run them and confirm they fail**

Run: `flutter test test/features/auth/login_screen_test.dart`
Expected: the new tests fail (`entryHeldProvider` is never true, no check found). The nine existing tests still pass.

- [ ] **Step 3: Implement the sequence above in `login_screen.dart`**

Use one `AnimationController` (`_checkIn`, with `vsync` from `SingleTickerProviderStateMixin`) running 0 → 1 over fold + pause + rise. Drive the parts with `Interval`s on it.
- Guard both `_signIn` and `_biometricSignIn` with a `bool _submitting` flag that is set on the first tap.
- Reuse the existing `TweenAnimationBuilder` height logic for the rise by animating its target to the full layout height.

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/features/auth/`
Expected: all pass.

- [ ] **Step 5: Commit** (after Irfan's go-ahead)

```bash
git add lib/core/motion/sign_in_motion.dart lib/features/auth/presentation/login_screen.dart test/features/auth/login_screen_test.dart
git commit -m "feat(auth): check-in on sign-in — button folds to a check, the sheet rises to cover"
```

---

### Task 3: D · Home arrives in steps

**Files:**
- Create: `lib/core/motion/arrival.dart`: `ArrivalAnimation` and `StaggeredEntrance`
- Modify: `lib/core/router/app_router.dart`: the `StatefulShellRoute.indexedStack` gets a `pageBuilder`
- Modify: `lib/features/dashboard/presentation/worker_dashboard_screen.dart`, `supervisor_dashboard_screen.dart`: wrap the sections
- Modify: `lib/core/widgets/app_scaffold.dart`: wrap `_BottomBar`
- Test: `test/core/motion/arrival_test.dart`

**Interfaces:**
- Consumes: `kSignInCurve`, `kReducedMotionFade` (Task 2)
- Produces:
  - `class ArrivalAnimation extends InheritedWidget { final Animation<double> animation; static Animation<double>? maybeOf(BuildContext context); }`
  - `class StaggeredEntrance extends StatelessWidget { const StaggeredEntrance({super.key, required this.order, this.fromBelow = false, required this.child}); }`
  - `const kArrival = Duration(milliseconds: 450);`
  - `const kArrivalStep = Duration(milliseconds: 60);`

`StaggeredEntrance` behaviour:
- With no `ArrivalAnimation` above it, it returns `child` unchanged. This is the case on every other screen, including Choose warehouse.
- With one, its part of the animation starts at `order × kArrivalStep` and runs for 210ms on `kSignInCurve`. The section fades in and moves up 8pt.
- When `fromBelow` is set (the bottom bar), it slides up from its full height and doesn't fade.

The shell's `pageBuilder` returns a `CustomTransitionPage` with `transitionDuration: kArrival`. Its `transitionsBuilder` wraps `child` in `ArrivalAnimation(animation: animation, child: child)`, with no fade of the page itself. The page's ground already matches the risen sheet. With reduced motion it returns a `FadeTransition` over `kReducedMotionFade` instead.

Order on both dashboards: greeting 0, Quick Actions block 1, Recent Activity block 2. The supervisor dashboard uses the same three positions for its own sections. The bottom bar is order 1 with `fromBelow: true`.

- [ ] **Step 1: Write the failing tests**

```dart
testWidgets('without an arrival the child shows as-is', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: StaggeredEntrance(order: 2, child: Text('Recent'))));
  expect(tester.widget<Opacity>(find.ancestor(of: find.text('Recent'), matching: find.byType(Opacity)).first).opacity, 1.0);
});

testWidgets('during an arrival later sections start later', (tester) async {
  final controller = AnimationController(vsync: tester, duration: kArrival)..value = 60 / 450 * 1.5; // 90ms in
  await tester.pumpWidget(MaterialApp(home: ArrivalAnimation(animation: controller, child: const Column(children: [
    StaggeredEntrance(order: 0, child: Text('Greeting')),
    StaggeredEntrance(order: 2, child: Text('Recent')),
  ]))));
  double opacityOf(String t) => tester.widget<Opacity>(find.ancestor(of: find.text(t), matching: find.byType(Opacity)).first).opacity;
  expect(opacityOf('Greeting'), greaterThan(0));
  expect(opacityOf('Recent'), 0);
  controller.value = 1;
  await tester.pump();
  expect(opacityOf('Recent'), 1);
});
```

Always build an `Opacity`, even at 1.0, so these finders work. Use `FadeTransition` only if you change the tests to match.

- [ ] **Step 2: Run them and confirm they fail**

Run: `flutter test test/core/motion/arrival_test.dart`
Expected: compile error, `arrival.dart` not found.

- [ ] **Step 3: Implement `arrival.dart`, then wire the shell `pageBuilder`, the dashboards and the bottom bar**

- [ ] **Step 4: Run all tests and confirm they pass**

Run: `flutter test`
Expected: all pass. The dashboard and app-scaffold tests have no `ArrivalAnimation`, so they render as before.

- [ ] **Step 5: Commit** (after Irfan's go-ahead)

```bash
git add lib/core/motion/arrival.dart lib/core/router/app_router.dart lib/features/dashboard/presentation/ lib/core/widgets/app_scaffold.dart test/core/motion/arrival_test.dart
git commit -m "feat(home): sections arrive in steps after sign-in"
```

---

### Task 4: B · Sign in builds itself in on push

**Files:**
- Create: `lib/features/auth/presentation/sign_in_geometry.dart`: what Welcome and Sign in must agree on
- Modify: `lib/features/auth/presentation/login_screen.dart`: use the shared values; the hero text, art and sheet read the route animation
- Modify: `lib/core/router/app_router.dart`: the `/login` route gets a `pageBuilder`
- Test: `test/features/auth/welcome_screen_test.dart` (the router-based harness lives there)

**Interfaces:**
- Consumes: `kSignInCurve`, `kReducedMotionFade` (Task 2)
- Produces, in `sign_in_geometry.dart`:
  - `const kSignInGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF003439), Color(0xFF00504A)]);`
  - `const kSignInWordmarkInset = Offset(24, 20); // from the left edge and from the top safe area`
  - `const kSignInWordmarkHeight = 22.0;`
  - `const kSignInEntrance = Duration(milliseconds: 450);`
  - `const kSignInExit = Duration(milliseconds: 300);`
  - `CustomTransitionPage<void> signInPage(Widget child)`: the page builder used for `/login`

The `/login` page uses `transitionDuration: kSignInEntrance` and `reverseTransitionDuration: kSignInExit`. Its `transitionsBuilder` returns `child` untouched; with reduced motion it returns a `FadeTransition` instead.

Inside LoginScreen, `ModalRoute.of(context)?.animation` drives three parts. The background gradient and the wordmark never move, because they must match the end of the welcome handoff.

| Part | Interval | Motion |
|------|----------|--------|
| Headline and tagline | 0.1 – 0.8 | fade in, rise 12pt |
| Sheet | 0.0 – 1.0 | slide up from below the screen |
| Art | 0.3 – 1.0 | fade in, move in 16pt from the right |

When the route animation is null or already complete (tests that build LoginScreen as `home:`), everything sits at rest.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('Sign in builds itself in: wordmark in place at once, the sheet arrives from below', (tester) async {
  await tester.pumpWidget(buildSubject()); // the router harness, with /login now using signInPage
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Start my shift'));
  await tester.pumpAndSettle(); // pushes /login (after Task 5, also plays the handoff first)
  // Re-run the entrance from the start to look at its first frame:
  final route = ModalRoute.of(tester.element(find.byType(LoginScreen)))! as TransitionRoute;
  route.controller!.value = 0;
  await tester.pump();
  final screen = tester.getSize(find.byType(LoginScreen));
  expect(tester.getTopLeft(find.text('Sign in').first).dy, greaterThan(screen.height));
  expect(tester.getTopLeft(find.byType(AturaWordmark)).dx, 24);
});
```

If writing `TransitionRoute.controller` is awkward in this go_router version, write the same assertions against a one-frame `pump()` right after the push in Task 5's harness.

- [ ] **Step 2: Run it and confirm it fails**

Run: `flutter test test/features/auth/welcome_screen_test.dart`
Expected: FAIL. The sheet is already at rest on the first frame.

- [ ] **Step 3: Implement `sign_in_geometry.dart`, move LoginScreen onto it, add the route-driven entrance, and give `/login` its `pageBuilder` in the app router and the test harness**

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/features/auth/`
Expected: all pass.

- [ ] **Step 5: Commit** (after Irfan's go-ahead)

```bash
git add lib/features/auth/presentation/ lib/core/router/app_router.dart test/features/auth/
git commit -m "feat(auth): sign-in screen builds itself in from the welcome handoff"
```

---

### Task 5: B · Badge handoff on Welcome

**Files:**
- Modify: `lib/features/auth/presentation/welcome_screen.dart`: `WelcomeScreen` becomes stateful and gets a `_handoff` controller; `_Hero`, `_Swing` and the bottom block read it
- Test: `test/features/auth/welcome_screen_test.dart`

**Interfaces:**
- Consumes: `kSignInGradient`, `kSignInWordmarkInset`, `kSignInWordmarkHeight` (Task 4); `kSignInCurve`, `kReducedMotionFade` (Task 2)
- Produces: `const kBadgeHandoff = Duration(milliseconds: 800);`

The `_handoff` controller runs 0 → 1 over `kBadgeHandoff` on Start my shift. Then it calls `await context.push(AppRoutes.login)`, and when that returns it runs `_handoff.reverse()` over 560ms.

| Interval | What moves |
|----------|------------|
| 0.0 – 0.3 | Headline, sub-line, button, note, planes and glow fade out |
| 0.0 – 0.45 | Badge angle lerps from `_Swing.rest` to 0 and lifts 8pt. Lanyard and hook (all three pieces from the hook fix) slide up 190pt and fade |
| 0.4 – 1.0 | **Flood:** a layer over everything, clipped to an `RRect`. It lerps from the band's rect at angle 0 (top corners 18 × scale, bottom corners 0) to the full screen with radius 0. Its fill lerps from the band colour to `kSignInGradient` |
| 0.4 – 1.0 | **Wordmark flight:** from the band position `(cx − 124·s + 25·s, badgeTop − 8 + 38·s)` at height `112·241/828·s` to `(kSignInWordmarkInset.dx, topInset + kSignInWordmarkInset.dy)` at height `kSignInWordmarkHeight`. Its colour goes from `onBand` to white |

The badge's face fades between 0.4 and 0.55, underneath the flood.

A tap while the handoff runs, or while the controller value is above 0, does nothing. With reduced motion, the push happens at once and `/login` cross-fades (Task 4).

If the button is tapped during the first-show swing, the handoff starts its lerp from `_Swing.rest`. The swing is 1.4s and the jump is under 7°, so this is acceptable.

- [ ] **Step 1: Write the failing tests**

```dart
testWidgets('Start my shift plays the handoff before Sign in opens', (tester) async {
  await tester.pumpWidget(buildSubject());
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Start my shift'));
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(LoginScreen), findsNothing);
  await tester.pumpAndSettle();
  expect(find.byType(LoginScreen), findsOneWidget);
});

testWidgets('Start my shift tapped twice opens Sign in once', (tester) async { /* tap, pump 100ms, tap again (warnIfMissed: false), settle; back once → welcome visible */ });

testWidgets('back from Sign in brings the welcome back whole', (tester) async { /* push via tap, settle, pop, settle: button is hit-testable and its Opacity ancestor is 1 */ });

testWidgets('with reduced motion Start my shift opens Sign in straight away', (tester) async { /* MediaQuery(disableAnimations: true): tap, pump(), pump(kReducedMotionFade) → LoginScreen found */ });
```

The existing tests 'Start my shift opens the sign-in screen' and 'back from sign-in returns to the welcome screen' must keep passing unchanged.

- [ ] **Step 2: Run them and confirm they fail**

Run: `flutter test test/features/auth/welcome_screen_test.dart`
Expected: the first new test fails, because LoginScreen is found at 400ms.

- [ ] **Step 3: Implement the handoff in `welcome_screen.dart`**

The flood and the flying wordmark are positioned in `_Hero`'s `LayoutBuilder` coordinates, which already compute `badgeTop`, `scale`, `cx` and `topInset`. The hero must stop clipping so the flood can cover the whole screen: draw the flood in an `Overlay`-free top layer of WelcomeScreen's root `Stack`. Pass the hero's geometry up through a callback or a small `ValueNotifier`; don't recompute it.

- [ ] **Step 4: Run all tests and confirm they pass**

Run: `flutter test`
Expected: all pass.

- [ ] **Step 5: Check on the emulator, in light and dark mode**

Run `flutter run -d emulator-5554`, then tap Start my shift, sign in, sign out, turn dark mode on in Profile, and repeat.
Expected:
- The welcome band floods to teal with no visible seam when Sign in takes over. The wordmark lands exactly on Sign in's wordmark.
- Sign in folds to a check, the sheet covers the screen, and Home arrives in steps.
- Back from Sign in restores the welcome.
- With Settings › Accessibility › Remove animations on, each step is a plain cross-fade.

- [ ] **Step 6: Commit** (after Irfan's go-ahead)

```bash
git add lib/features/auth/presentation/welcome_screen.dart test/features/auth/welcome_screen_test.dart
git commit -m "feat(auth): badge handoff — the welcome band floods into the sign-in screen"
```

---

## After the plan

Once Irfan approves, update `project-management/warehouse-app/Design.md` → Motion & Feedback in memory-core. "Default transition: GoRouter default" gains an exception for the sign-in path, B + D, with a link to the canvas.
