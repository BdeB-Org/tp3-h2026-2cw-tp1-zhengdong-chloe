/**
 * produits.js — Gestion des Produits
 * Manipulation du DOM et événements.
 * Tous les appels API passent par api.js.
 */

'use strict';

let _produits    = [];
let _fabricants  = [];
let _modeEdition = false;
let _idEdition   = null;
let _idSupprimer = null;

document.addEventListener('DOMContentLoaded', () => {
  chargerTout();
  attacherEvenements();
});

function attacherEvenements() {
  document.getElementById('btn-ajouter').addEventListener('click', ouvrirModalAjout);
  document.getElementById('btn-fermer-modal').addEventListener('click', fermerModal);
  document.getElementById('modal-overlay').addEventListener('click', e => {
    if (e.target === e.currentTarget) fermerModal();
  });
  document.getElementById('form-produit').addEventListener('submit', soumettreFormulaire);
  document.getElementById('btn-annuler-confirm').addEventListener('click', fermerConfirm);
  document.getElementById('btn-confirmer-suppr').addEventListener('click', confirmerSuppression);

  document.getElementById('recherche').addEventListener('input', e => {
    const terme = e.target.value.toLowerCase();
    const filtered = _produits.filter(p =>
      p.nom_produit.toLowerCase().includes(terme) ||
      String(p.prix_produit).includes(terme) ||
      nomFabricant(p.id_manu).toLowerCase().includes(terme)
    );
    rendreTableau(filtered);
  });

  document.getElementById('filtre-fab').addEventListener('change', e => {
    const val = e.target.value;
    const filtered = val ? _produits.filter(p => p.id_manu == val) : _produits;
    rendreTableau(filtered);
  });
}

async function chargerTout() {
  try {
    // Charge fabricants et produits en parallèle
    const [dataFab, dataProd] = await Promise.all([
      getAll('fabricants'),
      getAll('produits'),
    ]);
    _fabricants = dataFab.items || [];
    _produits   = dataProd.items || [];

    peuplerSelectFabricant('select-manu', _fabricants);
    peuplerFiltres(_fabricants);
    rendreTableau(_produits);
    document.getElementById('compteur').textContent = `${_produits.length} produit(s)`;
  } catch (err) {
    document.getElementById('produits-tbody').innerHTML = `
      <tr><td colspan="5">
        <div class="empty-state">
          <div class="empty-state-icon">⚠️</div>
          <div class="empty-state-text">Erreur : ${escHtml(err.message)}</div>
        </div>
      </td></tr>`;
    afficherToast('Erreur lors du chargement.', 'error');
  }
}

function peuplerSelectFabricant(selectId, fabricants) {
  const sel = document.getElementById(selectId);
  sel.innerHTML = '<option value="">— Aucun fabricant —</option>'
    + fabricants.map(f =>
        `<option value="${f.id_manu}">${escHtml(f.nom_manu)}</option>`
      ).join('');
}

function peuplerFiltres(fabricants) {
  const sel = document.getElementById('filtre-fab');
  sel.innerHTML = '<option value="">Tous les fabricants</option>'
    + fabricants.map(f =>
        `<option value="${f.id_manu}">${escHtml(f.nom_manu)}</option>`
      ).join('');
}

function nomFabricant(id) {
  const f = _fabricants.find(x => x.id_manu == id);
  return f ? f.nom_manu : '—';
}

function rendreTableau(produits) {
  const tbody = document.getElementById('produits-tbody');

  if (!produits || produits.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5">
      <div class="empty-state">
        <div class="empty-state-icon">🎸</div>
        <div class="empty-state-text">Aucun produit trouvé</div>
      </div>
    </td></tr>`;
    return;
  }

  tbody.innerHTML = produits.map(p => {
    const fab = nomFabricant(p.id_manu);
    return `
      <tr>
        <td class="td-id">${p.id_produit}</td>
        <td style="font-weight:600">${escHtml(p.nom_produit)}</td>
        <td class="td-price">${formatPrix(p.prix_produit)}</td>
        <td>
          <span class="badge badge-gold">${escHtml(fab)}</span>
        </td>
        <td>
          <div class="td-actions">
            <button class="btn btn-edit" onclick="ouvrirModalEdition(${p.id_produit})">Modifier</button>
            <button class="btn btn-danger" onclick="demanderSuppression(${p.id_produit})">Supprimer</button>
          </div>
        </td>
      </tr>`;
  }).join('');
}

function ouvrirModalAjout() {
  _modeEdition = false;
  _idEdition = null;
  document.getElementById('modal-titre').textContent = 'NOUVEAU PRODUIT';
  document.getElementById('form-produit').reset();
  document.getElementById('btn-soumettre').textContent = 'CRÉER';
  ouvrirModal();
}

async function ouvrirModalEdition(id) {
  _modeEdition = true;
  _idEdition = id;
  document.getElementById('modal-titre').textContent = 'MODIFIER LE PRODUIT';
  document.getElementById('btn-soumettre').textContent = 'ENREGISTRER';

  try {
    const p = _produits.find(x => x.id_produit == id) || await getById('produits', id);
    document.getElementById('field-nom').value   = p.nom_produit;
    document.getElementById('field-prix').value  = p.prix_produit;
    document.getElementById('select-manu').value = p.id_manu || '';
    ouvrirModal();
  } catch (err) {
    afficherToast('Impossible de charger ce produit.', 'error');
  }
}

async function soumettreFormulaire(e) {
  e.preventDefault();
  const nom  = document.getElementById('field-nom').value.trim();
  const prix = parseFloat(document.getElementById('field-prix').value);
  const manu = document.getElementById('select-manu').value;

  if (!nom) {
    afficherToast('Le nom du produit est obligatoire.', 'error');
    return;
  }
  if (isNaN(prix) || prix < 0) {
    afficherToast('Veuillez entrer un prix valide.', 'error');
    return;
  }

  const donnees = {
    nom_produit:  nom,
    prix_produit: prix,
    id_manu: manu ? Number(manu) : null,
  };

  const btn = document.getElementById('btn-soumettre');
  btn.disabled = true;
  btn.textContent = _modeEdition ? 'ENREGISTREMENT...' : 'CRÉATION...';

  try {
    if (_modeEdition) {
      await update('produits', _idEdition, donnees);
      afficherToast(`Produit "${nom}" mis à jour.`, 'success');
    } else {
      await create('produits', donnees);
      afficherToast(`Produit "${nom}" ajouté.`, 'success');
    }
    fermerModal();
    await chargerTout();
  } catch (err) {
    afficherToast('Erreur : ' + err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.textContent = _modeEdition ? 'ENREGISTRER' : 'CRÉER';
  }
}

function demanderSuppression(id) {
  _idSupprimer = id;
  const p = _produits.find(x => x.id_produit == id);
  document.getElementById('confirm-nom-prod').textContent = p ? p.nom_produit : `#${id}`;
  document.getElementById('confirm-overlay').classList.add('visible');
}

async function confirmerSuppression() {
  if (_idSupprimer === null) return;
  const btn = document.getElementById('btn-confirmer-suppr');
  btn.disabled = true;
  btn.textContent = 'SUPPRESSION...';
  try {
    await remove('produits', _idSupprimer);
    afficherToast('Produit supprimé avec succès.', 'success');
    fermerConfirm();
    await chargerTout();
  } catch (err) {
    afficherToast('Erreur : ' + err.message, 'error');
    fermerConfirm();
  } finally {
    btn.disabled = false;
    btn.textContent = 'SUPPRIMER';
    _idSupprimer = null;
  }
}

function ouvrirModal() {
  document.getElementById('modal-overlay').classList.add('visible');
  document.getElementById('field-nom').focus();
}

function fermerModal() {
  document.getElementById('modal-overlay').classList.remove('visible');
  document.getElementById('form-produit').reset();
}

function fermerConfirm() {
  document.getElementById('confirm-overlay').classList.remove('visible');
  _idSupprimer = null;
}

function formatPrix(val) {
  return val != null
    ? parseFloat(val).toLocaleString('fr-CA', { style: 'currency', currency: 'CAD' })
    : '—';
}

function escHtml(str) {
  const d = document.createElement('div');
  d.textContent = str ?? '';
  return d.innerHTML;
}

function afficherToast(msg, type = 'info') {
  const container = document.getElementById('toast-container');
  const icones = { success: '·', error: '·', info: '·' };
  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  toast.innerHTML = `<span class="toast-icon">${icones[type]}</span><span class="toast-msg">${escHtml(msg)}</span>`;
  container.appendChild(toast);
  setTimeout(() => {
    toast.classList.add('fade-out');
    setTimeout(() => toast.remove(), 280);
  }, 3500);
}
