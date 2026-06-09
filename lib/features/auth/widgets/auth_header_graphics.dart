import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthHeaderGraphics extends StatelessWidget {
  const AuthHeaderGraphics({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 380,
      padding: const EdgeInsets.only(top: 60),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Logo Text
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.cloud, size: 36, color: Theme.of(context).colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Text(
                    'P-Drive',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ).animate().fade().slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'Your Files. Anywhere.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.2),
            ],
          ),

          // Central Cloud Graphic
          Positioned(
            top: 140,
            child: Container(
              width: 160,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  LucideIcons.cloud_upload,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ).animate().fade(delay: 200.ms).scale(curve: Curves.easeOutBack, delay: 200.ms)
             .then().shimmer(duration: 2.seconds),
          ),

          // Floating Icons
          _buildFloatingIcon(
            context: context,
            icon: LucideIcons.image,
            label: 'JPG',
            top: 120,
            left: 50,
            delay: 300,
            duration: 3000,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          _buildFloatingIcon(
            context: context,
            icon: LucideIcons.file_text,
            label: 'PDF',
            top: 110,
            right: 60,
            delay: 400,
            duration: 3500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          _buildFloatingIcon(
            context: context,
            icon: LucideIcons.video,
            label: 'MP4',
            top: 220,
            left: 60,
            delay: 500,
            duration: 3200,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          _buildFloatingIcon(
            context: context,
            icon: LucideIcons.file,
            label: 'DOC',
            top: 230,
            right: 50,
            delay: 600,
            duration: 2800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon({
    required BuildContext context,
    required IconData icon,
    required String label,
    double? top,
    double? bottom,
    double? left,
    double? right,
    required int delay,
    required int duration,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color.withOpacity(0.8)),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      )
      .animate(onPlay: (controller) => controller.repeat(reverse: true))
      .fade(delay: delay.ms)
      .scale(curve: Curves.easeOutBack, delay: delay.ms)
      .moveY(begin: 0, end: -10, duration: duration.ms, curve: Curves.easeInOut),
    );
  }
}
