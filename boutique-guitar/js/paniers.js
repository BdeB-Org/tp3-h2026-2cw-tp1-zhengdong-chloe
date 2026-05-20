/**
 * paniers.js — Gestion des Paniers
 * Manipulation du DOM et événements.
 * Tous les appels API passent par api.js.
 */

'use strict';

let _paniers     = [];
let _clients     = [];
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
  document.getElementById('form-panier').addEventListener('submit', soumettreFormulaire);
  document.getElementById('btn-annuler-confirm').addEventListener('click', fermerConfirm);
  document.getElementById('btn-confirmer-suppr').addEventListener('click', confirmerSuppression);

  document.getElementById('recherche').addEventListener('input', e => {
    const terme = e.target.value.toLowerCase();
    const filtered = _paniers.filter(p =>
      String(p.id_panier).includes(terme) ||
      nomClient(p.id_client).toLowerCase().includes(terme) ||
      (p.date_creation || '').includes(terme)
    );
    rendreTableau(filtered);
  });
}

async function chargerTout() {
  try {
    const [dataClients, dataPaniers] = await Promise.all([
      getAll('clients'),
      getAll('paniers'),
    ]);
    _clients = dataClients.items || [];
    _paniers = dataPaniers.items || [];

    peuplerSelectClients(_clients);
    rendreTableau(_paniers);
    document.getElementById('compteur').textContent = `${_paniers.length} panier(s)`;
  } catch (err) {
    document.getElementById('paniers-tbody').innerHTML = `
      <tr><td colspan="5">
        <div class="empty-state">
          <div class="empty-state-icon">⚠️</div>
          <div class="empty-state-text">Erreur : ${escHtml(err.message)}</div>
        </div>
      </td></tr>`;
    afficherToast('Erreur lors du chargement.', 'error');
  }
}

function peuplerSelectClients(clients) {
  const sel = document.getElementById('select-client');
  sel.innerHTML = '<option value="">— Sélectionner un client —</option>'
    + clients.map(c =>
        `<option value="${c.id_client}">${escHtml(c.nom_client)}</option>`
      ).join('');
}

function nomClient(id) {
  const c = _clients.find(x => x.id_client == id);
  return c ? c.nom_client : `Client #${id}`;
}

function formaterDate(dateStr) {
  if (!dateStr) return '—';
  try {
    return new Date(dateStr).toLocaleDateString('fr-CA', {
      year: 'numeric', month: 'long', day: 'numeric'
    });
  } catch {
    return dateStr;
  }
}

function statutPanier(dateStr) {
  if (!dateStr) return { label: 'Inconnu', classe: '' };
  const d = new Date(dateStr);
  const now = new Date();
  const jours = Math.floor((now - d) / 86400000);
  if (jours <= 7)  return { label: 'Récent',  classe: 'badge-green' };
  if (jours <= 30) return { label: 'Actif',   classe: 'badge-gold' };
  return { label: 'Ancien', classe: 'badge-red' };
}

function rendreTableau(paniers) {
  const tbody = document.getElementById('paniers-tbody');

  if (!paniers || paniers.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5">
      <div class="empty-state">
        <div class="empty-state-icon">🛒</div>
        <div class="empty-state-text">Aucun panier trouvé</div>
      </div>
    </td></tr>`;
    return;
  }

  tbody.innerHTML = paniers.map(p => {
    const client = nomClient(p.id_client);
    const date   = formaterDate(p.date_creation);
    const statut = statutPanier(p.date_creation);
    return `
      <tr>
        <td class="td-id">${p.id_panier}</td>
        <td style="font-weight:600">${escHtml(client)}</td>
        <td style="color:var(--text-secondary); font-size:.9rem;">${date}</td>
        <td><span class="badge ${statut.classe}">${statut.label}</span></td>
        <td>
          <div class="td-actions">
            <button class="btn btn-edit" onclick="ouvrirModalEdition(${p.id_panier})">Modifier</button>
            <button class="btn btn-danger" onclick="demanderSuppression(${p.id_panier})">Supprimer</button>
          </div>
        </td>
      </tr>`;
  }).join('');
}

function ouvrirModalAjout() {
  _modeEdition = false;
  _idEdition = null;
  document.getElementById('modal-titre').textContent = 'NOUVEAU PANIER';
  document.getElementById('form-panier').reset();
  // Date du jour par défaut
  document.getElementById('field-date').value = new Date().toISOString().split('T')[0];
  document.getElementById('btn-soumettre').textContent = 'CRÉER';
  ouvrirModal();
}

async function ouvrirModalEdition(id) {
  _modeEdition = true;
  _idEdition = id;
  document.getElementById('modal-titre').textContent = 'MODIFIER LE PANIER';
  document.getElementById('btn-soumettre').textContent = 'ENREGISTRER';

  try {
    const p = _paniers.find(x => x.id_panier == id) || await getById('paniers', id);
    document.getElementById('select-client').value = p.id_client || '';
    document.getElementById('field-date').value    = p.date_creation ? p.date_creation.split('T')[0] : '';
    ouvrirModal();
  } catch (err) {
    afficherToast('Impossible de charger ce panier.', 'error');
  }
}

async function soumettreFormulaire(e) {
  e.preventDefault();
  const clientId = document.getElementById('select-client').value;
  const date     = document.getElementById('field-date').value;

  if (!clientId) {
    afficherToast('Veuillez sélectionner un client.', 'error');
    return;
  }

  const donnees = {
    id_client:      Number(clientId),
    date_creation:  date || new Date().toISOString().split('T')[0],
  };

  const btn = document.getElementById('btn-soumettre');
  btn.disabled = true;
  btn.textContent = _modeEdition ? 'ENREGISTREMENT...' : 'CRÉATION...';

  try {
    if (_modeEdition) {
      await update('paniers', _idEdition, donnees);
      afficherToast('Panier mis à jour avec succès.', 'success');
    } else {
      await create('paniers', donnees);
      afficherToast('Nouveau panier créé avec succès.', 'success');
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
  const p = _paniers.find(x => x.id_panier == id);
  const info = p ? `Panier #${p.id_panier} de ${nomClient(p.id_client)}` : `Panier #${id}`;
  document.getElementById('confirm-nom-panier').textContent = info;
  document.getElementById('confirm-overlay').classList.add('visible');
}

async function confirmerSuppression() {
  if (_idSupprimer === null) return;
  const btn = document.getElementById('btn-confirmer-suppr');
  btn.disabled = true;
  btn.textContent = 'SUPPRESSION...';
  try {
    await remove('paniers', _idSupprimer);
    afficherToast('Panier supprimé avec succès.', 'success');
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
}

function fermerModal() {
  document.getElementById('modal-overlay').classList.remove('visible');
  document.getElementById('form-panier').reset();
}

function fermerConfirm() {
  document.getElementById('confirm-overlay').classList.remove('visible');
  _idSupprimer = null;
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
