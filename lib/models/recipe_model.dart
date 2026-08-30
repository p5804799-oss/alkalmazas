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

const List<RecipeItem> kLidlExcelRecipes = [
  RecipeItem(
    id: 'lidl_1',
    name: 'Pikok Pure Csirkemell Sonka Szendvics Teljes Kiőrlésű Pékáruval',
    category: 'Reggeli / Snack',
    calories: 340,
    protein: 38,
    carbs: 32,
    fat: 4,
    prepTime: '5 perc',
    ingredients: ['100g Pikok Pure csirkemell sonka (96% hús)', '80g Lidl teljes kiőrlésű zsemle', '50g Kígyóuborka', 'Mustár'],
    instructions: 'A zsemlet félbevágjuk, megkenjük mustárral, ráhalmozzuk a magas fehérjetartalmú Pikok sonkát, és friss uborkával fogyasztjuk.',
  ),
  RecipeItem(
    id: 'lidl_2',
    name: 'Pilos Zsírszegény Túró Erdei Gyümölcsökkel & Zabpehellyel',
    category: 'Reggeli',
    calories: 390,
    protein: 44,
    carbs: 45,
    fat: 3,
    prepTime: '8 perc',
    ingredients: ['250g Pilos zsírszegény tehéntúró (0.2%)', '50g Alpro / Pilos zabpehely', '15g Lidl természetes méz', '50g Fagyasztott erdei gyümölcs keverék'],
    instructions: 'A túrót összekeverjük a zabpehellyel, meglocsoljuk mézzel, és ráborítjuk a megolvasztott bogyós gyümölcsöket.',
  ),
  RecipeItem(
    id: 'lidl_3',
    name: 'Lidl Friss Csirkemellfilé Jázmin Rizzsel & Zöldséggel',
    category: 'Ebéd / Vacsora',
    calories: 540,
    protein: 56,
    carbs: 60,
    fat: 6,
    prepTime: '25 perc',
    ingredients: ['200g Lidl friss csirkemell filé', '70g Jázmin rizs (száraz súly)', '150g Fagyasztott zöldségkeverék (sárgarépa, zöldborsó, kukorica)', '5ml Olívaolaj'],
    instructions: 'A csirkemellet felkockázzuk, sózzuk, borsozzuk, olívaolajon aranybarnára sütjük. A rizst kifőzzük, a zöldségeket megpároljuk.',
  ),
  RecipeItem(
    id: 'lidl_4',
    name: 'Lidl Aligator Tonhalsaláta Teljes Kiőrlésű Pirítóssal',
    category: 'Ebéd / Snack',
    calories: 420,
    protein: 41,
    carbs: 34,
    fat: 12,
    prepTime: '10 perc',
    ingredients: ['1 doboz Aligator tonhalkonzerv saját lében', '2 szelet Lidl teljes kiőrlésű toast kenyér', '30g Pilos görög joghurt', 'Lilahagyma, Citromlé'],
    instructions: 'A tonhalat lecsepegtetjük, összekeverjük görög joghurttal, apróra vágott lilahagymával és citromlével, majd pirítósra halmozzuk.',
  ),
  RecipeItem(
    id: 'lidl_5',
    name: 'Lidl Sovány Darált Marhahús Édesburgonya Hasábokkal',
    category: 'Ebéd / Vacsora',
    calories: 620,
    protein: 50,
    carbs: 65,
    fat: 18,
    prepTime: '30 perc',
    ingredients: ['180g Lidl sovány darált marhahús (max 10% zsír)', '200g Édesburgonya', 'Friss saláta', 'Fokhagyma, Só, Bors'],
    instructions: 'Az édesburgonyát hasábokra vágva sütőben megsütjük. A darált marhát serpenyőben fokhagymával és fűszerekkel megpirítjuk.',
  ),
  RecipeItem(
    id: 'lidl_6',
    name: 'Pilos Prosciutto Crudo & Mozzarella Saláta',
    category: 'Vacsora',
    calories: 410,
    protein: 36,
    carbs: 12,
    fat: 24,
    prepTime: '10 perc',
    ingredients: ['80g Pilos Prosciutto Crudo sonka', '125g Pilos Light Mozzarella', '100g Cseresznyeparadjesom', 'Bazsalikom, Balzsamecet'],
    instructions: 'A mozzarellát felkarikázzuk, tálra rendezzük a sonkával és a paradicsomokkal, majd balzsamecettel meglocsoljuk.',
  ),
];
