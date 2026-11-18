import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ModuleCard extends StatelessWidget {
  const ModuleCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.isLoading,
    required this.hasError,
    required this.onTap,
    super.key,
  });

  final String title;
  final IconData icon;
  final int? count;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppTheme.primary),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.dark,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  if (isLoading)
                    const SizedBox.square(
                      dimension: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Text(
                      hasError ? '—' : '${count ?? 0}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: hasError ? Colors.grey : AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hasError ? 'No disponible' : 'registros',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 17, color: Colors.black45),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
