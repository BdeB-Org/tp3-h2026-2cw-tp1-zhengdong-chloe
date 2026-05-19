#  Boutique Guitare — TP3

**Application web dynamique — 420-2CW-BB · Hiver 2026**  
Chloé Svantner & Cen Zhengdong — Collège Bois-de-Boulogne


Structure du projet

boutique-guitar/
├── index.html          - Page d'accueil 
├── clients.html        - Gestion des clients 
├── produits.html       - Catalogue de produits 
├── fabricants.html     - Gestion des fabricants 
├── paniers.html        - Gestion des paniers 
├── css/
│   └── style.css       - style 
└── js/

├── api.js          
├── clients.js      
├── produits.js    
├── fabricants.js   
└── paniers.js      



 Mode simulé 
 Ouvrir avec **Live Server** dans VS Code.

 Mode Oracle ORDS réel
1. Démarrer Oracle ORDS sur votre serveur
2. Ouvrir `js/api.js`
3. Modifier la configuration :
   ```js
   const API_CONFIG = {
     BASE_URL: 'http://localhost:8080/ords/VOTRE_SCHEMA',
     MOCK_MODE: false,  // - mettre à false
   };
   
4. S'assurer que les tables ORDS son activées :
 `clients` 
 `produits` 
`fabricants` 
 `paniers` 


Architecture API (`api.js`)

Toutes les requêtes `fetch()` sont centralisées dans `api.js`.  
**Aucun `fetch()` direct dans les autres fichiers JS.**


*TP3 — Collège Bois-de-Boulogne*
