import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const SettingsScreen(),
                          transitionsBuilder: (context, animation,
                              secondaryAnimation, child) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                          transitionDuration:
                              const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: Icon(
                          Icons.settings_outlined,
                          size: 22,
                          color: colors.foreground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Image.asset(
              'assets/kioki-logo.png',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'KIOKI',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: colors.foreground,
                letterSpacing: 12,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                const GameScreen(),
                        transitionsBuilder: (context, animation,
                            secondaryAnimation, child) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                        transitionDuration:
                            const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Text(
                    'START',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.foreground,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
