# Attribute von RecipeEditPage
- id: Grau hinterlegt innen, nicht editierbar
- title: ✓
- tags: Außerhalb
- image_id: Außen (✓) und Innen
- description: ✓
- time_prep: ✓
- time_total: ✓
- portions: ✓
- recipe_uri: ✓
- ingredients: ✓
- nutritions: ✓
- user_notes: Außen
- ratings: Außen
- created_at / updated_at: Grau hinterlegt außen, nicht editierbar

# Was noch zu tun ist:
- MyRecipePage nach Erstellung eines neuen Rezeptes updaten
- RecipeOverviewPage Update Methode implementieren
- Für JSON Verarbeitung anschauen: https://docs.flutter.dev/data-and-backend/serialization/json
- BUG: Wenn man "amount" bei Ingredient oder Nutrition auf einen nicht-double Wert setzt, geht es trotzdem durch?!