/**
 * clients.js — Gestion des Clients
 * Manipulation du DOM et événements.
 * Tous les appels API passent par api.js.
 */

'use strict';

/* ══════════════════════════════════
   ÉTAT LOCAL
   ══════════════════════════════════ */
let _clients = [];        // cache des clients affichés
let _modeEdition = false; // true = formulaire en mode édition
let _idEdition = null;    // id du client en cours d'édition
let _idSupprimer = null;  // id à confirmer pour suppression

/* ══════════════════════════════════
   INITIALISATION
   ══════════════════════════════════ */
document.addEventListener('DOMContentLoaded', () => {
  chargerClients();
  attacherEvenements();
});

function attacherEvenements() {
  // Bouton "Ajouter un client"
  document.getElementById('btn-ajouter').addEventListener('click', ouvrirModalAjout);

  // Fermer le modal principal
  document.getElementById('btn-fermer-modal').addEventListener('click', fermerModal);
  document.getElementById('modal-overlay').addEventListener('click', e => {
    if (e.target === e.currentTarget) fermerModal();
  });

  // Soumission du formulaire
  document.getElementById('form-client').addEventListener('submit', soumettreFormulaire);

  // Fermer confirmation
  document.getElementById('btn-annuler-confirm').addEventListener('click', fermerConfirm);
  document.getElementById('btn-confirmer-suppr').addEventListener('click', confirmerSuppression);

  // Recherche en temps réel
  document.getElementById('recherche').addEventListener('input', e => {
    const terme = e.target.value.toLowerCase();
    const filtered = _clients.filter(c =>
      c.nom_client.toLowerCase().includes(terme) ||
      (c.telephone || '').includes(terme) ||
      (c.address || '').toLowerCase().includes(terme)
    );
    rendreTableau(filtered);
  });
}

/* ══════════════════════════════════
   CHARGEMENT DES DONNÉES
   ══════════════════════════════════ */
async function chargerClients() {
  const tbody = document.getElementById('clients-tbody');
  tbody.innerHTML = `
    <tr><td colspan="5">
      <div class="spinner-wrapper">
        <div class="spinner"></div> CHARGEMENT...
      </div>
    </td></tr>`;

  try {
    const data = await getAll('clients');
    _clients = data.items || [];
    rendreTableau(_clients);
    document.getElementById('compteur').textContent = `${_clients.length} client(s)`;
  } catch (err) {
    tbody.innerHTML = `
      <tr><td colspan="5">
        <div class="empty-state">
          <div class="empty-state-icon">⚠️</div>
          <div class="empty-state-text">Erreur : ${escHtml(err.message)}</div>
        </div>
      </td></tr>`;
    afficherToast('Erreur lors du chargement des clients.', 'error');
  }
}

/* ══════════════════════════════════
   RENDU DU TABLEAU
   ══════════════════════════════════ */
function rendreTableau(clients) {
  const tbody = document.getElementById('clients-tbody');

  if (!clients || clients.length === 0) {
    tbody.innerHTML = `
      <tr><td colspan="5">
        <div class="empty-state">
          <div class="empty-state-icon">👥</div>
          <div class="empty-state-text">Aucun client trouvé</div>
        </div>
      </td></tr>`;
    return;
  }

  tbody.innerHTML = clients.map(c => `
    <tr>
      <td class="td-id">${c.id_client}</td>
      <td style="font-weight:600">${escHtml(c.nom_client)}</td>
      <td>
        <a href="tel:${escHtml(c.telephone || '')}" style="color:var(--text-secondary); text-decoration:none;">
          ${escHtml(c.telephone || '—')}
        </a>
      </td>
      <td style="color:var(--text-secondary); font-size:.9rem;">${escHtml(c.address || '—')}</td>
      <td>
        <div class="td-actions">
          <button class="btn btn-edit" onclick="ouvrirModalEdition(${c.id_client})">Modifier</button>
          <button class="btn btn-danger" onclick="demanderSuppression(${c.id_client})">Supprimer</button>
        </div>
      </td>
    </tr>
  `).join('');
}

/* ══════════════════════════════════
   MODAL — AJOUT
   ══════════════════════════════════ */
function ouvrirModalAjout() {
  _modeEdition = false;
  _idEdition = null;
  document.getElementById('modal-titre').textContent = 'NOUVEAU CLIENT';
  document.getElementById('form-client').reset();
  document.getElementById('field-id').value = '';
  ouvrirModal();
}

/* ══════════════════════════════════
   MODAL — ÉDITION
   ══════════════════════════════════ */
async function ouvrirModalEdition(id) {
  _modeEdition = true;
  _idEdition = id;
  document.getElementById('modal-titre').textContent = 'MODIFIER LE CLIENT';

  try {
    const client = _clients.find(c => c.id_client == id)
      || await getById('clients', id);

    document.getElementById('field-id').value  = client.id_client;
    document.getElementById('field-nom').value = client.nom_client;
    document.getElementById('field-tel').value = client.telephone || '';
    document.getElementById('field-adr').value = client.address   || '';
    ouvrirModal();
  } catch (err) {
    afficherToast('Impossible de charger ce client.', 'error');
  }
}

/* ══════════════════════════════════
   SOUMISSION DU FORMULAIRE
   ══════════════════════════════════ */
async function soumettreFormulaire(e) {
  e.preventDefault();

  const nom = document.getElementById('field-nom').value.trim();
  const tel = document.getElementById('field-tel').value.trim();
  const adr = document.getElementById('field-adr').value.trim();

  if (!nom) {
    afficherToast('Le nom du client est obligatoire.', 'error');
    return;
  }

  const donnees = { nom_client: nom, telephone: tel, address: adr };
  const btnSoumettre = document.getElementById('btn-soumettre');
  btnSoumettre.disabled = true;
  btnSoumettre.textContent = _modeEdition ? 'ENREGISTREMENT...' : 'CRÉATION...';

  try {
    if (_modeEdition) {
      await update('clients', _idEdition, donnees);
      afficherToast(`Client "${nom}" mis à jour avec succès.`, 'success');
    } else {
      await create('clients', donnees);
      afficherToast(`Client "${nom}" ajouté avec succès.`, 'success');
    }
    fermerModal();
    await chargerClients();
  } catch (err) {
    afficherToast('Erreur : ' + err.message, 'error');
  } finally {
    btnSoumettre.disabled = false;
    btnSoumettre.textContent = _modeEdition ? 'ENREGISTRER' : 'CRÉER';
  }
}

/* ══════════════════════════════════
   SUPPRESSION
   ══════════════════════════════════ */
function demanderSuppression(id) {
  _idSupprimer = id;
  const client = _clients.find(c => c.id_client == id);
  const nom = client ? client.nom_client : `#${id}`;
  document.getElementById('confirm-nom-client').textContent = nom;
  document.getElementById('confirm-overlay').classList.add('visible');
}

async function confirmerSuppression() {
  if (_idSupprimer === null) return;
  const btn = document.getElementById('btn-confirmer-suppr');
  btn.disabled = true;
  btn.textContent = 'SUPPRESSION...';

  try {
    await remove('clients', _idSupprimer);
    afficherToast('Client supprimé avec succès.', 'success');
    fermerConfirm();
    await chargerClients();
  } catch (err) {
    afficherToast('Erreur : ' + err.message, 'error');
    fermerConfirm();
  } finally {
    btn.disabled = false;
    btn.textContent = 'SUPPRIMER';
    _idSupprimer = null;
  }
}

/* ══════════════════════════════════
   MODAL HELPERS
   ══════════════════════════════════ */
function ouvrirModal() {
  document.getElementById('modal-overlay').classList.add('visible');
  document.getElementById('field-nom').focus();
}

function fermerModal() {
  document.getElementById('modal-overlay').classList.remove('visible');
  document.getElementById('form-client').reset();
}

function fermerConfirm() {
  document.getElementById('confirm-overlay').classList.remove('visible');
  _idSupprimer = null;
}

/* ══════════════════════════════════
   UTILITAIRES
   ══════════════════════════════════ */
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
