import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:partnerapp/constants/styles.dart';
import 'package:partnerapp/provider/orderProvvider.dart';
import 'package:partnerapp/provider/userProvider.dart';
import 'package:partnerapp/widgets/gradientButton.dart';
import 'package:provider/provider.dart';

class Orders extends StatefulWidget {
  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  int totalSales = 0;
  int monthSales = 0;

  void calculateSales() {
    var orders = Provider.of<OrderProvider>(context, listen: false).ordersList;
    for (var o in orders) {
      totalSales += int.parse(o.itemPrice);
      if (o.orderTime.toDate().month == DateTime.now().month && o.orderTime.toDate().year == DateTime.now().year) {
        monthSales += int.parse(o.itemPrice);
      }
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final user = Provider.of<UserProvider>(context, listen: false).userDetail;
      await Provider.of<OrderProvider>(context, listen: false).getOrders(user.category, user.city, user.shopDocId);
      calculateSales();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Order history'),
        backgroundColor: kBlue2,
        leading: InkWell(
          onTap: () {
            Navigator.pushNamed(context, 'home');
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: orderProvider.isLoading
          ? Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: kBlue1,
              ),
            )
          : orderProvider.ordersList.isEmpty
              ? Center(
                  child: Text('No orders yet!'),
                )
              : Container(
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54, width: 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Sales', style: kShopNameTextStyle),
                                Text('₹ ' + totalSales.toString(), style: kShopNameTextStyle),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Orders', style: kShopNameTextStyle),
                                Text(orderProvider.ordersList.length.toString(), style: kShopNameTextStyle),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('This month sales', style: kShopNameTextStyle),
                                Text('₹ ' + monthSales.toString(), style: kShopNameTextStyle),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            var order = orderProvider.ordersList[index];
                            return Card(
                                elevation: 5,
                                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.completed ? 'Completed' : 'Not Completed',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Time : ' + order.orderTime.toDate().toString(),
                                      ),
                                      SizedBox(height: 10),
                                      Text('Item Name : ' + order.itemName),
                                      SizedBox(height: 10),
                                      Text('Total amount : ₹' + order.itemPrice),
                                      SizedBox(height: 10),
                                      Text('Buyer Name : ' + order.buyerName),
                                      SizedBox(height: 20),
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: GradientButton(
                                          name: 'Process Order',
                                          onTapFunc: () {
                                            orderProvider.detailOrder = order;
                                            Navigator.pushNamed(context, 'orderDetails');
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ));
                          },
                          itemCount: orderProvider.ordersList.length,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
