part of '../imports/store_imports.dart';

class _StoreBottomBar extends StatelessWidget {
  const _StoreBottomBar({required this.current, required this.onSelect});

  final StoreTab current;
  final ValueChanged<StoreTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: current.index,
      onDestinationSelected: (i) => onSelect(StoreTab.values[i]),
      backgroundColor: AppColors.card,
      indicatorColor: AppColors.brandSurface,
      destinations: [
        for (final tab in StoreTab.values)
          NavigationDestination(
            icon: Icon(tab.icon, color: AppColors.hintText),
            selectedIcon: Icon(tab.selectedIcon, color: AppColors.brand),
            label: tab.label,
          ),
      ],
    );
  }
}
