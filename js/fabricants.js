/**
 * fabricants.js — Gestion des Fabricants
 * Manipulation du DOM et événements.
 * Tous les appels API passent par api.js.
 */

'use strict';

let _fabricants = [];
let _modeEdition = false;
let _idEdition = null;
let _idSupprimer = null;

document.addEventListener('DOMContentLoaded', () => {
  chargerFabricants();
  attacherEvenements();
});

function attacherEvenements() {
  document.getElementById('btn-ajouter').addEventListener('click', ouvrirModalAjout);
  document.getElementById('btn-fermer-modal').addEventListener('click', fermerModal);
  document.getElementById('modal-overlay').addEventListener('click', e => {
    if (e.target === e.currentTarget) fermerModal();
  });
  document.getElementById('form-fabricant').addEventListener('submit', soumettreFormulaire);
  document.getElementById('btn-annuler-confirm').addEventListener('click', fermerConfirm);
  document.getElementById('btn-confirmer-suppr').addEventListener('click', confirmerSuppression);

  document.getElementById('recherche').addEventListener('input', e => {
    const terme = e.target.value.toLowerCase();
    const filtered = _fabricants.filter(f =>
      f.nom_manu.toLowerCase().includes(terme) ||
      (f.telephone || '').includes(terme)
    );
    rendreTableau(filtered);
  });
}

async function chargerFabricants() {
  const tbody = document.getElementById('fabricants-tbody');
  tbody.innerHTML = `
    <tr><td colspan="4">
      <div class="spinner-wrapper"><div class="spinner"></div> CHARGEMENT...</div>
    </td></tr>`;
  try {
    const data = await getAll('fabricants');
    _fabricants = data.items || [];
    rendreTableau(_fabricants);
    document.getElementById('compteur').textContent = `${_fabricants.length} fabricant(s)`;
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="4">
      <div class="empty-state">
        <div class="empty-state-icon">⚠️</div>
        <div class="empty-state-text">Erreur : ${escHtml(err.message)}</div>
      </div>
    </td></tr>`;
    afficherToast('Erreur lors du chargement des fabricants.', 'error');
  }
}

function rendreTableau(fabricants) {
  const tbody = document.getElementById('fabricants-tbody');
  if (!fabricants || fabricants.length === 0) {
    tbody.innerHTML = `<tr><td colspan="4">
      <div class="empty-state">
        <div class="empty-state-icon">🏭</div>
        <div class="empty-state-text">Aucun fabricant trouvé</div>
      </div>
    </td></tr>`;
    return;
  }

  tbody.innerHTML = fabricants.map(f => `
    <tr>
      <td class="td-id">${f.id_manu}</td>
      <td style="font-weight:600">${escHtml(f.nom_manu)}</td>
      <td>
        <a href="tel:${escHtml(f.telephone || '')}" style="color:var(--text-secondary); text-decoration:none;">
          ${escHtml(f.telephone || '—')}
        </a>
      </td>
      <td>
        <div class="td-actions">
          <button class="btn btn-edit" onclick="ouvrirModalEdition(${f.id_manu})">Modifier</button>
          <button class="btn btn-danger" onclick="demanderSuppression(${f.id_manu})">Supprimer</button>
        </div>
      </td>
    </tr>
  `).join('');
}

function ouvrirModalAjout() {
  _modeEdition = false;
  _idEdition = null;
  document.getElementById('modal-titre').textContent = 'NOUVEAU FABRICANT';
  document.getElementById('form-fabricant').reset();
  document.getElementById('btn-soumettre').textContent = 'CRÉER';
  ouvrirModal();
}

async function ouvrirModalEdition(id) {
  _modeEdition = true;
  _idEdition = id;
  document.getElementById('modal-titre').textContent = 'MODIFIER LE FABRICANT';
  document.getElementById('btn-soumettre').textContent = 'ENREGISTRER';
  try {
    const f = _fabricants.find(x => x.id_manu == id) || await getById('fabricants', id);
    document.getElementById('field-nom').value = f.nom_manu;
    document.getElementById('field-tel').value = f.telephone || '';
    ouvrirModal();
  } catch (err) {
    afficherToast('Impossible de charger ce fabricant.', 'error');
  }
}

async function soumettreFormulaire(e) {
  e.preventDefault();
  const nom = document.getElementById('field-nom').value.trim();
  const tel = document.getElementById('field-tel').value.trim();

  if (!nom) {
    afficherToast('Le nom du fabricant est obligatoire.', 'error');
    return;
  }

  const donnees = { nom_manu: nom, telephone: tel };
  const btn = document.getElementById('btn-soumettre');
  btn.disabled = true;
  btn.textContent = _modeEdition ? 'ENREGISTREMENT...' : 'CRÉATION...';

  try {
    if (_modeEdition) {
      await update('fabricants', _idEdition, donnees);
      afficherToast(`Fabricant "${nom}" mis à jour.`, 'success');
    } else {
      await create('fabricants', donnees);
      afficherToast(`Fabricant "${nom}" ajouté.`, 'success');
    }
    fermerModal();
    await chargerFabricants();
  } catch (err) {
    afficherToast('Erreur : ' + err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.textContent = _modeEdition ? 'ENREGISTRER' : 'CRÉER';
  }
}

function demanderSuppression(id) {
  _idSupprimer = id;
  const f = _fabricants.find(x => x.id_manu == id);
  document.getElementById('confirm-nom-fab').textContent = f ? f.nom_manu : `#${id}`;
  document.getElementById('confirm-overlay').classList.add('visible');
}

async function confirmerSuppression() {
  if (_idSupprimer === null) return;
  const btn = document.getElementById('btn-confirmer-suppr');
  btn.disabled = true;
  btn.textContent = 'SUPPRESSION...';
  try {
    await remove('fabricants', _idSupprimer);
    afficherToast('Fabricant supprimé avec succès.', 'success');
    fermerConfirm();
    await chargerFabricants();
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
  document.getElementById('form-fabricant').reset();
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
