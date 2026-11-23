import 'package:flutter_test/flutter_test.dart';
import 'package:webviewtest/src/features/store/presentation/imports/store_imports.dart';

void main() {
  group('StoreTab.forPath', () {
    test('maps tab roots and their sub-pages', () {
      expect(StoreTab.forPath(''), StoreTab.home);
      expect(StoreTab.forPath('/'), StoreTab.home);
      expect(StoreTab.forPath('/offers'), StoreTab.offers);
      expect(StoreTab.forPath('/cart'), StoreTab.cart);
      expect(StoreTab.forPath('/account/orders'), StoreTab.account);
    });

    test('leaves product and category pages in the current tab', () {
      expect(StoreTab.forPath('/-/c1143338721'), isNull);
      expect(StoreTab.forPath('/cartier-ring/p123'), isNull);
      expect(StoreTab.forPath('/accounting'), isNull);
    });
  });
}
