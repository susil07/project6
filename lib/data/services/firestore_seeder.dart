import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_go/data/models/food_item_model.dart';

class FirestoreSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedFoodItems() async {
    final sampleFoodItems = [
      {
        'id': 'item_1',
        'name': 'Veggie tomato mix',
        'price': 'N1,900',
        'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
        'category': 'Foods',
        'description': 'A healthy mix of fresh vegetables with tomato sauce, perfect for a light meal.',
        'rating': 4.5,
      },
      {
        'id': 'item_2',
        'name': 'Egg and plantain',
        'price': 'N2,300',
        'imageUrl': 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400',
        'category': 'Foods',
        'description': 'Perfectly fried plantain served with scrambled eggs, a Nigerian classic.',
        'rating': 4.3,
      },
      {
        'id': 'item_3',
        'name': 'Fish stew pot',
        'price': 'N2,500',
        'imageUrl': 'https://images.unsplash.com/photo-1541544741938-2af30898a887?w=400',
        'category': 'Foods',
        'description': 'Rich and flavorful fish stew with traditional spices, prepared fresh daily.',
        'rating': 4.7,
      },
      {
        'id': 'item_4',
        'name': 'Fried chicken wings',
        'price': 'N3,000',
        'imageUrl': 'https://images.unsplash.com/photo-1567620905732-2d1ec7bb7445?w=400',
        'category': 'Foods',
        'description': 'Crispy golden chicken wings seasoned to perfection with special spices.',
        'rating': 4.8,
      },
      {
        'id': 'item_5',
        'name': 'Tropical juice',
        'price': 'N1,200',
        'imageUrl': 'https://images.unsplash.com/photo-1621506289937-48e498495058?w=400',
        'category': 'Drinks',
        'description': 'Refreshing tropical juice blend with mango, pineapple, and passion fruit.',
        'rating': 4.6,
      },
      {
        'id': 'item_6',
        'name': 'Jollof Rice Special',
        'price': 'N2,800',
        'imageUrl': 'https://images.unsplash.com/photo-1569062718239-1beea1c3f725?w=400',
        'category': 'Foods',
        'description': 'Our signature jollof rice cooked with premium ingredients and served with chicken.',
        'rating': 4.9,
      },
      {
        'id': 'item_7',
        'name': 'Suya Platter',
        'price': 'N3,500',
        'imageUrl': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
        'category': 'Foods',
        'description': 'Spicy grilled beef skewers with traditional suya spice blend.',
        'rating': 4.7,
      },
      {
        'id': 'item_8',
        'name': 'Chapman',
        'price': 'N1,500',
        'imageUrl': 'https://images.unsplash.com/photo-1551538827-9c037cb4f32a?w=400',
        'category': 'Drinks',
        'description': 'Nigerian favorite cocktail with a perfect blend of fruits and carbonated drinks.',
        'rating': 4.4,
      },
      {
        'id': 'item_9',
        'name': 'Meat Pie',
        'price': 'N800',
        'imageUrl': 'https://images.unsplash.com/photo-1509315811345-672d83ef2fbc?w=400',
        'category': 'Snacks',
        'description': 'Flaky pastry filled with seasoned minced meat and vegetables.',
        'rating': 4.2,
      },
      {
        'id': 'item_10',
        'name': 'Puff Puff',
        'price': 'N500',
        'imageUrl': 'https://images.unsplash.com/photo-1587241321921-91erta42d70d?w=400',
        'category': 'Snacks',
        'description': 'Sweet deep-fried dough balls, perfect for snacking anytime.',
        'rating': 4.5,
      },
    ];

    try {
      for (var item in sampleFoodItems) {
        final foodItem = FoodItemModel(
          id: item['id'] as String,
          name: item['name'] as String,
          price: item['price'] as String,
          imageUrl: item['imageUrl'] as String,
          category: item['category'] as String,
          description: item['description'] as String,
          rating: (item['rating'] as num).toDouble(),
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('food_items')
            .doc(foodItem.id)
            .set(foodItem.toJson());
      }
      
      return;
    } catch (e) {
      throw Exception('Failed to seed data: $e');
    }
  }

  Future<bool> checkIfDataExists() async {
    final snapshot = await _firestore.collection('food_items').limit(1).get();
    return snapshot.docs.isNotEmpty;
  }
}
