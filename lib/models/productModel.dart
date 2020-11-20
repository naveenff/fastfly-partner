class ProductModel {
  String name;
  List<String> image;
  List<String> colors;
  List<String> sizes;
  String description;
  String price;
  String mrp;
  String quantity;
  int gst;
  String docId;

  ProductModel({
    this.description,
    this.docId,
    this.gst,
    this.image,
    this.colors,
    this.sizes,
    this.quantity,
    this.mrp,
    this.price,
    this.name,
  });
}
