# 🎸 Boutique Guitare — TP3

**Application web dynamique — 420-2CW-BB · Hiver 2026**  
Chloé Svantner & Cen Zhengdong — Collège Bois-de-Boulogne

---

## Structure du projet

```
boutique-guitar/
├── index.html          → Page d'accueil (tableau de bord)
├── clients.html        → Gestion des clients (CRUD complet)
├── produits.html       → Catalogue de produits (CRUD complet)
├── fabricants.html     → Gestion des fabricants (CRUD complet)
├── paniers.html        → Gestion des paniers (CRUD complet)
├── css/
│   └── style.css       → Feuille de styles globale (thème sombre)
└── js/
    ├── api.js          → Couche API centralisée (fetch + mock ORDS)
    ├── clients.js      → Logique DOM — Clients
    ├── produits.js     → Logique DOM — Produits
    ├── fabricants.js   → Logique DOM — Fabricants
    └── paniers.js      → Logique DOM — Paniers
```

---

## Démarrage rapide

### Mode simulé (par défaut)
Aucune configuration requise. Ouvrir avec **Live Server** dans VS Code.

### Mode Oracle ORDS réel
1. Démarrer Oracle ORDS sur votre serveur
2. Ouvrir `js/api.js`
3. Modifier la configuration :
   ```js
   const API_CONFIG = {
     BASE_URL: 'http://localhost:8080/ords/VOTRE_SCHEMA',
     MOCK_MODE: false,  // ← mettre à false
   };
   ```
4. S'assurer que les tables ORDS suivantes sont activées :
   - `clients`  → id_client, nom_client, telephone, address
   - `produits` → id_produit, nom_produit, prix_produit, id_manu
   - `fabricants` → id_manu, nom_manu, telephone
   - `paniers` → id_panier, date_creation, id_client

---

## Fonctionnalités

| Page         | Affichage | Ajout | Modification | Suppression |
|--------------|:---------:|:-----:|:------------:|:-----------:|
| Clients      | ✅        | ✅    | ✅           | ✅          |
| Produits     | ✅        | ✅    | ✅           | ✅          |
| Fabricants   | ✅        | ✅    | ✅           | ✅          |
| Paniers      | ✅        | ✅    | ✅           | ✅          |

### Fonctionnalités supplémentaires
- 🔍 Recherche en temps réel sur toutes les pages
- 🎨 Thème sombre élégant
- 📱 Responsive (mobile-friendly)
- 💬 Notifications toast (succès / erreur)
- ✅ Dialogue de confirmation avant suppression
- 🔗 Jointure produits ↔ fabricants (affichage du nom du fabricant)
- 📅 Statut coloré des paniers selon l'ancienneté

---

## Architecture API (`api.js`)

Toutes les requêtes `fetch()` sont centralisées dans `api.js`.  
**Aucun `fetch()` direct dans les autres fichiers JS.**

```js
// Fonctions publiques disponibles :
getAll(entite)              // GET /ords/{schema}/{entite}/
getById(entite, id)         // GET /ords/{schema}/{entite}/{id}
create(entite, donnees)     // POST /ords/{schema}/{entite}/
update(entite, id, donnees) // PUT /ords/{schema}/{entite}/{id}
remove(entite, id)          // DELETE /ords/{schema}/{entite}/{id}
```

La réponse ORDS est au format : `{ items: [...], count: N }`

---

## Technologies

- HTML5 sémantique
- CSS3 (variables, flexbox, grid, animations)
- JavaScript vanilla ES6+ (async/await, fetch, DOM)
- Oracle ORDS (REST API automatique)
- Polices : Cinzel, Crimson Pro, JetBrains Mono (Google Fonts)

---

*Projet scolaire — Collège Bois-de-Boulogne*
