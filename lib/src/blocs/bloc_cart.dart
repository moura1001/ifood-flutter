import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:ifood_app/src/controllers/cart_controller.dart';
import 'package:ifood_app/src/models/cart_item.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ifood_app/src/validation/address_validator.dart';

class BlocCart extends BlocBase {
  var _cartItems = BehaviorSubject<List<CartItem>>();

  List<CartItem> items;
  double totalPrice;

  Observable<List<CartItem>> get cartItems => _cartItems.stream;

  void addItem(CartItem newItem) {
    if (items == null) {
      items = [newItem];
    } else {
      var result =
          items.firstWhere((item) => item.id == newItem.id, orElse: () => null);

      if (result != null) {
        result.incrementAmount();
      } else {
        items.add(newItem);
      }
    }

    _cartItems.sink.add(items);
  }

  void decrementAmount(int index) {
    items[index].amount--;
    items[index].priceTotal = items[index].amount * items[index].price;

    if (items[index].amount <= 0) {
      items.removeAt(index);
    }

    _cartItems.sink.add(items);
  }

  Future sendPedido(
      double total, int idRestaurante, int idCliente, String endereco, String tipoEntrega) async {
    
    if(!AddressValidator.validate(endereco))
      return {"error": "Endereço inválido."};
    
    CartController cartController = CartController();
    List copy = List.from(items);

    try {
      var res = await cartController.createPedido(idRestaurante, idCliente, tipoEntrega, endereco);

      if(res["pedido"].isEmpty)
        return res;

      copy.forEach((item) async {
        try {
          var newfood = await cartController.insertFood(
              res["pedido"]["id"], item.id, item.amount, item.price);
          print("novacomida: $newfood");
        } catch (err) {
          print(err);
        }
      });

      var preco = await cartController.totalPrice(res["pedido"]["id"], total, tipoEntrega);
      print(preco);
      clearList();
      print("Items originais FINAL: $items");
      print("Items COPIA: $copy");
      
    } catch (err) {
      print(err);
    }

    return {};
  }

  void clearList() {
    items = [];
    _cartItems.sink.add(items);
  }

  double valueTotal() {
    double total = 0;
    if (items == null || items.length == 0) {
      return total;
    }

    items.forEach((item) {
      if (item != null) {
        total += item.priceTotal;
      }
    });

    return total;
  }

  @override
  void dispose() {
    _cartItems.close();
    super.dispose();
  }
}
