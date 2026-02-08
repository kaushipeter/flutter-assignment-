class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final bool isFeatured;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.isFeatured,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['image'],
      isFeatured: json['isFeatured'] == 1 || json['isFeatured'] == true || json['isFeatured'] == '1',
      category: json['category'] ?? 'Uncategorized',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'isFeatured': isFeatured,
      'category': category,
    };
  }
}

// Dummy data based on Laravel project content
final List<Product> dummyProducts = [
  Product(
    id: 1,
    name: 'Amberelle',
    description: 'A warm, inviting scent with notes of amber and vanilla.',
    price: 4500.00,
    image: 'amberelle.jpg',
    isFeatured: true,
    category: 'Women',
  ),
  Product(
    id: 2,
    name: 'Noir',
    description: 'Deep and mysterious, featuring dark wood and spice.',
    price: 5200.00,
    image: 'noir.jpg',
    isFeatured: true,
    category: 'Men',
  ),
  Product(
    id: 3,
    name: 'Fresh',
    description: 'Crisp and clean, like a morning breeze.',
    price: 3800.00,
    image: 'fresh.jpg',
    isFeatured: true,
    category: 'Women',
  ),
  Product(
    id: 4,
    name: 'Emberlace',
    description: 'Smoky and sophisticated.',
    price: 4800.00,
    image: 'emberlace.jpg',
    isFeatured: false,
    category: 'Gifts',
  ),
  Product(
    id: 5,
    name: 'Lollipop',
    description: 'Sweet and playful for younger audiences.',
    price: 2500.00,
    image: 'lollipop.jpg',
    isFeatured: false,
    category: 'Kids',
  ),
];
