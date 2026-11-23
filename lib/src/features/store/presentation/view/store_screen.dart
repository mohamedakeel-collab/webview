part of '../imports/store_imports.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late final StoreTabCubit _cubit;
  late final StoreViewController _vc;

  @override
  void initState() {
    super.initState();
    _cubit = injector<StoreTabCubit>();
    _vc = StoreViewController(onSelectTab: _cubit.select);
  }

  @override
  void dispose() {
    _vc.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: _StoreBody(vc: _vc),
    );
  }
}
