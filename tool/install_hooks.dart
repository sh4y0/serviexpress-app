import 'dart:io';

void main() async {
  final isWindows = Platform.isWindows;
  final repoRoot = Directory.current.path;
  final gitHooksDir = Directory('$repoRoot/.git/hooks');
  final sourceHook = File('$repoRoot/hooks/commit-msg');
  final targetHook = File('${gitHooksDir.path}/commit-msg');

  if (!gitHooksDir.existsSync()) {
    exit(1);
  }

  if (!sourceHook.existsSync()) {
    exit(1);
  }

  try {
    await sourceHook.copy(targetHook.path);
    if (!isWindows) {
      await Process.run('chmod', ['+x', targetHook.path]);
    }
  } catch (e) {
    exit(1);
  }
}
