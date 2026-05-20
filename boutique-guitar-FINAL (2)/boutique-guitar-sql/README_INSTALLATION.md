# Guide d'installation — Côté serveur Oracle

## Ordre d'exécution des scripts

Exécuter **dans cet ordre exact** dans SQL Developer ou SQLPlus :

| # | Fichier | Description |
|---|---------|-------------|
| 1 | `01_creation_tables.sql` | Tables, contraintes, commentaires |
| 2 | `02_sequences_triggers.sql` | Séquences et déclencheurs auto-incrément |
| 3 | `03_pkg_fabricants.sql` | Package PL/SQL — Fabricants |
| 4 | `04_pkg_clients.sql` | Package PL/SQL — Clients |
| 5 | `05_pkg_produits.sql` | Package PL/SQL — Produits |
| 6 | `06_pkg_paniers.sql` | Package PL/SQL — Paniers |
| 7 | `07_ords_configuration.sql` | Points de terminaison ORDS |
| 8 | `08_donnees_initiales.sql` | Données de démarrage |
| 9 | `09_tests_unitaires.sql` | Suites de tests utPLSQL |

---

## Prérequis

- Oracle Database 19c ou supérieur
- Oracle REST Data Services (ORDS) 22.x ou supérieur
- APEX_JSON disponible dans le schéma (inclus avec APEX ou via DBMS_JSON)
- utPLSQL installé pour les tests unitaires : https://utplsql.org

---

## Points de terminaison REST générés

Une fois le script 07 exécuté, les URLs suivantes sont disponibles :

### Fabricants
| Méthode | URL | Action |
|---------|-----|--------|
| `GET` | `/ords/{schema}/fabricants/` | Liste tous les fabricants |
| `GET` | `/ords/{schema}/fabricants/:id` | Retourne un fabricant |
| `POST` | `/ords/{schema}/fabricants/` | Crée un fabricant |
| `PUT` | `/ords/{schema}/fabricants/:id` | Modifie un fabricant |
| `DELETE` | `/ords/{schema}/fabricants/:id` | Supprime un fabricant |

### Clients
| Méthode | URL | Action |
|---------|-----|--------|
| `GET` | `/ords/{schema}/clients/` | Liste tous les clients |
| `GET` | `/ords/{schema}/clients/:id` | Retourne un client |
| `POST` | `/ords/{schema}/clients/` | Crée un client |
| `PUT` | `/ords/{schema}/clients/:id` | Modifie un client |
| `DELETE` | `/ords/{schema}/clients/:id` | Supprime un client |

### Produits
| Méthode | URL | Action |
|---------|-----|--------|
| `GET` | `/ords/{schema}/produits/` | Liste tous les produits |
| `GET` | `/ords/{schema}/produits/:id` | Retourne un produit |
| `GET` | `/ords/{schema}/produits/fabricant/:id_manu` | Filtre par fabricant |
| `POST` | `/ords/{schema}/produits/` | Crée un produit |
| `PUT` | `/ords/{schema}/produits/:id` | Modifie un produit |
| `DELETE` | `/ords/{schema}/produits/:id` | Supprime un produit |

### Paniers
| Méthode | URL | Action |
|---------|-----|--------|
| `GET` | `/ords/{schema}/paniers/` | Liste tous les paniers |
| `GET` | `/ords/{schema}/paniers/:id` | Retourne un panier |
| `GET` | `/ords/{schema}/paniers/client/:id_client` | Paniers d'un client |
| `POST` | `/ords/{schema}/paniers/` | Crée un panier |
| `PUT` | `/ords/{schema}/paniers/:id` | Modifie un panier |
| `DELETE` | `/ords/{schema}/paniers/:id` | Supprime un panier |

---

## Connecter le front-end

Dans `js/api.js`, mettre à jour :

```javascript
const API_CONFIG = {
  BASE_URL:  'http://localhost:8080/ords/VOTRE_SCHEMA',
  MOCK_MODE: false,
};
```

---

## Lancer les tests unitaires

```sql
-- Un seul package
EXEC ut.run('test_pkg_fabricants');
EXEC ut.run('test_pkg_clients');
EXEC ut.run('test_pkg_produits');
EXEC ut.run('test_pkg_paniers');

-- Tous en une seule commande
EXEC ut.run();
```

### Scénarios couverts (39 tests au total)

| Package | Tests |
|---------|-------|
| Fabricants | GET all, CREATE valide, CREATE nom vide, GET by ID, GET ID inexistant, UPDATE valide, UPDATE inexistant, DELETE valide, DELETE inexistant |
| Clients | GET all, CREATE valide, CREATE nom vide, GET by ID, GET ID inexistant, UPDATE valide, UPDATE inexistant, DELETE valide, DELETE cascade paniers, DELETE inexistant |
| Produits | GET all, CREATE avec fabricant, CREATE sans fabricant, CREATE nom vide, CREATE prix négatif, GET by ID, GET ID inexistant, GET by fabricant, UPDATE valide, UPDATE inexistant, DELETE valide, DELETE inexistant |
| Paniers | GET all, CREATE valide, CREATE sans client, CREATE client inexistant, GET by ID, GET ID inexistant, GET by client, UPDATE valide, UPDATE inexistant, DELETE valide, DELETE inexistant |

---

## Codes d'erreur PL/SQL

| Code | Package | Message |
|------|---------|---------|
| `-20001` | pkg_fabricants | Fabricant introuvable |
| `-20002` | pkg_fabricants | Nom du fabricant obligatoire |
| `-20003` | pkg_fabricants | Fabricant possède des produits |
| `-20011` | pkg_clients | Client introuvable |
| `-20012` | pkg_clients | Nom du client obligatoire |
| `-20021` | pkg_produits | Produit introuvable |
| `-20022` | pkg_produits | Nom du produit obligatoire |
| `-20023` | pkg_produits | Prix invalide (négatif ou nul) |
| `-20031` | pkg_paniers | Panier introuvable |
| `-20032` | pkg_paniers | ID client obligatoire |
| `-20033` | pkg_paniers | Client référencé inexistant |
