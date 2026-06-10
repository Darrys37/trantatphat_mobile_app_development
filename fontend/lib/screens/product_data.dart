  // product_data.dart
  // Shared data file – no leading underscore so it can be imported anywhere.

  const Map<String, Map<String, String>> categoryImages = {
    'Women': {
      'New':         'https://images.pexels.com/photos/1148957/pexels-photo-1148957.jpeg?auto=compress&w=400',
      'Clothes':     'https://images.pexels.com/photos/5632386/pexels-photo-5632386.jpeg?auto=compress&w=400',
      'Shoes':       'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?auto=compress&w=400',
      'Accessories': 'https://images.pexels.com/photos/1927259/pexels-photo-1927259.jpeg?auto=compress&w=400',
    },
    'Men': {
      'New':         'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&w=400',
      'Clothes':     'https://images.pexels.com/photos/1300550/pexels-photo-1300550.jpeg?auto=compress&w=400',
      'Shoes':       'https://images.pexels.com/photos/1280064/pexels-photo-1280064.jpeg?auto=compress&w=400',
      'Accessories': 'https://images.pexels.com/photos/190819/pexels-photo-190819.jpeg?auto=compress&w=400',
    },
    'Kids': {
      'New':         'https://images.pexels.com/photos/35537/child-children-girl-happy.jpg?auto=compress&w=400',
      'Clothes':     'https://images.pexels.com/photos/1619651/pexels-photo-1619651.jpeg?auto=compress&w=400',
      'Shoes':       'https://images.pexels.com/photos/1471437/pexels-photo-1471437.jpeg?auto=compress&w=400',
      'Accessories': 'https://images.pexels.com/photos/1620760/pexels-photo-1620760.jpeg?auto=compress&w=400',
    },
  };

  const Map<String, Map<String, List<Map<String, dynamic>>>> genderProducts = {
    'Women': {
      'T-shirts': [
        {'name': 'Pullover',       'brand': 'Mango',           'price': 51, 'oldPrice': null, 'rating': 4.5, 'reviews': 3,  'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg?auto=compress&w=400'},
        {'name': 'T-shirt',        'brand': 'Lime-shop',       'price': 12, 'oldPrice': null, 'rating': 4.0, 'reviews': 11, 'discount': null, 'isFavorite': true,  'image': 'https://images.pexels.com/photos/1021693/pexels-photo-1021693.jpeg?auto=compress&w=400'},
        {'name': 'Shirt',          'brand': 'Topshop',         'price': 51, 'oldPrice': null, 'rating': 4.0, 'reviews': 5,  'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/3622608/pexels-photo-3622608.jpeg?auto=compress&w=400'},
        {'name': 'T-Shirt SPANISH','brand': 'Mango',           'price': 9,  'oldPrice': null, 'rating': 4.0, 'reviews': 4,  'discount': 30,   'isFavorite': false, 'image': 'https://images.pexels.com/photos/2220316/pexels-photo-2220316.jpeg?auto=compress&w=400'},
      ],
      'Crop tops': [
        {'name': 'Crop Top',       'brand': 'Zara',            'price': 22, 'oldPrice': null, 'rating': 4.5, 'reviews': 7,  'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/1536619/pexels-photo-1536619.jpeg?auto=compress&w=400'},
        {'name': 'Ribbed Crop',    'brand': 'Mango',           'price': 18, 'oldPrice': 25,   'rating': 4.0, 'reviews': 5,  'discount': 28,   'isFavorite': false, 'image': 'https://images.pexels.com/photos/2065195/pexels-photo-2065195.jpeg?auto=compress&w=400'},
        {'name': 'Floral Crop',    'brand': 'H&M',             'price': 14, 'oldPrice': null, 'rating': 3.8, 'reviews': 3,  'discount': null, 'isFavorite': true,  'image': 'https://images.pexels.com/photos/1536619/pexels-photo-1536619.jpeg?auto=compress&w=400'},
      ],
      'Sleeveless': [
        {'name': 'Tank Top',       'brand': 'Nike',            'price': 19, 'oldPrice': null, 'rating': 4.3, 'reviews': 12, 'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/7691168/pexels-photo-7691168.jpeg?auto=compress&w=400'},
        {'name': 'Cami Top',       'brand': 'Topshop',         'price': 16, 'oldPrice': 22,   'rating': 4.0, 'reviews': 6,  'discount': 27,   'isFavorite': false, 'image': 'https://images.pexels.com/photos/1382731/pexels-photo-1382731.jpeg?auto=compress&w=400'},
        {'name': 'Vest Top',       'brand': 'Zara',            'price': 24, 'oldPrice': null, 'rating': 4.6, 'reviews': 4,  'discount': null, 'isFavorite': true,  'image': 'https://images.pexels.com/photos/1043473/pexels-photo-1043473.jpeg?auto=compress&w=400'},
      ],
      'Blouses': [
        {'name': 'Blouse',         'brand': 'Dorothy Perkins', 'price': 34, 'oldPrice': null, 'rating': 3.5, 'reviews': 6,  'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/1759622/pexels-photo-1759622.jpeg?auto=compress&w=400'},
        {'name': 'Light Blouse',   'brand': 'Topshop',         'price': 28, 'oldPrice': null, 'rating': 4.0, 'reviews': 9,  'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/2220316/pexels-photo-2220316.jpeg?auto=compress&w=400'},
        {'name': 'Silk Blouse',    'brand': 'Mango',           'price': 45, 'oldPrice': 60,   'rating': 4.7, 'reviews': 14, 'discount': 25,   'isFavorite': true,  'image': 'https://images.pexels.com/photos/1536619/pexels-photo-1536619.jpeg?auto=compress&w=400'},
      ],
    },
    'Men': {
      'T-shirts': [
        {'name': 'Classic Tee',    'brand': "Levi's",          'price': 25, 'oldPrice': null, 'rating': 4.3, 'reviews': 8,  'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg?auto=compress&w=400'},
        {'name': 'Graphic Tee',    'brand': 'H&M',             'price': 18, 'oldPrice': 24,   'rating': 4.0, 'reviews': 12, 'discount': 25,   'isFavorite': false, 'image': 'https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg?auto=compress&w=400'},
        {'name': 'Polo Shirt',     'brand': 'Ralph Lauren',    'price': 55, 'oldPrice': null, 'rating': 4.6, 'reviews': 6,  'discount': null, 'isFavorite': true,  'image': 'https://images.pexels.com/photos/3622608/pexels-photo-3622608.jpeg?auto=compress&w=400'},
        {'name': 'Basic Tee',      'brand': 'Zara',            'price': 15, 'oldPrice': null, 'rating': 3.8, 'reviews': 5,  'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/2220316/pexels-photo-2220316.jpeg?auto=compress&w=400'},
      ],
      'Crop tops': [
        {'name': 'Muscle Tee',     'brand': 'Nike',            'price': 22, 'oldPrice': null, 'rating': 4.2, 'reviews': 9,  'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/1752757/pexels-photo-1752757.jpeg?auto=compress&w=400'},
        {'name': 'Short Sleeve',   'brand': 'Adidas',          'price': 28, 'oldPrice': 35,   'rating': 4.5, 'reviews': 7,  'discount': 20,   'isFavorite': false, 'image': 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&w=400'},
      ],
      'Sleeveless': [
        {'name': 'Sleeveless Tee', 'brand': 'Under Armour',    'price': 20, 'oldPrice': null, 'rating': 4.1, 'reviews': 10, 'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/1124468/pexels-photo-1124468.jpeg?auto=compress&w=400'},
        {'name': 'Sport Vest',     'brand': 'Nike',            'price': 18, 'oldPrice': 25,   'rating': 4.4, 'reviews': 8,  'discount': 28,   'isFavorite': true,  'image': 'https://images.pexels.com/photos/1300550/pexels-photo-1300550.jpeg?auto=compress&w=400'},
      ],
      'Blouses': [
        {'name': 'Oxford Shirt',   'brand': 'Topman',          'price': 38, 'oldPrice': null, 'rating': 4.3, 'reviews': 11, 'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&w=400'},
        {'name': 'Linen Shirt',    'brand': 'Zara Man',        'price': 42, 'oldPrice': 55,   'rating': 4.6, 'reviews': 6,  'discount': 24,   'isFavorite': false, 'image': 'https://images.pexels.com/photos/1300550/pexels-photo-1300550.jpeg?auto=compress&w=400'},
      ],
    },
    'Kids': {
      'T-shirts': [
        {'name': 'Kids Tee',       'brand': 'Gap Kids',        'price': 12, 'oldPrice': null, 'rating': 4.5, 'reviews': 7,  'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/35537/child-children-girl-happy.jpg?auto=compress&w=400'},
        {'name': 'Cartoon Tee',    'brand': 'H&M Kids',        'price': 9,  'oldPrice': 14,   'rating': 4.2, 'reviews': 5,  'discount': 35,   'isFavorite': false, 'image': 'https://images.pexels.com/photos/1619651/pexels-photo-1619651.jpeg?auto=compress&w=400'},
        {'name': 'Stripe Tee',     'brand': 'Zara Kids',       'price': 14, 'oldPrice': null, 'rating': 4.0, 'reviews': 8,  'discount': null, 'isFavorite': true,  'image': 'https://images.pexels.com/photos/1620760/pexels-photo-1620760.jpeg?auto=compress&w=400'},
      ],
      'Crop tops': [
        {'name': 'Girls Crop',     'brand': 'H&M Kids',        'price': 11, 'oldPrice': null, 'rating': 4.3, 'reviews': 4,  'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/35537/child-children-girl-happy.jpg?auto=compress&w=400'},
      ],
      'Sleeveless': [
        {'name': 'Kids Vest',      'brand': 'Gap Kids',        'price': 10, 'oldPrice': null, 'rating': 4.1, 'reviews': 6,  'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/1619651/pexels-photo-1619651.jpeg?auto=compress&w=400'},
        {'name': 'Summer Top',     'brand': 'Zara Kids',       'price': 8,  'oldPrice': 12,   'rating': 4.0, 'reviews': 3,  'discount': 33,   'isFavorite': false, 'image': 'https://images.pexels.com/photos/1620760/pexels-photo-1620760.jpeg?auto=compress&w=400'},
      ],
      'Blouses': [
        {'name': 'Girls Blouse',   'brand': 'H&M Kids',        'price': 16, 'oldPrice': null, 'rating': 4.4, 'reviews': 5,  'discount': null, 'isFavorite': false, 'image': 'https://images.pexels.com/photos/35537/child-children-girl-happy.jpg?auto=compress&w=400'},
      ],
    },
  };