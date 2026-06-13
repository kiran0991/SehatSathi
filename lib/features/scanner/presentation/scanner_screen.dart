import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../analysis/domain/models/scan_analysis_payload.dart';
import '../../analysis/presentation/providers/ingredient_analysis_providers.dart';
import '../../profile/domain/models/health_profile.dart';
import '../../profile/presentation/providers/health_profile_providers.dart';
import '../domain/models/image_upload_state.dart';
import '../domain/models/ocr_result.dart';
import 'providers/image_upload_providers.dart';
import 'providers/ocr_providers.dart';
import 'widgets/browser_camera_capture.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageUploadControllerProvider);
    final controller = ref.read(imageUploadControllerProvider.notifier);
    final ocrState = ref.watch(ocrControllerProvider);
    final ocrController = ref.read(ocrControllerProvider.notifier);
    final canReset =
        state.hasPreview ||
        state.uploadedImage != null ||
        ocrState.value != null ||
        ocrState.hasError;

    return Scaffold(
      backgroundColor: const Color(0xFF081C15),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 860;
                  final actionPanel = _ActionPanel(
                    state: state,
                    onCameraPressed: state.isPicking || state.isUploading
                        ? null
                        : () async {
                            ocrController.clear();
                            final capturedImage =
                                await showBrowserCameraCaptureDialog(context);
                            if (capturedImage != null) {
                              controller.setSelectedImage(capturedImage);
                            }
                          },
                    onGalleryPressed: state.isPicking || state.isUploading
                        ? null
                        : () async {
                            ocrController.clear();
                            await controller.pickFromGallery();
                          },
                    onUploadPressed: state.isUploading || !state.hasPreview
                        ? null
                        : () async {
                            ocrController.clear();
                            final result = await controller
                                .uploadSelectedImage();
                            if (!context.mounted) {
                              return;
                            }

                            final nextState = ref.read(
                              imageUploadControllerProvider,
                            );
                            if (result != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n.text('scannerImageUploaded'),
                                  ),
                                ),
                              );
                            } else if (nextState.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(nextState.errorMessage!),
                                ),
                              );
                            }
                          },
                    onResetPressed: canReset
                        ? () {
                            controller.clearSelection();
                            ocrController.clear();
                          }
                        : null,
                    onOcrPressed:
                        state.uploadedImage == null || ocrState.isLoading
                        ? null
                        : () async {
                            final uploadedImage = ref
                                .read(imageUploadControllerProvider)
                                .uploadedImage;
                            if (uploadedImage == null) {
                              return;
                            }

                            try {
                              final result = await ocrController
                                  .extractIngredients(uploadedImage);
                              if (!context.mounted) {
                                return;
                              }
                              final healthProfile =
                                  ref
                                      .read(healthProfileControllerProvider)
                                      .value ??
                                  HealthProfile.initial();
                              final analysisResult = ref.read(
                                ingredientAnalysisProvider(
                                  IngredientAnalysisInput(
                                    ocrResult: result,
                                    healthProfile: healthProfile,
                                  ),
                                ),
                              );
                              context.go(
                                '/result',
                                extra: ScanAnalysisPayload(
                                  uploadedImage: uploadedImage,
                                  ocrResult: result,
                                  analysisResult: analysisResult,
                                ),
                              );
                            } catch (error) {
                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error.toString().replaceFirst(
                                      'Bad state: ',
                                      '',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                    ocrState: ocrState,
                  );

                  if (isCompact) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 440,
                            child: _PreviewPanel(state: state),
                          ),
                          const SizedBox(height: 24),
                          actionPanel,
                        ],
                      ),
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 6, child: _PreviewPanel(state: state)),
                      const SizedBox(width: 24),
                      Expanded(flex: 5, child: actionPanel),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.state});

  final ImageUploadState state;

  @override
  Widget build(BuildContext context) {
    final selectedImage = state.selectedImage;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B3B2E), Color(0xFF04110C)],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.document_scanner_outlined,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                context.l10n.text('scannerTitle'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppStyles.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.text('scannerSubtitle'),
            style: const TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 14,
              height: 1.5,
              fontFamily: AppStyles.fontFamily,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: selectedImage == null
                  ? const _EmptyPreview()
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.memory(
                        selectedImage.bytes,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          if (selectedImage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image_outlined, color: Colors.white70),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedImage.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppStyles.fontFamily,
                      ),
                    ),
                  ),
                  Text(
                    '${(selectedImage.sizeInBytes / 1024).toStringAsFixed(1)} KB',
                    style: const TextStyle(
                      color: Color(0xFFA7F3D0),
                      fontFamily: AppStyles.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_a_photo_outlined,
            size: 54,
            color: Colors.white70,
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.text('scannerNoImage'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: AppStyles.fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.text('scannerNoImageHint'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
              fontFamily: AppStyles.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.state,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onUploadPressed,
    required this.onResetPressed,
    required this.onOcrPressed,
    required this.ocrState,
  });

  final ImageUploadState state;
  final VoidCallback? onCameraPressed;
  final VoidCallback? onGalleryPressed;
  final VoidCallback? onUploadPressed;
  final VoidCallback? onResetPressed;
  final VoidCallback? onOcrPressed;
  final AsyncValue<OcrResult?> ocrState;

  @override
  Widget build(BuildContext context) {
    final uploadedImage = state.uploadedImage;
    final ocrResult = ocrState.value;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.text('scannerChooseMethod'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: AppStyles.fontFamily,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => context.go('/profile'),
                icon: const Icon(Icons.person_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.text('scannerMethodSubtitle'),
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontFamily: AppStyles.fontFamily,
            ),
          ),
          const SizedBox(height: 24),
          _ActionTile(
            icon: Icons.photo_camera_outlined,
            title: context.l10n.text('scannerTakePhoto'),
            subtitle: context.l10n.text('scannerTakePhotoSubtitle'),
            onTap: onCameraPressed,
            isBusy: state.isPicking,
          ),
          const SizedBox(height: 14),
          _ActionTile(
            icon: Icons.folder_open_outlined,
            title: context.l10n.text('scannerChooseDevice'),
            subtitle: context.l10n.text('scannerChooseDeviceSubtitle'),
            onTap: onGalleryPressed,
            isBusy: state.isPicking,
          ),
          const SizedBox(height: 24),
          if (state.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppStyles.fontFamily,
                ),
              ),
            ),
          if (state.errorMessage != null) const SizedBox(height: 16),
          if (uploadedImage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.text('scannerUploadComplete'),
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppStyles.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.text('scannerUploadReady'),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontFamily: AppStyles.fontFamily,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          if (uploadedImage != null) const SizedBox(height: 16),
          if (ocrState.hasError)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                ocrState.error.toString().replaceFirst('Bad state: ', ''),
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppStyles.fontFamily,
                ),
              ),
            ),
          if (ocrState.hasError) const SizedBox(height: 16),
          if (ocrResult != null) _OcrResultCard(result: ocrResult),
          if (ocrResult != null) const SizedBox(height: 16),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onResetPressed,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    context.l10n.text('scannerReset'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: AppStyles.fontFamily,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: onOcrPressed,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: ocrState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          context.l10n.text('scannerRunOcr'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: AppStyles.fontFamily,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onUploadPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: state.isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surface,
                          ),
                        )
                      : Text(
                          context.l10n.text('scannerUploadSupabase'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: AppStyles.fontFamily,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OcrResultCard extends StatelessWidget {
  const _OcrResultCard({required this.result});

  final OcrResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('scannerOcrIngredients'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontFamily: AppStyles.fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.ingredients.isEmpty
                ? context.l10n.text('scannerNoStructuredIngredients')
                : result.ingredients.map((item) => item.name).join(', '),
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontFamily: AppStyles.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isBusy,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          color: const Color(0xFFF9FAFB),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppStyles.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontFamily: AppStyles.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            isBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
