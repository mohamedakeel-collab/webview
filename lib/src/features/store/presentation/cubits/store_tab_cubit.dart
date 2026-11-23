part of '../imports/store_imports.dart';

@injectable
class StoreTabCubit extends Cubit<StoreTab> {
  StoreTabCubit() : super(StoreTab.home);

  void select(StoreTab tab) => emit(tab);
}
