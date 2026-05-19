 Boutique Guitare — TP3

Application web  420-2CW-BB 
Chloé Svantner & Cen Zhengdong — Collège Bois-de-Boulogne

Structure du projet


boutique-guitar/
  -index.html          
  -clients.html       
  -produits.html       
  -fabricants.html     
  -paniers.html    
  
   css/
     style.css       
   js/
    ├── api.js         
    ├── clients.js      
    ├── produits.js     
    ├── fabricants.js  
    └── paniers.js      




Aucune configuration requise. Ouvrir avec **Live Server** dans VS Code.

Mode Oracle ORDS réel
1. Démarrer Oracle ORDS sur votre serveur
2. Ouvrir `js/api.js`
3. Modifier la configuration :
     js
   const API_CONFIG = {
     BASE_URL: 'http://localhost:8080/ords/VOTRE_SCHEMA',
     MOCK_MODE: false,  // ← mettre à false
   };

 S'assurer que les tables ORDS suivantes sont activées :


*Projet scolaire — Collège Bois-de-Boulogne*
