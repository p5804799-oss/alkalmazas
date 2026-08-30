import 'package:flutter/material.dart';

class RecipeItem {
  final String id;
  final String name;
  final String category;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String prepTime;
  final List<String> ingredients;
  final String instructions;

  const RecipeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.prepTime,
    required this.ingredients,
    required this.instructions,
  });
}

const List<RecipeItem> kBuiltInRecipes = [
  RecipeItem(
    id: 'rec_1',
    name: 'Csirkemell Jázmin Rizzsel & Párolt Brokkolival',
    category: 'Ebéd / Vacsora',
    calories: 520,
    protein: 52,
    carbs: 58,
    fat: 8,
    prepTime: '25 perc',
    ingredients: ['200g Csirkemell filé', '70g Jázmin rizs (szárazon)', '150g Brokkoli', '5ml Olívaolaj', 'Fűszerek ízlés szerint'],
    instructions: 'A csirkemellet csíkokra vágjuk, fűszerezzük és kevés olajon aranybarnára pirítjuk. A rizst kétszeres vízben megfőzzük, a brokkolit 6 perc alatt roppanósra gőzöljük.',
  ),
  RecipeItem(
    id: 'rec_2',
    name: 'Fehérjés Zabkása Erdei Gyümölcsökkel',
    category: 'Reggeli',
    calories: 410,
    protein: 36,
    carbs: 48,
    fat: 7,
    prepTime: '10 perc',
    ingredients: ['60g Zabpehely', '30g Tejsavófehérje por', '150ml Víz vagy Mandulatej', '50g Erdei gyümölcs', '1 tk Fahéj'],
    instructions: 'A zabpelyhet forró vízzel vagy tejjel puhára főzzük, lehúzzuk a tűzről, hozzákeverjük a fehérjeport és megszórjuk a gyümölcsökkel.',
  ),
  RecipeItem(
    id: 'rec_3',
    name: 'Marhahúsos Édesburgonya Tál',
    category: 'Ebéd / Vacsora',
    calories: 610,
    protein: 48,
    carbs: 62,
    fat: 16,
    prepTime: '30 perc',
    ingredients: ['180g Sovány darált marhahús (max 10%)', '220g Édesburgonya', '100g Zöldbab', 'Só, Bors, Fokhagyma'],
    instructions: 'Az édesburgonyát kockákra vágva sütőben megsütjük. A darált marhát fokhagymával megpirítjuk, majd a zöldbabbal egy tálban tálaljuk.',
  ),
  RecipeItem(
    id: 'rec_4',
    name: 'Lazacfilé Quinoával & Avokádókrémmel',
    category: 'Ebéd / Vacsora',
    calories: 580,
    protein: 42,
    carbs: 40,
    fat: 26,
    prepTime: '20 perc',
    ingredients: ['170g Friss lazacfilé', '60g Quinoa', '50g Érett avokádó', 'Citromlé, Tengeri só'],
    instructions: 'A lazacot forró serpenyőben mindkét oldalán 4-4 percig sütjük. A quinoát megfőzzük, az avokádót villával áttörve citrommal ízesítjük.',
  ),
  RecipeItem(
    id: 'rec_5',
    name: 'Zsírszegény Túrókrém Mandulával & Mézzel',
    category: 'Snack / Esti étkezés',
    calories: 320,
    protein: 38,
    carbs: 18,
    fat: 10,
    prepTime: '5 perc',
    ingredients: ['250g Zsírszegény tehéntúró', '100g Görög joghurt (0%)', '15g Szeletelt mandula', '1 tk Méz'],
    instructions: 'A túrót a görög joghurttal és a mézzel krémesre keverjük, a tetejét megszórjuk pirított mandulával.',
  ),
];
