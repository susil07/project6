import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  print('🌱 TastyGo - Firestore Data Seeding Script');
  print('==========================================\n');

  // Initialize Firestore
  // Note: This script should be run AFTER configuring Firebase
  final firestore = FirebaseFirestore.instance;

  // Sample food items
  final sampleFoodItems = [
    {
      'id': 'item_1',
      'name': 'Veggie tomato mix',
      'price': 'N1,900',
      'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
      'category': 'Foods',
      'description':
          'A healthy mix of fresh vegetables with tomato sauce, perfect for a light meal.',
      'rating': 4.5,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'item_2',
      'name': 'Egg and plantain',
      'price': 'N2,300',
      'imageUrl': 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543',
      'category': 'Foods',
      'description':
          'Perfectly fried plantain served with scrambled eggs, a Nigerian classic.',
      'rating': 4.3,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'item_3',
      'name': 'Fish stew pot',
      'price': 'N2,500',
      'imageUrl': 'https://images.unsplash.com/photo-1541544741938-2af30898a887',
      'category': 'Foods',
      'description':
          'Rich and flavorful fish stew with traditional spices,prepared fresh daily.',
      'rating': 4.7,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'item_4',
      'name': 'Fried chicken wings',
      'price': 'N3,000',
      'imageUrl': 'https://images.unsplash.com/photo-1567620905732-2d1ec7bb7445',
      'category': 'Foods',
      'description':
          'Crispy golden chicken wings seasoned to perfection with special spices.',
      'rating': 4.8,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'item_5',
      'name': 'Tropical juice',
      'price': 'N1,200',
      'imageUrl': 'https://images.unsplash.com/photo-1621506289937-48e498495058',
      'category': 'Drinks',
      'description':
          'Refreshing tropical juice blend with mango, pineapple, and passion fruit.',
      'rating': 4.6,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'item_6',
      'name': 'Jollof Rice Special',
      'price': 'N2,800',
      'imageUrl': 'https://images.unsplash.com/photo-1569062818782-ed90023bc1c1',
      'category': 'Foods',
      'description':
          'Our signature jollof rice cooked with premium ingredients and served with chicken.',
      'rating': 4.9,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'item_7',
      'name': 'Suya Platter',
      'price': 'N3,500',
      'imageUrl': 'https://images.unsplash.com/photo-1544025162-d76694265947',
      'category': 'Foods',
      'description':
          'Spicy grilled beef skewers with traditional suya spice blend.',
      'rating': 4.7,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'item_8',
      'name': 'Chapman',
      'price': 'N1,500',
      'imageUrl': 'https://images.unsplash.com/photo-1551538827-9c037cb4f32a',
      'category': 'Drinks',
      'description':
          'Nigerian favorite cocktail with a perfect blend of fruits and carbonated drinks.',
      'rating': 4.4,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'item_9',
      'name': 'Meat Pie',
      'price': 'N800',
      'imageUrl': 'https://images.unsplash.com/photo-1509315811345-672d83ef2fbc',
      'category': 'Snacks',
      'description':
          'Flaky pastry filled with seasoned minced meat and vegetables.',
      'rating': 4.2,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'item_10',
      'name': 'Puff Puff',
      'price': 'N500',
      'imageUrl': 'https://images.unsplash.com/photo-1514517521153-1be72277b32f',
      'category': 'Snacks',
      'description':
          'Sweet deep-fried dough balls, perfect for snacking anytime.',
      'rating': 4.5,
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  try {
    print('📝 Adding ${sampleFoodItems.length} food items to Firestore...\n');

    for (var item in sampleFoodItems) {
      await firestore.collection('food_items').doc(item['id'] as String).set(item);
      print('✅ Added: ${item['name']}');
    }

    print('\n🎉 Seed data added successfully!');
    print('📊 Total items: ${sampleFoodItems.length}');
    print('\nYou can now run your app and see the food items!');
  } catch (e) {
    print('\n❌ Error seeding data: $e');
    print('\nMake sure:');
    print('1. Firebase is properly configured');
    print('2. Firestore database is created');
    print('3. You have internet connection');
  }

  exit(0);
}
