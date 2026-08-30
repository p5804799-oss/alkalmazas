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
    name: 'Pikok Pure Csirkemell Sonka Szendvics',
    category: 'Reggeli / Snack',
    calories: 340,
    protein: 38,
    carbs: 32,
    fat: 4,
    prepTime: '5 perc',
    ingredients: ['100g Pikok Pure csirkemell sonka', '80g Lidl teljes kiőrlésű zsemle', '50g Kígyóuborka'],
    instructions: 'A zsemlét megkenjük, ráhalmozzuk a sonkát és uborkával fogyasztjuk.',
  ),
  RecipeItem(
    id: 'lidl_2',
    name: 'Pilos Zsírszegény Túró Erdei Gyümölccsel',
    category: 'Reggeli',
    calories: 390,
    protein: 44,
    carbs: 45,
    fat: 3,
    prepTime: '8 perc',
    ingredients: ['250g Pilos zsírszegény túró (0.2%)', '50g Zabpehely', '15g Méz', '50g Erdei gyümölcs'],
    instructions: 'A túrót összekeverjük a zabpehellyel és a gyümölcsökkel.',
  ),
  RecipeItem(
    id: 'lidl_3',
    name: 'Lidl Friss Csirkemellfilé Jázmin Rizzsel',
    category: 'Ebéd / Vacsora',
    calories: 540,
    protein: 56,
    carbs: 60,
    fat: 6,
    prepTime: '25 perc',
    ingredients: ['200g Lidl csirkemell', '70g Jázmin rizs', '150g Zöldségkeverék'],
    instructions: 'A csirkemellet megsütjük, a rizst kifőzzük.',
  ),
  RecipeItem(
    id: 'lidl_4',
    name: 'Aligator Tonhalsaláta Teljes Kiőrlésű Pirítóssal',
    category: 'Ebéd / Snack',
    calories: 420,
    protein: 41,
    carbs: 34,
    fat: 12,
    prepTime: '10 perc',
    ingredients: ['1 doboz Aligator tonhal saját lében', '2 szelet Lidl toast kenyér', '30g Görög joghurt'],
    instructions: 'A tonhalat joghurttal összekeverjük és a pirítósra kenjük.',
  ),
];
