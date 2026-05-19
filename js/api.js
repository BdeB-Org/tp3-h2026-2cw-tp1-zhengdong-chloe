/*
  api.js — Couche de communication avec l'API Oracle ORDS
 Boutique Guitare — TP3
 
 */

'use strict';

/*configuration */
const API_CONFIG = {
  // URL de base de votre API Oracle ORDS
  BASE_URL: 'http://localhost:8080/ords/boutiqueguitar',


  MOCK_MODE: true,
};

/* DONNÉES INITIALES */
const INITIAL_DATA = {
  fabricants: [
    { id_manu: 1, nom_manu: 'Gibson',  telephone: '1-800-444-2766' },
    { id_manu: 2, nom_manu: 'Fender',  telephone: '1-800-856-9801' },
    { id_manu: 3, nom_manu: 'Martin',  telephone: '1-888-343-5842' },
    { id_manu: 4, nom_manu: 'Taylor',  telephone: '1-619-258-1207' },
  ],
  clients: [
    { id_client: 1, nom_client: 'Lefebvre, Marc',    telephone: '514-555-0101', address: '12 rue Saint-Denis, Montréal' },
    { id_client: 2, nom_client: 'Tremblay, Sophie',  telephone: '438-555-0202', address: '45 boul. Saint-Laurent, Laval' },
    { id_client: 3, nom_client: 'Côté, Jean-Pierre', telephone: '450-555-0303', address: '88 avenue des Érables, Longueuil' },
  ],
  produits: [
    { id_produit: 1, nom_produit: 'Gibson Les Paul Standard 60s',   prix_produit: 3499.99, id_manu: 1 },
    { id_produit: 2, nom_produit: 'Gibson SG Standard',              prix_produit: 1999.99, id_manu: 1 },
    { id_produit: 3, nom_produit: 'Gibson J-45 Acoustique',          prix_produit: 2899.99, id_manu: 1 },
    { id_produit: 4, nom_produit: 'Fender Stratocaster Player',      prix_produit: 1149.99, id_manu: 2 },
    { id_produit: 5, nom_produit: 'Fender Telecaster Professional',  prix_produit: 1999.00, id_manu: 2 },
    { id_produit: 6, nom_produit: 'Martin D-28 Acoustique',          prix_produit: 3999.99, id_manu: 3 },
    { id_produit: 7, nom_produit: 'Taylor 314ce Grand Auditorium',   prix_produit: 2499.99, id_manu: 4 },
  ],
  paniers: [
    { id_panier: 1, date_creation: '2026-04-10', id_client: 1 },
    { id_panier: 2, date_creation: '2026-04-22', id_client: 2 },
    { id_panier: 3, date_creation: '2026-05-05', id_client: 3 },
  ],
};

/* INITIALISATION DU Mock */
const DB_KEY = 'boutique_guitar_db';

function _initMockDB() {
  const stored = localStorage.getItem(DB_KEY);
  if (!stored) {
    localStorage.setItem(DB_KEY, JSON.stringify(INITIAL_DATA));
  }
}

function _getMockDB() {
  return JSON.parse(localStorage.getItem(DB_KEY) || '{}');
}

function _saveMockDB(db) {
  localStorage.setItem(DB_KEY, JSON.stringify(db));
}

function _nextId(items, pkField) {
  if (!items || items.length === 0) return 1;
  return Math.max(...items.map(i => i[pkField] || 0)) + 1;
}

/* MOCK API — simule Oracle ORDS*/
const MockAPI = {
  async getAll(entite) {
    await _delay(120);
    const db = _getMockDB();
    const items = db[entite] || [];
    // Simule le format de réponse ORDS : { items: [...], count: N }
    return { items: [...items], count: items.length };
  },

  async getById(entite, id) {
    await _delay(80);
    const db = _getMockDB();
    const pkField = _getPkField(entite);
    const item = (db[entite] || []).find(i => i[pkField] == id);
    if (!item) throw new Error(`Entrée ${id} introuvable dans ${entite}`);
    return { ...item };
  },

  async create(entite, donnees) {
    await _delay(150);
    const db = _getMockDB();
    const pkField = _getPkField(entite);
    if (!db[entite]) db[entite] = [];
    const newItem = { ...donnees, [pkField]: _nextId(db[entite], pkField) };
    db[entite].push(newItem);
    _saveMockDB(db);
    return { ...newItem };
  },

  async update(entite, id, donnees) {
    await _delay(130);
    const db = _getMockDB();
    const pkField = _getPkField(entite);
    const idx = (db[entite] || []).findIndex(i => i[pkField] == id);
    if (idx === -1) throw new Error(`Entrée ${id} introuvable dans ${entite}`);
    const updated = { ...db[entite][idx], ...donnees, [pkField]: Number(id) };
    db[entite][idx] = updated;
    _saveMockDB(db);
    return { ...updated };
  },

  async remove(entite, id) {
    await _delay(100);
    const db = _getMockDB();
    const pkField = _getPkField(entite);
    const before = (db[entite] || []).length;
    db[entite] = (db[entite] || []).filter(i => i[pkField] != id);
    if (db[entite].length === before) throw new Error(`Entrée ${id} introuvable dans ${entite}`);
    _saveMockDB(db);
    return { deleted: true };
  },
};

/* API RÉELLE — appels Oracle ORDS via fetch()*/
const RealAPI = {
  async getAll(entite) {
    const res = await fetch(`${API_CONFIG.BASE_URL}/${entite}/`, {
      method: 'GET',
      headers: { 'Accept': 'application/json' },
    });
    if (!res.ok) throw new Error(`Erreur HTTP ${res.status} — ${entite}`);
    return await res.json(); // ORDS retourne { items: [...], ... }
  },

  async getById(entite, id) {
    const pkField = _getPkField(entite);
    const res = await fetch(`${API_CONFIG.BASE_URL}/${entite}/${id}`, {
      method: 'GET',
      headers: { 'Accept': 'application/json' },
    });
    if (!res.ok) throw new Error(`Erreur HTTP ${res.status}`);
    return await res.json();
  },

  async create(entite, donnees) {
    const res = await fetch(`${API_CONFIG.BASE_URL}/${entite}/`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify(donnees),
    });
    if (!res.ok) throw new Error(`Erreur HTTP ${res.status} — création impossible`);
    return await res.json();
  },

  async update(entite, id, donnees) {
    const res = await fetch(`${API_CONFIG.BASE_URL}/${entite}/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify(donnees),
    });
    if (!res.ok) throw new Error(`Erreur HTTP ${res.status} — mise à jour impossible`);
    return await res.json();
  },

  async remove(entite, id) {
    const res = await fetch(`${API_CONFIG.BASE_URL}/${entite}/${id}`, {
      method: 'DELETE',
      headers: { 'Accept': 'application/json' },
    });
    if (!res.ok) throw new Error(`Erreur HTTP ${res.status} — suppression impossible`);
    // ORDS retourne 200 avec corps vide ou JSON
    const text = await res.text();
    return text ? JSON.parse(text) : { deleted: true };
  },
};

/* API PUBLIQUE — fonctions exportées  Aucun fetch() ne doit exister en dehors de ce fichier.*/

/* Récupère tous les enregistrements d'une entité */
async function getAll(entite) {
  return API_CONFIG.MOCK_MODE
    ? MockAPI.getAll(entite)
    : RealAPI.getAll(entite);
}

/* Récupère un enregistrement par son identifiant */
async function getById(entite, id) {
  return API_CONFIG.MOCK_MODE
    ? MockAPI.getById(entite, id)
    : RealAPI.getById(entite, id);
}

/* Crée un nouvel enregistrement */
async function create(entite, donnees) {
  return API_CONFIG.MOCK_MODE
    ? MockAPI.create(entite, donnees)
    : RealAPI.create(entite, donnees);
}

/* Met à jour un enregistrement existant */
async function update(entite, id, donnees) {
  return API_CONFIG.MOCK_MODE
    ? MockAPI.update(entite, id, donnees)
    : RealAPI.update(entite, id, donnees);
}

/* Supprime un enregistrement */
async function remove(entite, id) {
  return API_CONFIG.MOCK_MODE
    ? MockAPI.remove(entite, id)
    : RealAPI.remove(entite, id);
}

/* UTILITAIRES INTERNES */
function _getPkField(entite) {
  const pks = {
    clients:    'id_client',
    produits:   'id_produit',
    fabricants: 'id_manu',
    paniers:    'id_panier',
  }; 
  return pks[entite] || 'id';
}

function _delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/* Initialisation au chargement */
if (API_CONFIG.MOCK_MODE) _initMockDB();

/* Expose l'état */
function getModeLabel() {
  return API_CONFIG.MOCK_MODE ? 'mock' : 'live';
}
