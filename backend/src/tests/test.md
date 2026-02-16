3 Gemischter Salat mit Hänchen
4 Rührei mit Vollkornbrot

             title             |   name   | stars 
-------------------------------+----------+-------
 Gemischter Salat mit Hähnchen | Florian  |   4.0
 Gemischter Salat mit Hähnchen | Patricia |   5.0
 Gemischter Salat mit Hähnchen | Mama     |   4.5
 Gemischter Salat mit Hähnchen | Papa     |   3.5
 Rührei mit Vollkornbrot       | Florian  |   3.0
 Rührei mit Vollkornbrot       | Patricia |   3.5
 Rührei mit Vollkornbrot       | Mama     |   2.5
 Rührei mit Vollkornbrot       | Papa     |   5.0

SELECT recipes.title, users.name, ratings.stars FROM ratings JOIN recipes ON ratings.recipe_id = recipes.id JOIN users ON ratings.user_id = users.id ORDER BY recipes.id, users.id;